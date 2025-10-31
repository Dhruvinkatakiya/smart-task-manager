#!/usr/bin/env bash
set -euo pipefail

# start-all.sh
# Full-stack startup script for Smart Task Manager
# - cleans common ports / port-forwards
# - (optionally) recreates minikube
# - builds Docker images and loads them into minikube
# - deploys infrastructure via Terraform (auto-approve optional)
# - applies Kubernetes manifests for frontend
# - patches ingress to LoadBalancer and attempts to start minikube tunnel
# - starts nginx proxy for local access
# Usage: ./scripts/start-all.sh [--fresh] [--yes] [--skip-build] [--no-tunnel]

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKIP_BUILD=false
FRESH=false
ASSUME_YES=false
NO_TUNNEL=false

usage() {
  cat <<EOF
Usage: $0 [--fresh] [--yes] [--skip-build] [--no-tunnel]

Options:
  --fresh       Delete and recreate minikube cluster before deployment (destructive)
  --yes         Non-interactive: auto-confirm prompts, auto-approve terraform
  --skip-build  Skip building Docker images (assume images are already available)
  --no-tunnel   Do not attempt to start 'minikube tunnel'
EOF
  exit 1
}

while [[ ${#} -gt 0 ]]; do
  case $1 in
    --fresh) FRESH=true; shift ;;
    --yes) ASSUME_YES=true; shift ;;
    --skip-build) SKIP_BUILD=true; shift ;;
    --no-tunnel) NO_TUNNEL=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

ask() {
  if [ "$ASSUME_YES" = true ]; then
    return 0
  fi
  read -r -p "$1 [y/N]: " response
  case "$response" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}

echo "\n=== Smart Task Manager - Start All ==="
echo "Repo: $REPO_ROOT"\n
# 1) Basic checks
echo "Checking prerequisites..."
for cmd in docker kubectl minikube terraform lsof; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: '$cmd' not found in PATH. Install it before running this script." >&2
    exit 2
  fi
done

# 2) Optionally recreate minikube
if [ "$FRESH" = true ]; then
  if ask "This will delete your Minikube cluster and recreate it. Continue?"; then
    echo "Deleting minikube..."
    minikube delete || true
    echo "Starting minikube..."
    minikube start --driver=docker
  else
    echo "Skipping fresh minikube recreation.";
  fi
else
  if ! minikube status | grep -q "Running"; then
    echo "Minikube not running — starting it now"
    minikube start --driver=docker
  else
    echo "Minikube is already running"
  fi
fi

echo "Enabling ingress addon (if not enabled)"
minikube addons enable ingress || true

# 3) Clean common ports and stray processes
echo "Cleaning ports and existing helpers..."
PORTS=(3000 9090 8000 8001 8002 5001 27017 27018)
for p in "${PORTS[@]}"; do
  pids=$(lsof -ti tcp:"$p" || true)
  if [ -n "$pids" ]; then
    echo "Killing processes on port $p: $pids"
    kill -9 $pids || true
  fi
done

echo "Stopping background port-forwards and nginx if any"
pkill -f "kubectl port-forward" || true
pkill -f nginx || true
sleep 2

# 4) Build Docker images (optional)
if [ "$SKIP_BUILD" = false ]; then
  echo "Building Docker images..."
  (cd "$REPO_ROOT/auth-service" && docker build -t auth-service:latest .)
  (cd "$REPO_ROOT/task-service" && docker build -t task-service:latest .)
  (cd "$REPO_ROOT/board-service" && docker build -t board-service:latest .)
  (cd "$REPO_ROOT/frontend" && docker build -t frontend:latest .)
else
  echo "Skipping Docker image builds (--skip-build set)"
fi

# 5) Load images into minikube
echo "Loading images into Minikube"
minikube image load auth-service:latest || true
minikube image load task-service:latest || true
minikube image load board-service:latest || true
minikube image load frontend:latest || true

# 6) Deploy infrastructure via Terraform
echo "Deploying infrastructure with Terraform"
cd "$REPO_ROOT/infra/terraform"
terraform init -input=false
if [ "$ASSUME_YES" = true ]; then
  terraform apply -auto-approve
else
  if ask "Apply Terraform changes now?"; then
    terraform apply
  else
    echo "Skipping terraform apply — you can run it manually in infra/terraform";
  fi
fi

cd "$REPO_ROOT"

# 7) Apply frontend manifests (frontend is not managed by Terraform in this repo)
echo "Applying frontend manifests (kubectl)"
kubectl apply -f k8s/frontend-deployment.yaml || true
kubectl apply -f k8s/frontend-service.yaml || true

# 8) Patch ingress to LoadBalancer and start tunnel (if desired)
echo "Patching ingress controller to LoadBalancer (if present)"
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec":{"type":"LoadBalancer"}}' || true
if [ "$NO_TUNNEL" = false ]; then
  echo "Attempting to start 'minikube tunnel' in background — this may require sudo and will run until killed"
  (minikube tunnel > /tmp/minikube_tunnel.log 2>&1 &) || true
  echo "Minikube tunnel started (logs: /tmp/minikube_tunnel.log)"
else
  echo "Skipping minikube tunnel (--no-tunnel set)"
fi

# 9) Port-forward common services for direct local access
echo "Starting kubectl port-forwards for local convenience"
kubectl port-forward svc/frontend-service 3000:3000 > /dev/null 2>&1 & || true
kubectl port-forward svc/auth-service 8000:80 > /dev/null 2>&1 & || true
kubectl port-forward svc/task-service 5001:80 > /dev/null 2>&1 & || true
kubectl port-forward svc/board-service 8002:80 > /dev/null 2>&1 & || true
kubectl port-forward svc/mongo 27018:27017 > /dev/null 2>&1 & || true

sleep 3

# 10) Start nginx proxy for local aggregator (optional)
if [ -f "$REPO_ROOT/nginx-proxy.conf" ]; then
  echo "Starting nginx proxy using nginx-proxy.conf"
  nginx -c "$REPO_ROOT/nginx-proxy.conf" || true
fi

echo "\n=== Summary ==="
echo "Frontend: http://localhost:3000 (or via ingress)"
echo "Main proxy (if nginx started): http://localhost:9090"
echo "Public NGROK URL: run ./scripts/start-ngrok.sh (optional)"
echo "\nKubernetes pods status:"
kubectl get pods -n default || true

echo "\nDone. If something failed, check pod logs (kubectl logs) and the minikube tunnel log: /tmp/minikube_tunnel.log"
