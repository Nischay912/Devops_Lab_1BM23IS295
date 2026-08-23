# Exercise 1 — Hello Pod

Deployed nginx as a Pod on a local Kubernetes cluster using Minikube.

## What I did
- Started Minikube cluster
- Created a Pod using the nginx image via a YAML manifest
- Exposed it as a NodePort service
- Accessed the app in the browser using `minikube service`

## Files
- `hello-k8s.yaml` — Pod manifest

## Key Concepts
- **Pod** — smallest unit in Kubernetes, runs a container
- **kubectl** — CLI to manage the Kubernetes cluster
- **NodePort** — exposes the Pod on a port outside the cluster
- **Minikube** — runs a local single-node Kubernetes cluster

## Output

Minikube cluster started:

![minikube start](./screenshots/01-minikube-start.png)

Pod created and running:

![kubectl apply and get pods](./screenshots/02-kubectl-apply-get-pods.png)

Service exposed:

![service exposed](./screenshots/03-service-exposed.png)

Minikube tunnel to browser:

![minikube service](./screenshots/04-minikube-service-tunnel.png)

Nginx welcome page in browser:

![nginx welcome page](./screenshots/05-nginx-welcome-page.png)
