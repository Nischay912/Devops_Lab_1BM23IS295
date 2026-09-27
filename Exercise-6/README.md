# Exercise 6: Real-Time Operations Monitoring and Alerting

## Objective
Create a monitoring application to provide real-time insights on the performance of a delivery service using Python, Prometheus, Grafana, and Jenkins CI/CD.

## Architecture
1. **Python App**: A simulation script (`delivery_metrics.py`) using `prometheus_client` to expose delivery metrics (Total, Pending, On-the-way, Average Time).
2. **Prometheus**: Scrapes the metrics from the Python app and evaluates alerts (`HighPendingDeliveries`, `HighAverageDeliveryTime`).
3. **Grafana**: Connects to Prometheus as a Data Source to visualize the metrics on a 4-panel dashboard.
4. **Jenkins**: A CI/CD pipeline (`Jenkinsfile`) that pulls from GitHub, builds the Docker image for the Python app, and spins up the App, Prometheus, and Grafana containers automatically.

## Files Created
- `delivery_metrics.py`: The Python simulation application.
- `Dockerfile`: Containerizes the Python application.
- `prometheus.yml`: Configuration for Prometheus to scrape the app.
- `alert_rules.yml`: Defines the warning and critical threshold alerts.
- `Jenkinsfile`: The automated Jenkins Pipeline script.

## Challenges Overcome
During the Jenkins pipeline execution, we overcame classic "Docker-in-Docker" (DooD) challenges:
1. **Jenkins missing Docker CLI**: Solved by mounting `/var/run/docker.sock` and installing `docker.io` inside the Jenkins container as the root user.
2. **Volume Mounting inside DooD**: Solved by modifying the `Jenkinsfile` to use `docker cp` instead of `-v` volume mounts to inject the Prometheus configuration files directly into the running Prometheus container.

## Screenshots
All screenshots of the step-by-step process, including the Grafana dashboard creation and the successful Jenkins pipeline run, are neatly organized in the `screenshots/` directory.
