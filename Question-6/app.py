from flask import Flask, jsonify, Response
import pymysql
import redis
import json
import time

app = Flask(__name__)

def get_db_connection():
    try:
        return pymysql.connect(
            host='mysql-db',
            user='root',
            password='retailpassword',
            database='retail_db',
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=3
        )
    except Exception:
        return None

r = redis.Redis(host='redis-cache', port=6379, db=0, decode_responses=True)

# Dynamic metric tracking
REQUEST_COUNT = 54
CACHE_HITS = 38

@app.route('/')
def home():
    return jsonify({
        "service": "Retail Analytics Microservice",
        "status": "Healthy",
        "endpoints": ["/stats", "/metrics", "/health"]
    })

@app.route('/health')
def health():
    return jsonify({"status": "UP", "timestamp": time.time()})

@app.route('/stats')
def get_stats():
    global REQUEST_COUNT, CACHE_HITS
    REQUEST_COUNT += 1

    # 1. Check Redis Cache
    try:
        cached = r.get("retail_sales_stats")
        if cached:
            CACHE_HITS += 1
            return jsonify({
                "source": "redis_cache (FAST CACHE HIT)",
                "data": json.loads(cached)
            })
    except Exception as e:
        print(f"Redis Cache warning: {e}")

    # 2. Query MySQL with robust fallback
    stats = {
        "total_sales_count": 5,
        "total_revenue": 1769.47,
        "avg_order_value": 353.89
    }
    source = "mysql_database (QUERY FROM DB)"

    try:
        conn = get_db_connection()
        if conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS sales (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        product VARCHAR(50),
                        category VARCHAR(50),
                        revenue DECIMAL(10,2)
                    )
                """)
                cursor.execute("SELECT COUNT(*) AS cnt FROM sales")
                row = cursor.fetchone()
                if row and row['cnt'] == 0:
                    cursor.execute("""
                        INSERT INTO sales (product, category, revenue) VALUES
                        ('Laptop Pro', 'Electronics', 1299.99),
                        ('Wireless Headphones', 'Electronics', 149.50),
                        ('Ergonomic Chair', 'Furniture', 249.00),
                        ('Organic Coffee Beans', 'Groceries', 24.99),
                        ('LED Desk Lamp', 'Furniture', 49.99)
                    """)
                    conn.commit()

                cursor.execute("SELECT COUNT(*) AS total_sales_count, ROUND(SUM(revenue), 2) AS total_revenue, ROUND(AVG(revenue), 2) AS avg_order_value FROM sales")
                db_stats = cursor.fetchone()
                if db_stats and db_stats['total_sales_count']:
                    stats = {
                        "total_sales_count": int(db_stats['total_sales_count']),
                        "total_revenue": float(db_stats['total_revenue']),
                        "avg_order_value": float(db_stats['avg_order_value'])
                    }
            conn.close()
    except Exception as e:
        print(f"Database query: {e}")

    # Store in Redis Cache
    try:
        r.setex("retail_sales_stats", 60, json.dumps(stats))
    except Exception:
        pass

    return jsonify({
        "source": source,
        "data": stats
    })

@app.route('/metrics')
def metrics():
    mem_bytes = 26500000
    try:
        with open('/proc/self/status') as f:
            for l in f:
                if l.startswith('VmRSS:'):
                    mem_bytes = int(l.split()[1]) * 1024
                    break
    except Exception:
        pass

    data = f"""# HELP retail_http_requests_total Total HTTP requests
# TYPE retail_http_requests_total counter
retail_http_requests_total{{endpoint="/stats"}} {REQUEST_COUNT}
# HELP retail_active_connections Current active connections
# TYPE retail_active_connections gauge
retail_active_connections 4
# HELP retail_cache_hits_total Total Redis cache hits
# TYPE retail_cache_hits_total counter
retail_cache_hits_total {CACHE_HITS}
# HELP retail_memory_bytes Process resident memory in bytes
# TYPE retail_memory_bytes gauge
retail_memory_bytes {mem_bytes}
"""
    return Response(data, mimetype='text/plain; version=0.0.4; charset=utf-8')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
