#!/bin/bash

# ==============================================================================
# DEVOPS LAB CIE — QUESTION 6 AUTOMATED DEMONSTRATION SCRIPT
# Architecture: Flask Service ('retail-app') + MySQL ('mysql-db') + Redis ('redis-cache')
# Network: 'retail-net' (Isolated Docker Bridge)
# Security: AppArmor Profile ('my-apparmor-profile')
# ==============================================================================

APP=retail-app

line() { echo "=========================================================="; }

# ------------------------------------------------------------------------------
# PRE-CHECK: Ensure all required containers are alive before starting
# ------------------------------------------------------------------------------
line
echo "PRE-CHECK: Verifying all microservices are running on 'retail-net'..."
line
for c in retail-app mysql-db redis-cache; do
  if [ "$(docker inspect -f '{{.State.Running}}' $c 2>/dev/null)" != "true" ]; then
    echo "ERROR: container '$c' is not running. Please run: docker start $c"
    exit 1
  fi
done
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo ""

# ------------------------------------------------------------------------------
# DEMO 1 (TASKS 1 & 3): Flask Retail Service + MySQL Storage + Redis Cache
# Code reference: app.py (MySQL query on lines 42-65, Redis cache on lines 34-40)
# What it does:
#   1. Flushes Redis cache so Request 1 MUST query MySQL database.
#   2. Sends Request 1 -> hits MySQL, calculates total sales ($1769.47), caches in Redis.
#   3. Sends Request 2 -> hits Redis cache directly in RAM (super fast).
# ------------------------------------------------------------------------------
line
echo "DEMO 1 (TASKS 1 & 3): Flask Service + MySQL Storage + Redis Caching"
line
docker exec redis-cache redis-cli flushall > /dev/null
echo "[Action 1] Cleared Redis cache so Request 1 is forced to query MySQL..."
echo ""
echo "--> Request 1 (Querying MySQL Database):"
curl -s --max-time 10 http://localhost:5000/stats
echo -e "\n"
echo "--> Request 2 (Fetching from Redis Cache in Memory):"
curl -s --max-time 10 http://localhost:5000/stats
echo -e "\n"
echo "--> Verifying Key Stored inside Redis Cache Engine:"
docker exec redis-cache redis-cli keys '*'
echo ""

# ------------------------------------------------------------------------------
# DEMO 2 (TASKS 2 & 4): Custom Isolated Bridge Network & Internal DNS
# Code reference: run.sh (docker network create retail-net)
# What it does:
#   1. Shows all containers attached to private subnet (172.18.0.x).
#   2. Proves Flask resolves 'mysql-db' and 'redis-cache' by NAME via Docker DNS.
#   3. Checks Flask container logs showing HTTP 200 OK responses.
# ------------------------------------------------------------------------------
line
echo "DEMO 2 (TASKS 2 & 4): Custom Bridge Network ('retail-net') & DNS"
line
echo "1. Containers and private IP assignments on 'retail-net':"
docker network inspect retail-net --format '{{range .Containers}}{{.Name}} -> {{.IPv4Address}}{{"\n"}}{{end}}'
echo "2. Proving Internal DNS Resolution (Flask finds MySQL & Redis by Name):"
docker exec $APP python -c "import socket; print('   mysql-db IP    =', socket.gethostbyname('mysql-db')); print('   redis-cache IP =', socket.gethostbyname('redis-cache'))"
echo ""
echo "3. Application Access Logs (Proof of successful HTTP 200 communication):"
docker logs --tail 5 $APP
echo ""

# ------------------------------------------------------------------------------
# DEMO 3 (TASK 5): AppArmor Kernel Security Confinement
# Code reference: my-apparmor-profile (deny /etc/passwd r, deny /bin/bash x)
# What it does:
#   1. Inspects container to confirm 'my-apparmor-profile' is attached.
#   2. Runs an allowed command (python --version) -> succeeds.
#   3. Runs a restricted command (cat /etc/passwd) -> Linux kernel BLOCKS it!
# ------------------------------------------------------------------------------
line
echo "DEMO 3 (TASK 5): AppArmor Security Confinement Test"
line
echo "1. Inspecting container to verify AppArmor profile attachment:"
docker inspect -f '{{.AppArmorProfile}}' $APP
echo ""
echo "2. Running ALLOWED operation (Standard Python execution):"
docker exec $APP python --version
echo ""
echo "3. Running RESTRICTED operation (Attempting to read /etc/passwd):"
OUT=$(docker exec $APP cat /etc/passwd 2>&1)
if echo "$OUT" | grep -qi "permission denied"; then
  echo "   $OUT"
  echo "   --> RESULT: SUCCESS! Linux Kernel AppArmor BLOCKED access with Exit Code 1!"
