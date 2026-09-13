# Exercise 4 — Docker Networking with Multiple Containers

Set up a multi-container application using Docker bridge networking, connecting a Flask web server, MySQL database, and Redis cache on the same custom network.

## What I did
- Created a custom Docker bridge network
- Built a Flask REST API container
- Launched MySQL and Redis containers on the same network
- Tested inter-container connectivity using `ping` from within the Flask container
- Cleaned up all containers and the network

## Files
- `app.py` — Flask REST API
- `requirements.txt` — Python dependencies
- `Dockerfile` — Docker image definition for Flask app

## Key Concepts
- **Bridge Network** — a private internal network Docker creates so containers can talk to each other by name
- **`--net` flag** — connects a container to a specific network at launch
- **`-p` flag** — maps a container port to a host port so the app is accessible from outside
- **`-d` flag** — detached mode, runs container in the background
- **DNS resolution** — on a custom bridge network, containers can reach each other using their container names (e.g. `ping mysql` works)

## Output

Bridge network created and listed:

![network create and ls](./screenshots/01-network-create-ls.png)

Network inspected:

![network inspect](./screenshots/02-network-inspect.png)

Flask image built:

![docker build](./screenshots/03-docker-build.png)

MySQL container launched:

![docker run mysql](./screenshots/04-docker-run-mysql.png)

Redis container launched:

![docker run redis](./screenshots/05-docker-run-redis.png)

Flask image rebuilt with Werkzeug fix:

![docker rebuild fixed](./screenshots/06-docker-rebuild-fixed.png)

Flask container launched after fix:

![docker run flask fixed](./screenshots/07-docker-run-flask-fixed.png)

All 3 containers running:

![all containers running](./screenshots/08-all-containers-running.png)

Exec into Flask container:

![docker exec flask](./screenshots/09-docker-exec-flask.png)

Ping MySQL from Flask container — success:

![ping mysql](./screenshots/10-ping-mysql.png)

Ping Redis from Flask container — success:

![ping redis](./screenshots/11-ping-redis.png)

Cleanup — containers stopped, removed, network deleted:

![cleanup](./screenshots/12-cleanup.png)
