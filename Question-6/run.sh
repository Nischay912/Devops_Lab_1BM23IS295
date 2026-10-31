#!/bin/bash
set -e

echo "=========================================================="
echo "🚀 Setting up Question 6: Retail Analytics Multi-Container Stack"
echo "=========================================================="

echo "[1/6] Cleaning up old containers and network..."
docker rm -f mysql-db redis-cache retail-app prometheus grafana cadvisor 2>/dev/null || true
docker network rm retail-net 2>/dev/null || true

echo "[2/6] Loading AppArmor Profile into Linux Kernel..."
sudo cp my-apparmor-profile /etc/apparmor.d/my-apparmor-profile
sudo apparmor_parser -r -W /etc/apparmor.d/my-apparmor-profile
sudo aa-status | grep my-apparmor-profile && echo "✅ AppArmor Profile Active!"

echo "[3/6] Creating Custom Isolated Bridge Network..."
docker network create retail-net
echo "✅ Network 'retail-net' created."

echo "[4/6] Building Flask Container Image..."
docker build -t retail-app .
echo "✅ Image 'retail-app' built."

echo "[5/6] Launching Containers on 'retail-net'..."
# 1. MySQL (No published port to host - internal isolation)
docker run -d --name mysql-db --network retail-net \
  -e MYSQL_ROOT_PASSWORD=retailpassword \
  -e MYSQL_DATABASE=retail_db \
  mysql:5.7

# 2. Redis (No published port to host - internal isolation)
docker run -d --name redis-cache --network retail-net \
  redis:alpine

# 3. Flask Retail App (Exposes 5000 to host, secured with AppArmor)
docker run -d --name retail-app --network retail-net -p 5000:5000 \
  --security-opt="apparmor=my-apparmor-profile" \
  retail-app

# 4. Prometheus (Port 9090)
docker run -d --name prometheus -p 9090:9090 --network retail-net \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# 5. Grafana (Port 3000)
docker run -d --name grafana -p 3000:3000 --network retail-net \
  grafana/grafana

# 6. cAdvisor (Port 8080 - Container Metrics Collector)
docker run -d --name cadvisor --network retail-net --privileged \
  -p 8080:8080 \
  -v /:/rootfs:ro -v /var/run:/var/run:ro -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  gcr.io/cadvisor/cadvisor:v0.49.1

echo "=========================================================="
echo "⏳ Waiting 15 seconds for MySQL & Flask initialization..."
echo "=========================================================="
sleep 15

echo "✅ All containers running successfully:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=========================================================="
echo "🎉 Setup Complete! Now run: bash demo.sh"
echo "=========================================================="