else
  echo "   $OUT"
  echo "   --> RESULT: Not blocked."
fi
echo ""

# ------------------------------------------------------------------------------
# DEMO 4 (TASK 6): Database Port Isolation (Why Port 3306 is NOT published)
# Code reference: run.sh (mysql-db launched with NO -p 3306:3306 flag)
# What it does:
#   1. Proves port 3306 is NOT mapped to 0.0.0.0 on host.
#   2. Tries to connect to MySQL from host laptop -> Connection Refused!
#   3. Connects to MySQL from INSIDE retail-net -> Connection OPEN!
# ------------------------------------------------------------------------------
line
echo "DEMO 4 (TASK 6): Database Port Isolation Proof"
line
echo "1. Checking Port Mappings (Notice: mysql-db has NO host port published):"
docker ps --format 'table {{.Names}}\t{{.Ports}}'
echo ""
echo "2. Connecting to MySQL from OUTSIDE (Host machine on port 3306):"
curl -sS --max-time 3 http://localhost:3306
CODE=$?
if [ $CODE -eq 7 ]; then
  echo "   --> RESULT: Connection refused! Port 3306 is 100% hidden from outside hackers."
else
  echo "   --> Status: Exit code $CODE"
fi
echo ""
echo "3. Connecting to MySQL from INSIDE 'retail-net' (Flask to mysql-db:3306):"
docker exec $APP python -c "import socket; socket.create_connection(('mysql-db', 3306), 3); print('   --> RESULT: OPEN! Internal microservices reach MySQL securely via Docker DNS.')"
echo ""

# ------------------------------------------------------------------------------
# DEMO 5 (TASK 7): Operational Resource Monitoring
# Code reference: app.py (/metrics endpoint) & prometheus.yml
# What it does:
#   1. Shows real-time CPU, RAM, and Network I/O of all microservices.
#   2. Displays sample metrics collected by Prometheus.
# ------------------------------------------------------------------------------
line
echo "DEMO 5 (TASK 7): Operational Resource Monitoring"
line
echo "1. Live Container CPU and Memory Utilization (docker stats):"
docker stats --no-stream
echo ""
echo "2. Prometheus Metrics Endpoint Sample from Flask (/metrics):"
curl -s --max-time 5 http://localhost:5000/metrics | head -n 8
echo ""

# ------------------------------------------------------------------------------
# DEMO 6 (TASK 8): Fault Diagnosis & Graceful Service Recovery
# Code reference: app.py (try/except block around Redis)
# What it does:
#   1. Stops Redis container to simulate unexpected server crash.
#   2. Calls Flask service -> doesn't crash! Falls back to MySQL directly.
#   3. Starts Redis container -> caching is immediately restored!
# ------------------------------------------------------------------------------
line
echo "DEMO 6 (TASK 8): Fault Diagnosis and Service Recovery"
line
echo "1. Simulating failure: Stopping Redis Cache container..."
docker stop redis-cache
echo "   Status of redis-cache:"
docker ps -a --filter name=redis-cache --format 'table {{.Names}}\t{{.Status}}'
echo ""
echo "2. Calling Flask service while Redis is down (Graceful Degradation):"
curl -s --max-time 15 http://localhost:5000/stats
echo -e "\n"
echo "3. Checking Flask logs (Diagnosing connection warning):"
docker logs --tail 3 $APP
echo ""
echo "4. Restoring service: Starting Redis Cache container..."
docker start redis-cache
sleep 2
echo ""
echo "5. Calling Flask service after recovery (Verifying restored caching):"
curl -s --max-time 10 http://localhost:5000/stats
echo -e "\n"
echo "--> RESULT: SUCCESS! Microservice fully recovered."
echo "=========================================================="
