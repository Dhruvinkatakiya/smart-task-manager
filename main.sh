#!/bin/bash

# Smart Task Manager - Complete Full-Stack Startup Script
# This script starts all services including the new React frontend

echo "🚀 Starting Smart Task Manager Full-Stack Application..."
echo "=================================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Minikube is running
echo -e "${BLUE}1. Checking Minikube status...${NC}"
if ! minikube status | grep -q "Running"; then
    echo -e "${YELLOW}Starting Minikube...${NC}"
    minikube start
else
    echo -e "${GREEN}✓ Minikube is running${NC}"
fi

# Check all pods are running
echo -e "\n${BLUE}2. Checking pod status...${NC}"
kubectl get pods

# Kill any existing port forwards
echo -e "\n${BLUE}3. Cleaning up existing port forwards...${NC}"
pkill -f "kubectl port-forward"
pkill -f "nginx"

# Wait a moment for cleanup
sleep 2

# Start port forwards in background
echo -e "\n${BLUE}4. Starting port forwards...${NC}"

# Auth Service
kubectl port-forward svc/auth-service 8000:80 > /dev/null 2>&1 &
echo -e "${GREEN}✓ Auth Service: localhost:8000${NC}"

# Task Service
kubectl port-forward svc/task-service 5001:80 > /dev/null 2>&1 &
echo -e "${GREEN}✓ Task Service: localhost:5001${NC}"

# Board Service
kubectl port-forward svc/board-service 8002:80 > /dev/null 2>&1 &
echo -e "${GREEN}✓ Board Service: localhost:8002${NC}"

# MongoDB
kubectl port-forward svc/mongo 27018:27017 > /dev/null 2>&1 &
echo -e "${GREEN}✓ MongoDB: localhost:27018${NC}"

# Frontend Service (from Kubernetes)
kubectl port-forward svc/frontend-service 3000:3000 > /dev/null 2>&1 &
echo -e "${GREEN}✓ Frontend: localhost:3000${NC}"

# Wait for port forwards to establish
echo -e "\n${BLUE}5. Waiting for services to be ready...${NC}"
sleep 5

# Start Nginx proxy
echo -e "\n${BLUE}6. Starting Nginx reverse proxy...${NC}"
nginx -c $(pwd)/nginx-proxy.conf > /dev/null 2>&1 &
echo -e "${GREEN}✓ Nginx running on port 9090${NC}"

# Summary
echo -e "\n${GREEN}=================================================="
echo -e "✅ All services are running!"
echo -e "==================================================${NC}"
echo -e "\n📌 ${BLUE}Access Points:${NC}"
echo -e "   🌐 Main Application: ${YELLOW}http://localhost:9090${NC}"
echo -e "   🎨 Frontend (Direct): http://localhost:3000"
echo -e "   🔐 Auth API: http://localhost:8000"
echo -e "   📝 Task API: http://localhost:5001"
echo -e "   📋 Board API: http://localhost:8002"
echo -e "   🗄️  MongoDB: mongodb://localhost:27018"
echo -e "\n📊 ${BLUE}Kubernetes Status:${NC}"
kubectl get pods
echo -e "\n${YELLOW}Tip: Use 'kubectl get pods' to check pod status${NC}"
echo -e "${YELLOW}Tip: Use 'kubectl logs <pod-name>' to view logs${NC}"
echo -e "\n${GREEN}Happy coding! 🎉${NC}\n"
