#!/bin/bash

APP=retail-app

line() { echo "=========================================================="; }

# ---------- PRE-CHECK ----------
line
echo "PRE-CHECK: Are all containers running?"
line
for c in retail-app mysql-db redis-cache; do
  if [ "$(docker inspect -f '{{.State.Running}}' $c 2>/dev/null)" != "true" ]; then
    echo "ERROR: container '$c' is not running. Start it with: docker start $c"
    exit 1
  fi
done
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo ""

# ---------- DEMO 1 ----------
line
echo "DEMO 1: Flask + MySQL + Redis caching (Tasks 1, 3)"
line
docker exec redis-cache redis-cli flushall > /dev/null
echo "(Redis cache cleared so Request 1 must go to MySQL)"
echo ""
echo "Request 1 (should say mysql_database):"
curl -s --max-time 10 http://localhost:5000/stats
echo -e "\n"
echo "Request 2 (should say redis cache):"
curl -s --max-time 10 http://localhost:5000/stats
echo -e "\n"
echo "Key stored inside Redis:"
docker exec redis-cache redis-cli keys '*'
echo ""

# ---------- DEMO 2 ----------
line
echo "DEMO 2: Custom bridge network and logs (Tasks 2, 4)"
line
echo "Containers attached to retail-net:"
docker network inspect retail-net --format '{{range .Containers}}{{.Name}} -> {{.IPv4Address}}{{"\n"}}{{end}}'
echo "Flask can find the other containers by NAME (internal DNS):"
docker exec $APP python -c "import socket; print('mysql-db =', socket.gethostbyname('mysql-db'), '| redis-cache =', socket.gethostbyname('redis-cache'))"
echo ""
echo "Flask logs (proof that requests were answered):"
docker logs --tail 5 $APP
echo ""

# ---------- DEMO 3 ----------
line
echo "DEMO 3: AppArmor confinement (Task 5)"
line
echo "Profile applied to retail-app:"
docker inspect -f '{{.AppArmorProfile}}' $APP
echo ""
echo "Allowed operation (should work):"
docker exec $APP python --version
echo ""
echo "Restricted operation: reading /etc/passwd"
OUT=$(docker exec $APP cat /etc/passwd 2>&1)
if echo "$OUT" | grep -qi "permission denied"; then
  echo "$OUT"
  echo "--> RESULT: AppArmor BLOCKED the read."
else
  echo "--> RESULT: NOT blocked. The profile is not working!"
fi
echo ""
echo "Kernel log entry (needs sudo password):"
sudo dmesg 2>/dev/null | grep -i 'apparmor="DENIED"' | tail -n 2
echo ""

# ---------- DEMO 4 ----------
line
echo "DEMO 4: Why MySQL port 3306 is not published (Task 6)"
line
echo "Port mappings (mysql-db must have NO 0.0.0.0:3306->):"
docker ps --format 'table {{.Names}}\t{{.Ports}}'
echo ""
echo "Trying to reach MySQL from the host on port 3306:"
curl -sS --max-time 3 http://localhost:3306
CODE=$?
if [ $CODE -eq 7 ]; then
  echo "--> RESULT: Connection refused. DB port is NOT exposed to the host."
else
  echo "--> WARNING: host could reach port 3306 (curl exit code $CODE)."
fi
echo ""
echo "Now from INSIDE retail-net (Flask container to mysql-db):"
docker exec $APP python -c "import socket; socket.create_connection(('mysql-db', 3306), 3); print('--> RESULT: OPEN. Flask reaches mysql-db:3306 on the internal network.')"
echo ""

# ---------- DEMO 5 ----------
line
echo "DEMO 5: Resource monitoring (Task 7)"
line
docker stats --no-stream
echo ""
echo "Monitoring containers (if running):"
docker ps --filter name=prometheus --filter name=grafana --filter name=cadvisor --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo ""
echo "Metrics endpoint sample from Flask:"
curl -s --max-time 5 http://localhost:5000/metrics | head -n 8
echo "(Grafana dashboard: show it in the browser at http://localhost:3000)"
echo ""

# ---------- DEMO 6 ----------
line
echo "DEMO 6: Fault diagnosis and recovery (Task 8)"
line
echo "1. Stopping Redis on purpose..."
docker stop redis-cache
docker ps -a --filter name=redis-cache --format 'table {{.Names}}\t{{.Status}}'
echo ""
echo "2. Calling Flask while Redis is down:"
curl -s --max-time 15 http://localhost:5000/stats
echo -e "\n"
echo "3. Checking Flask logs:"
docker logs --tail 4 $APP
echo ""
echo "4. Restoring Redis..."
docker start redis-cache
sleep 3
echo "5. Calling Flask after recovery:"
curl -s --max-time 10 http://localhost:5000/stats
echo -e "\n"
curl -s --max-time 10 http://localhost:5000/stats
echo -e "\n"
echo "System recovered."
