# 🎯 QUESTION 6 — COMPLETE STEP-BY-STEP EXAM GUIDE & CODE BREAKDOWN

This guide maps all **8 Tasks** of Question 6 directly to the code, provides copy-paste commands, and gives simple layman explanations for the teacher.

---

## 📌 TABLE OF TASKS & CODE MAPPING

| Task | Topic | Code File & Location | Command to Run | What it Proves |
| :--- | :--- | :--- | :--- | :--- |
| **Task 1** | Flask Retail Service | `app.py` (Lines 31-92) | `wget -qO- http://localhost:5000/stats` | Returns sales JSON statistics |
| **Task 2** | Custom Bridge Network | `run.sh` / Docker CLI | `docker network inspect retail-net` | Containers communicate on private bridge |
| **Task 3** | MySQL Storage & Redis Cache | `app.py` (Lines 42-65 & 34-40) | `wget -qO- http://localhost:5000/stats` (x2) | First hits MySQL, second hits Redis cache |
| **Task 4** | Verify Connectivity & Logs | `app.py` / Docker CLI | `docker logs --tail 5 retail-app` | Shows HTTP 200 requests in container logs |
| **Task 5** | AppArmor Security Confinement | `my-apparmor-profile` | `docker exec retail-app cat /etc/passwd` | Kernel blocks sensitive file (Exit Code 1) |
| **Task 6** | Database Port Isolation | `run.sh` (MySQL run command) | `wget -O- http://localhost:3306` | Port 3306 connection refused from host |
| **Task 7** | Resource Monitoring | `app.py` (/metrics) & Prometheus | `docker stats --no-stream` | Live CPU & RAM utilization table |
| **Task 8** | Fault Diagnosis & Recovery | `app.py` (Lines 32-41) | `docker stop redis-cache` $\rightarrow$ `docker start` | Graceful degradation and instant recovery |

---

## 🔍 CODE BREAKDOWN: WHERE EACH COMPONENT LIVES

### 1. Where is the Sample Sales Data? (`app.py` Lines 42–65)
In `app.py`, the MySQL initialization query stores 5 products:
```python
INSERT INTO sales (product, category, revenue) VALUES
('Laptop Pro', 'Electronics', 1299.99),
('Wireless Headphones', 'Electronics', 149.50),
('Ergonomic Chair', 'Furniture', 249.00),
('Organic Coffee Beans', 'Groceries', 24.99),
('LED Desk Lamp', 'Furniture', 49.99)
```
- **Total Revenue:** $1299.99 + 149.50 + 249.00 + 24.99 + 49.99 = **$1769.47**
- **Average Order Value:** $1769.47 / 5 = **$353.89**
- **Total Orders:** **5**
*(Show this to the teacher so they see the exact math matches your output!)*

### 2. Where is the Redis Cache Code? (`app.py` Lines 34–40)
```python
# 1. Checks Redis Cache first:
cached = r.get("retail_sales_stats")
if cached:
    return jsonify({
        "source": "redis_cache (FAST CACHE HIT)",
        "data": json.loads(cached)
    })
```
And stores it with a 60-second timer:
```python
r.setex("retail_sales_stats", 60, json.dumps(stats))
```

### 3. Where is the AppArmor Restriction? (`my-apparmor-profile`)
```apparmor
deny /etc/passwd r,    # Blocks reading password file
deny /bin/bash x,      # Blocks executing shell binary
```
Applied in Docker using:
`--security-opt="apparmor=my-apparmor-profile"`

---

## 🚀 STEP-BY-STEP DEMONSTRATION COMMANDS (Copy One by One)

### 🔹 TASK 1 & 3: Demonstrate Flask Service, MySQL Storage & Redis Caching
**Run this command:**
```bash
wget -qO- http://localhost:5000/stats
```
**Expected Output:**
```json
{"data":{"avg_order_value":353.89,"total_revenue":1769.47,"total_sales_count":5},"source":"mysql_database (QUERY FROM DB)"}
```
🗣️ **What to tell teacher (Plain Layman English):**
> *"Ma'am, here is Task 1 and Task 3. Our Flask app connected to MySQL, calculated the total sales for our 5 products ($1769.47), and saved a copy into Redis cache."*

---

### 🔹 TASK 4: Verify Connectivity & Container Logs
**Run this command:**
```bash
docker logs --tail 5 retail-app
```
**Expected Output:**
```text
172.18.0.1 - - [31/Oct/2026 ...] "GET /stats HTTP/1.1" 200 -
172.18.0.4 - - [31/Oct/2026 ...] "GET /metrics HTTP/1.1" 200 -
```
🗣️ **What to tell teacher:**
> *"Here is Task 4. Container logs confirm that our HTTP requests returned status code 200 OK, and Prometheus is actively communicating with Flask over `retail-net`."*

---

### 🔹 TASK 5: Test AppArmor Security Confinement
**Run this command:**
```bash
docker exec retail-app cat /etc/passwd
```
**Expected Output:**
```text
cat: /etc/passwd: Permission denied
```
🗣️ **What to tell teacher:**
> *"Here is Task 5. Even though this container runs with root privileges, our AppArmor Mandatory Access Control profile intercepts the read request and blocks access to sensitive system credentials with Exit Code 1."*

---

### 🔹 TASK 6: Demonstrate Database Port Isolation (Why DB Port Not Published)
**Run this command:**
```bash
wget -O- http://localhost:3306
```
**Expected Output:**
```text
Connecting to localhost|127.0.0.1|:3306... failed: Connection refused.
```
**And show network inspection:**
```bash
docker network inspect retail-net | grep -A 4 -E "(mysql-db|retail-app)"
```
🗣️ **What to tell teacher:**
> *"Here is Task 6. MySQL port 3306 is not published to the outside host, so connection is refused from our laptop. Inside `retail-net`, Flask and MySQL communicate securely by container name using Docker's embedded DNS without exposing the database to hackers."*

---

### 🔹 TASK 7: Operational Resource Monitoring
**Run this command:**
```bash
docker stats --no-stream
```
**Expected Output:**
A live table showing CPU % and Memory consumption across all microservices:
```text
CONTAINER ID   NAME          CPU %     MEM USAGE / LIMIT
44bcf620d819   retail-app    0.02%     25.18MiB / 3.82GiB
c3207cabfde8   mysql-db      0.15%     169.4MiB / 3.82GiB
04733d0304bd   redis-cache   0.52%     5.77MiB / 3.82GiB
456560d3b9f3   prometheus    1.02%     24.39MiB / 3.82GiB
```
**And check Prometheus metrics endpoint:**
```bash
wget -qO- http://localhost:5000/metrics | head -n 6
```
🗣️ **What to tell teacher:**
> *"Here is Task 7. `docker stats` provides real-time resource utilization monitoring for CPU and Memory, and our `/metrics` endpoint exports Prometheus metrics for operational tracking."*

---

### 🔹 TASK 8: Fault Diagnosis & Service Recovery
**Step 1: Deliberately stop Redis Cache container:**
```bash
docker stop redis-cache
```

**Step 2: Query the Flask service and inspect logs:**
```bash
wget -qO- http://localhost:5000/stats
docker logs --tail 3 retail-app
```
*(Notice: The service gracefully falls back to MySQL and returns sales data without crashing!).*

**Step 3: Restore the service:**
```bash
docker start redis-cache
wget -qO- http://localhost:5000/stats
```
🗣️ **What to tell teacher:**
> *"Here is Task 8. We simulated a component failure by stopping Redis. Flask gracefully handled the broken connection by querying MySQL directly without crashing, and restarting Redis restored full service immediately."*
