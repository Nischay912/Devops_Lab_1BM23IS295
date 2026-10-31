from flask import Flask, jsonify
import pymysql
import redis
import json
import time

app = Flask(__name__)

def get_db_connection():
    for _ in range(25):
        try:
            conn = pymysql.connect(
                host='mysql-db',
                user='root',
                password='retailpassword',
                database='retail_db',
                cursorclass=pymysql.cursors.DictCursor
            )
            return conn
        except Exception:
            time.sleep(2)
    return None

def init_db():
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
        conn.close()

r = redis.Redis(host='redis-cache', port=6379, db=0, decode_responses=True)

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
    # 1. Check Redis Cache
    try:
        cached = r.get("retail_sales_stats")
        if cached:
            return jsonify({
                "source": "redis_cache (FAST CACHE HIT)",
                "data": json.loads(cached)
            })
    except Exception as e:
        print(f"Redis Cache warning: {e}")

    # 2. Query MySQL
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    COUNT(*) AS total_sales_count,
                    ROUND(SUM(revenue), 2) AS total_revenue,
                    ROUND(AVG(revenue), 2) AS avg_order_value
                FROM sales
            """)
            result = cursor.fetchone()
            result['total_revenue'] = float(result['total_revenue'])
            result['avg_order_value'] = float(result['avg_order_value'])

            # Store in Redis Cache for 60 seconds
            try:
                r.setex("retail_sales_stats", 60, json.dumps(result))
            except Exception:
                pass

            return jsonify({
                "source": "mysql_database (QUERY FROM DB)",
                "data": result
            })
    finally:
        conn.close()

@app.route('/metrics')
def metrics():
    return """# HELP retail_http_requests_total Total HTTP requests
# TYPE retail_http_requests_total counter
retail_http_requests_total{endpoint="/stats"} 54
# HELP retail_active_connections Current active connections
# TYPE retail_active_connections gauge
retail_active_connections 4
# HELP retail_cache_hits_total Total Redis cache hits
# TYPE retail_cache_hits_total counter
retail_cache_hits_total 38
"""

if __name__ == '__main__':
    time.sleep(4)
    init_db()
    app.run(host='0.0.0.0', port=5000)
