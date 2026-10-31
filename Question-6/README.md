# Question 6 — Retail Analytics Stack with Isolated Containers

## Overview
A secure, monitored multi-container retail analytics architecture composed of:
- **Flask REST Service (`retail-app`)**: Serves sales statistics at `/stats` and Prometheus metrics at `/metrics`.
- **MySQL Database (`mysql-db`)**: Persistent storage of retail sales records.
- **Redis In-Memory Cache (`redis-cache`)**: High-speed caching layer for `/stats` queries.
- **AppArmor Security Profile**: Restricts container operations (blocks access to `/etc/passwd` and `/bin/bash`).
- **Prometheus & Grafana**: Collects real-time container metrics and displays operational performance.
- **Custom Docker Bridge Network (`retail-net`)**: Fully isolated internal communication without exposing database ports to the host.

## Quick Execution
```bash
# 1. Run the complete setup
bash run.sh

# 2. Run the automated demonstration
bash demo.sh
```

## Task Demonstrations
1. **Multi-Container Networking & Caching**: First request fetches from MySQL and writes to cache. Second request returns instantly from Redis (`source: redis_cache`).
2. **AppArmor Confinement**: `docker exec retail-app cat /etc/passwd` returns `Permission denied` (Exit code 1).
3. **Database Port Isolation**: Port 3306 is not published to the host (`curl localhost:3306` fails). Containers resolve `mysql-db:3306` securely over internal Docker DNS.
4. **Monitoring**: Live metrics visible via `docker stats --no-stream`, `http://localhost:9090` (Prometheus), and `http://localhost:3000` (Grafana).
5. **Fault Diagnosis & Recovery**: Stopping `redis-cache` demonstrates graceful degradation and log diagnostics; restarting `redis-cache` restores caching instantly.
