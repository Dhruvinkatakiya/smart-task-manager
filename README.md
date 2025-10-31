# 🚀 Smart Task Manager

[![React](https://img.shields.io/badge/React-18.2.0-61DAFB?logo=react&logoColor=black)](https://reactjs.org/)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-6.0-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)

A modern task management application built with microservices architecture, featuring real-time updates, team collaboration, and a responsive interface.

[Documentation](#-documentation) • [Quick Start](#-quick-start)

---

## 📋 Table of Contents

- [Features](#-features)
- [System Architecture](#️-system-architecture)
- [Technology Stack](#️-technology-stack)
- [Quick Start](#-quick-start)
- [API Documentation](#-api-documentation)
- [Development](#-development)
- [Deployment](#-deployment)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Security](#-security)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🎨 Frontend

- **Modern React UI** with professional blue-teal gradient theme
- **Responsive Dashboard** with real-time task and board statistics
- **Kanban Board** with drag-and-drop task management across three states (To Do, In Progress, Done)
- **Board Management** with member collaboration features
- **JWT Authentication** with secure login/register flows
- **Professional Design** with glassmorphism effects and smooth animations

### ⚙️ Backend Microservices

- **Auth Service** (Port 8000) - JWT-based authentication and user management
- **Task Service** (Port 5001) - Complete CRUD operations for task management
- **Board Service** (Port 8002) - Board creation, management, and member permissions
- **MongoDB** (Port 27017) - Persistent data storage with optimized queries

### 🔧 DevOps & Infrastructure

- **Docker** - Multi-stage optimized container images
- **Kubernetes** - Production-ready orchestration with Minikube
- **Terraform** - Complete Infrastructure as Code (IaC)
- **GitHub Actions** - Automated CI/CD pipeline with testing and deployment
- **Nginx Ingress** - Intelligent routing and load balancing
- **Ngrok** - Public URL tunneling for demo and testing
- **Trivy & CodeQL** - Automated security vulnerability scanning

---

## 🏗️ Application Architecture

### Complete System Architecture Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           � EXTERNAL ACCESS LAYER                           │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    Ngrok Public Tunnel (HTTPS)                         │ │
│  │          https://ulrike-comfier-precontemporaneously.ngrok-free.dev    │ │
│  └──────────────────────────────────┬─────────────────────────────────────┘ │
└─────────────────────────────────────┼───────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    � KUBERNETES CLUSTER ENTRY POINT                         │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                   Minikube Tunnel (LoadBalancer)                       │ │
│  │                      Exposes Ingress Controller                        │ │
│  └──────────────────────────────────┬─────────────────────────────────────┘ │
└─────────────────────────────────────┼───────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                       🔀 INGRESS ROUTING LAYER                               │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │               Nginx Ingress Controller (Port 80/443)                   │ │
│  │                                                                        │ │
│  │  Routing Rules:                                                        │ │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │ │
│  │  │  Path: /               → frontend-service:3000                  │  │ │
│  │  │  Path: /api/auth/*     → auth-service:80                        │  │ │
│  │  │  Path: /api/tasks/*    → task-service:80                        │  │ │
│  │  │  Path: /api/boards/*   → board-service:80                       │  │ │
│  │  └─────────────────────────────────────────────────────────────────┘  │ │
│  └───┬──────────────────┬──────────────────┬──────────────────┬──────────┘ │
└──────┼──────────────────┼──────────────────┼──────────────────┼────────────┘
       │                  │                  │                  │
       ▼                  ▼                  ▼                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    ☸️  KUBERNETES SERVICES (ClusterIP)                       │
│                                                                              │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌─────────────┐  │
│  │  frontend    │   │     auth     │   │     task     │   │    board    │  │
│  │  -service    │   │   -service   │   │   -service   │   │  -service   │  │
│  │              │   │              │   │              │   │             │  │
│  │  Port: 3000  │   │   Port: 80   │   │   Port: 80   │   │  Port: 80   │  │
│  │  Target:3000 │   │  Target:8000 │   │  Target:5001 │   │ Target:8002 │  │
│  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘   └──────┬──────┘  │
└─────────┼──────────────────┼──────────────────┼──────────────────┼─────────┘
          │                  │                  │                  │
          ▼                  ▼                  ▼                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                       🐳 PODS & CONTAINERS LAYER                             │
│                                                                              │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌─────────────┐  │
│  │  Frontend    │   │  Auth-Service│   │ Task-Service │   │Board-Service│  │
│  │    Pod       │   │     Pod      │   │     Pod      │   │    Pod      │  │
│  │              │   │              │   │              │   │             │  │
│  │ ┌──────────┐ │   │ ┌──────────┐ │   │ ┌──────────┐ │   │ ┌─────────┐ │  │
│  │ │  React   │ │   │ │  Node.js │ │   │ │  Node.js │ │   │ │ Node.js │ │  │
│  │ │   App    │ │   │ │  Express │ │   │ │  Express │ │   │ │ Express │ │  │
│  │ │    +     │ │   │ │  Server  │ │   │ │  Server  │ │   │ │ Server  │ │  │
│  │ │  Nginx   │ │   │ │    +     │ │   │ │    +     │ │   │ │    +    │ │  │
│  │ │  Server  │ │   │ │ Mongoose │ │   │ │ Mongoose │ │   │ │Mongoose │ │  │
│  │ └──────────┘ │   │ │   ODM    │ │   │ │   ODM    │ │   │ │   ODM   │ │  │
│  │              │   │ └─────┬────┘ │   │ └─────┬────┘ │   │ └────┬────┘ │  │
│  │ Health:      │   │       │      │   │       │      │   │      │      │  │
│  │ ✓ Ready      │   │       │      │   │       │      │   │      │      │  │
│  │ ✓ Live       │   │       │      │   │       │      │   │      │      │  │
│  │              │   │ Health:      │   │ Health:      │   │ Health:     │  │
│  │ Resources:   │   │ ✓ Ready      │   │ ✓ Ready      │   │ ✓ Ready     │  │
│  │ CPU: 100m    │   │ ✓ Live       │   │ ✓ Live       │   │ ✓ Live      │  │
│  │ Mem: 128Mi   │   │              │   │              │   │             │  │
│  └──────────────┘   │ Resources:   │   │ Resources:   │   │ Resources:  │  │
│                     │ CPU: 200m    │   │ CPU: 200m    │   │ CPU: 200m   │  │
│                     │ Mem: 256Mi   │   │ Mem: 256Mi   │   │ Mem: 256Mi  │  │
│                     └──────┬───────┘   └──────┬───────┘   └──────┬──────┘  │
└────────────────────────────┼──────────────────┼──────────────────┼─────────┘
                             │                  │                  │
                             └──────────┬───────┴──────────────────┘
                                        │
                                        ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                  💾 DATA PERSISTENCE LAYER                                   │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    MongoDB Service (ClusterIP)                         │ │
│  │                         Port: 27017                                    │ │
│  └──────────────────────────────────┬─────────────────────────────────────┘ │
│                                     │                                        │
│                                     ▼                                        │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                        MongoDB Pod                                     │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │ │
│  │  │                 MongoDB 6.0 Container                            │ │ │
│  │  │                                                                  │ │ │
│  │  │  Database: smart_task_manager                                    │ │ │
│  │  │                                                                  │ │ │
│  │  │  Collections:                                                    │ │ │
│  │  │  ├─ users       - Authentication & User Profiles                │ │ │
│  │  │  ├─ tasks       - Task Items (title, desc, status, board)       │ │ │
│  │  │  └─ boards      - Board Management & Member Lists               │ │ │
│  │  │                                                                  │ │ │
│  │  │  Resources: CPU 250m | Memory 512Mi                              │ │ │
│  │  └──────────────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                  🔐 CONFIGURATION & SECRETS MANAGEMENT                       │
│                                                                              │
│  ┌──────────────────────────────┐     ┌─────────────────────────────────┐   │
│  │      ConfigMap               │     │    Kubernetes Secrets           │   │
│  │    (mongo-config)            │     │    (smart-secrets)              │   │
│  │                              │     │                                 │   │
│  │  • MONGO_URI                 │     │  • JWT_SECRET (base64)          │   │
│  │    mongodb://mongo:27017/... │     │    Used by all services         │   │
│  └──────────────────────────────┘     └─────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                       📦 INFRASTRUCTURE AS CODE (IaC)                        │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                        Terraform Configuration                         │ │
│  │                                                                        │ │
│  │  Manages:                                                              │ │
│  │  ├─ ConfigMaps (mongo-config)                                         │ │
│  │  ├─ Secrets (smart-secrets)                                           │ │
│  │  ├─ Deployments (auth, task, board, mongo)                            │ │
│  │  ├─ Services (ClusterIP for all services)                             │ │
│  │  └─ Ingress (routing rules)                                           │ │
│  │                                                                        │ │
│  │  Location: infra/terraform/                                           │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                     🔄 CI/CD AUTOMATION PIPELINE                             │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                      GitHub Actions Workflow                           │ │
│  │                                                                        │ │
│  │  Stage 1: Code Quality & Security                                     │ │
│  │  ├─ npm test (all services)                                           │ │
│  │  ├─ Trivy filesystem scan                                             │ │
│  │  ├─ Secret scanning                                                   │ │
│  │  └─ SARIF upload to GitHub Security                                   │ │
│  │                                                                        │ │
│  │  Stage 2: Build & Push                                                │ │
│  │  ├─ Docker build (multi-stage)                                        │ │
│  │  ├─ Trivy image scan                                                  │ │
│  │  ├─ Push to Docker Hub (on main)                                      │ │
│  │  └─ Save artifacts                                                    │ │
│  │                                                                        │ │
│  │  Stage 3: Infrastructure Validation                                   │ │
│  │  ├─ Terraform validate                                                │ │
│  │  ├─ Terraform plan (dry-run)                                          │ │
│  │  └─ Kubernetes manifest validation                                    │ │
│  │                                                                        │ │
│  │  Location: .github/workflows/ci-cd.yml                                │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Request Flow Visualization

```
┌─────────┐
│  User   │  1. Opens browser: https://ulrike-comfier...ngrok-free.dev
└────┬────┘
     │
     ▼
┌─────────────────────┐
│  Ngrok Tunnel       │  2. Secure HTTPS tunnel to localhost
│  (Public Gateway)   │
└────┬────────────────┘
     │
     ▼
┌─────────────────────┐
│ Minikube Tunnel     │  3. LoadBalancer exposes Ingress
│ (Cluster Gateway)   │
└────┬────────────────┘
     │
     ▼
┌─────────────────────────────────────┐
│  Nginx Ingress Controller           │  4. Route based on path:
│                                     │     / → Frontend
│  Routing Logic:                     │     /api/auth/* → Auth
│  • Check request path               │     /api/tasks/* → Task
│  • Match to service                 │     /api/boards/* → Board
│  • Forward to ClusterIP             │
└────┬───────┬────────┬───────┬───────┘
     │       │        │       │
     ▼       ▼        ▼       ▼
   ┌───┐  ┌────┐  ┌────┐  ┌─────┐
   │UI │  │Auth│  │Task│  │Board│     5. Service DNS resolution
   └─┬─┘  └──┬─┘  └──┬─┘  └──┬──┘        (Kubernetes internal)
     │       │       │       │
     ▼       ▼       ▼       ▼
   ┌───────────────────────────┐
   │    Pod Containers         │      6. Process request in
   │  (Express.js servers)     │         Node.js/Express
   └───────┬───────────────────┘
           │
           ▼
   ┌───────────────┐
   │   MongoDB     │                  7. Data operations
   │  (Database)   │                     (CRUD via Mongoose)
   └───────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) - For containerization
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) - Local Kubernetes cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI
- [Terraform](https://www.terraform.io/downloads) - Infrastructure as Code
- [Node.js 18+](https://nodejs.org/) - For local development (optional)
- [ngrok](https://ngrok.com/) - For public URL access (optional)

### Option 1: Terraform Deployment (Recommended) ⭐

```bash
# 1. Clone the repository
git clone https://github.com/Dhruvinkatakiya/smart-task-manager.git
cd smart-task-manager

# 2. Start Minikube cluster
minikube start --driver=docker
minikube addons enable ingress

# 3. Build Docker images for all services
docker build -t auth-service:latest ./auth-service
docker build -t task-service:latest ./task-service
docker build -t board-service:latest ./board-service
docker build -t frontend:latest ./frontend

# 4. Load images into Minikube
minikube image load auth-service:latest
minikube image load task-service:latest
minikube image load board-service:latest
minikube image load frontend:latest

# 5. Deploy infrastructure using Terraform
cd infra/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ../..

# 6. Deploy frontend (not managed by Terraform)
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# 7. Verify all pods are running
kubectl get pods -n default

# 8. Access the application
# Start port-forward for frontend:
kubectl port-forward -n default svc/frontend-service 3000:3000

# Open browser: http://localhost:3000
```

### Option 2: Kubernetes Manifests Deployment

```bash
# 1-4. Same as Option 1 (clone, start minikube, build & load images)

# 5. Apply all Kubernetes manifests
kubectl apply -f k8s/mongo-config.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/mongo-deployment.yaml
kubectl apply -f k8s/mongo-service.yaml
kubectl apply -f k8s/auth-deployment.yaml
kubectl apply -f k8s/auth-service.yaml
kubectl apply -f k8s/task-deployment.yaml
kubectl apply -f k8s/task-service.yaml
kubectl apply -f k8s/board-deployment.yaml
kubectl apply -f k8s/board-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml

# 6. Verify deployments
kubectl get pods -n default
kubectl get svc -n default

# 7. Access the application
kubectl port-forward -n default svc/frontend-service 3000:3000
# Open browser: http://localhost:3000
```

### Option 3: Docker Compose (Development)

```bash
# 1. Clone repository
git clone https://github.com/PujanMevawala/smart-task-manager.git
cd smart-task-manager

# 2. Start all services
docker-compose up -d

# 3. Access the application
# Frontend: http://localhost:3000
# Nginx Proxy: http://localhost:9090
# Auth API: http://localhost:8000
# Task API: http://localhost:5001
# Board API: http://localhost:8002
```

### Accessing via Public URL (Ngrok)

```bash
# Start ngrok tunnel (in a separate terminal)
ngrok http 3000

# Or use the provided script:
chmod +x scripts/start-ngrok.sh
./scripts/start-ngrok.sh

# Copy the generated HTTPS URL
# Example: https://your-unique-id.ngrok-free.app
```

---

## 🌐 API Documentation

### Base URLs

- **Local Development**: `http://localhost:9090`
- **Local K8s (Port-forward)**: `http://localhost:3000`
- **Public**: `https://ulrike-comfier-precontemporaneously.ngrok-free.dev`

### API Endpoints

All API endpoints require JWT authentication (except register/login).

**Authentication:**

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user

**Tasks:**

- `GET /api/tasks` - Get all tasks
- `POST /api/tasks` - Create task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task

**Boards:**

- `GET /api/boards` - Get all boards
- `POST /api/boards` - Create board
- `POST /api/boards/:boardId/members` - Add member to board

---

## 💻 Development

### Project Structure

```
smart-task-manager/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── frontend/                      # React frontend application
│   ├── public/
│   ├── src/
│   │   ├── components/            # React components
│   │   │   ├── Auth.css
│   │   │   ├── Boards.js
│   │   │   ├── Dashboard.js
│   │   │   ├── Header.js
│   │   │   ├── Login.js
│   │   │   ├── Register.js
│   │   │   ├── Tasks.js
│   │   │   └── PrivateRoute.js
│   │   ├── context/
│   │   │   └── AuthContext.js     # Authentication context
│   │   ├── services/
│   │   │   ├── api.js             # API client setup
│   │   │   ├── authService.js     # Auth API calls
│   │   │   └── taskService.js     # Task API calls
│   │   ├── App.js
│   │   └── index.js
│   ├── Dockerfile                 # Multi-stage build
│   ├── nginx.conf                 # Nginx configuration
│   └── package.json
├── auth-service/                  # Authentication microservice
│   ├── src/
│   │   ├── config/
│   │   │   └── db.js              # MongoDB connection
│   │   ├── controllers/
│   │   │   └── authController.js  # Auth business logic
│   │   ├── middleware/
│   │   │   └── authMiddleware.js  # JWT verification
│   │   ├── models/
│   │   │   └── User.js            # User schema
│   │   ├── routes/
│   │   │   └── authRoutes.js      # API routes
│   │   └── server.js              # Express app entry
│   ├── Dockerfile
│   └── package.json
├── task-service/                  # Task management microservice
│   ├── src/
│   │   ├── controllers/
│   │   │   └── taskController.js
│   │   ├── models/
│   │   │   ├── Task.js
│   │   │   └── Board.js
│   │   ├── routes/
│   │   │   └── taskRoutes.js
│   │   └── server.js
│   ├── Dockerfile
│   └── package.json
├── board-service/                 # Board management microservice
│   ├── src/
│   │   ├── controllers/
│   │   │   └── boardController.js
│   │   ├── models/
│   │   │   ├── Board.js
│   │   │   └── User.js
│   │   ├── routes/
│   │   │   └── boardRoutes.js
│   │   └── server.js
│   ├── Dockerfile
│   └── package.json
├── k8s/                           # Kubernetes manifests
│   ├── auth-deployment.yaml
│   ├── auth-service.yaml
│   ├── board-deployment.yaml
│   ├── board-service.yaml
│   ├── task-deployment.yaml
│   ├── task-service.yaml
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   ├── mongo-deployment.yaml
│   ├── mongo-service.yaml
│   ├── mongo-config.yaml          # ConfigMap for MongoDB URI
│   ├── secrets.yaml               # Secrets for JWT
│   └── ingress.yaml               # Ingress routing
├── infra/
│   └── terraform/                 # Infrastructure as Code
│       ├── main.tf                # Main Terraform config
│       ├── provider.tf            # Provider configuration
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output values
│       └── terraform.tfstate      # State file
├── scripts/                       # Utility scripts
│   ├── build-images.sh            # Build all Docker images
│   ├── deploy-terraform.sh        # Deploy with Terraform
│   ├── setup-ngrok.sh             # Setup ngrok
│   ├── start-ngrok.sh             # Start ngrok tunnel
│   └── test-endpoints.sh          # Test API endpoints
├── docker-compose.yml             # Docker Compose for local dev
├── nginx-proxy.conf               # Nginx reverse proxy config
├── README.md                      # This file
└── DEPLOYMENT_EVALUATION_REPORT.md # Deployment evaluation (20/20)
```

### Local Development Workflow

#### 1. Start MongoDB Locally

```bash
docker run -d -p 27017:27017 --name mongo mongo:6.0
```

#### 2. Run Services Individually

**Auth Service:**

```bash
cd auth-service
npm install
npm run dev  # Runs on port 8000
```

**Task Service:**

```bash
cd task-service
npm install
npm run dev  # Runs on port 5001
```

**Board Service:**

```bash
cd board-service
npm install
npm run dev  # Runs on port 8002
```

**Frontend:**

```bash
cd frontend
npm install
npm start    # Runs on port 3000
```

---

## 🚢 Deployment

Use the automated startup script for quick deployment:

```bash
# Make script executable
chmod +x scripts/start-all.sh

# Run full deployment (interactive)
./scripts/start-all.sh

# Or with options:
./scripts/start-all.sh --fresh --yes  # Fresh cluster, auto-approve
./scripts/start-all.sh --skip-build   # Skip rebuilding images
```

### Accessing the Application

#### Via Port-Forward

```bash
kubectl port-forward -n default svc/frontend-service 3000:3000
# Access: http://localhost:3000
```

#### Via Ingress (with Minikube Tunnel)

```bash
# In one terminal:
minikube tunnel

# In another terminal:
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec":{"type":"LoadBalancer"}}'

# Access: http://localhost
```

#### Via Ngrok (Public URL)

```bash
# Start port-forward first
kubectl port-forward -n default svc/frontend-service 3000:3000 &

# Start ngrok
ngrok http 3000

# Copy the HTTPS URL provided by ngrok
```

---

## 🔄 CI/CD Pipeline

The project uses GitHub Actions for automated CI/CD:

### Pipeline Stages

```
┌──────────────────────────────────────────────────────────┐
│          Stage 1: Code Quality & Security                │
├──────────────────────────────────────────────────────────┤
│ • Checkout code                                          │
│ • Setup Node.js 18                                       │
│ • Install dependencies (npm ci)                          │
│ • Run tests (npm test)                                   │
│ • Trivy vulnerability scan                               │
│ • CodeQL security analysis                               │
│ • Upload SARIF to GitHub Security                        │
└──────────────────────────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────┐
│          Stage 2: Build & Push Docker Images             │
├──────────────────────────────────────────────────────────┤
│ • Build auth-service:latest                              │
│ • Build task-service:latest                              │
│ • Build board-service:latest                             │
│ • Build frontend:v1.0                                    │
│ • Tag images with commit SHA                             │
│ • Push to Docker Hub (optional)                          │
└──────────────────────────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────┐
│          Stage 3: Deploy to Kubernetes                   │
├──────────────────────────────────────────────────────────┤
│ • Setup Minikube cluster                                 │
│ • Setup kubectl CLI                                      │
│ • Load Docker images to Minikube                         │
│ • Apply Kubernetes manifests                             │
│ • Verify deployment rollout status                       │
│ • Run health checks                                      │
└──────────────────────────────────────────────────────────┘
```

---

## 🔒 Security

### Security Features

- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **Password Hashing** - bcrypt with salt rounds
- ✅ **CORS Protection** - Configured cross-origin policies
- ✅ **Environment Variables** - No hardcoded secrets
- ✅ **Kubernetes Secrets** - Base64 encoded sensitive data
- ✅ **Container Scanning** - Trivy for vulnerabilities
- ✅ **Static Analysis** - CodeQL for code security
- ✅ **HTTPS Support** - Via ngrok and ingress TLS (optional)

### Security Scanning

#### Trivy (Container Vulnerabilities)

```bash
# Scan a Docker image
trivy image auth-service:latest

# Scan with SARIF output
trivy image --format sarif --output trivy-results.sarif auth-service:latest
```

#### CodeQL (Static Analysis)

Automatically runs on every push to main/develop branches via GitHub Actions.

### Secrets Management

**Kubernetes Secrets:**

```bash
# Create secret from literal values
kubectl create secret generic smart-secrets \
  --from-literal=JWT_SECRET=your-secret-key \
  --from-literal=MONGO_URI=mongodb://mongo:27017/taskmanager

# Or apply from YAML
kubectl apply -f k8s/secrets.yaml
```

**ConfigMaps:**

```bash
kubectl apply -f k8s/mongo-config.yaml
```

---

## 🧪 Testing

### Unit Tests

Each service has its own test suite:

```bash
# Auth Service
cd auth-service
npm test

# Task Service
cd task-service
npm test

# Board Service
cd board-service
npm test

# Frontend
cd frontend
npm test
```

### Integration Testing

Use the provided test script:

```bash
chmod +x scripts/test-endpoints.sh
./scripts/test-endpoints.sh
```

---

## 📊 Monitoring & Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n default
kubectl describe pod <pod-name> -n default
kubectl logs <pod-name> -n default
kubectl logs <pod-name> -n default --previous  # Previous crashed pod logs
```

### Check Services

```bash
kubectl get svc -n default
kubectl describe svc <service-name> -n default
```

### Check Ingress

```bash
kubectl get ingress -n default
kubectl describe ingress smart-ingress -n default
```

### Common Issues

**Issue: Pods in ImagePullBackOff**

```bash
# Solution: Load images into minikube
minikube image load auth-service:latest
minikube image load task-service:latest
minikube image load board-service:latest
```

**Issue: CrashLoopBackOff**

```bash
# Check pod logs
kubectl logs <pod-name> -n default

# Common causes:
# 1. MongoDB not ready - wait for mongo pod to be Running
# 2. Wrong environment variables - check secrets and configmaps
# 3. Port conflicts - ensure ports are not already in use
```

**Issue: Ingress not accessible**

```bash
# Ensure ingress addon is enabled
minikube addons enable ingress

# Check ingress controller
kubectl get pods -n ingress-nginx

# Start minikube tunnel
minikube tunnel
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [React Documentation](https://reactjs.org/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

<div align="center">

**Made with ❤️ by Dhruvin Katakiya**

[⭐ Star this repository](https://github.com/Dhruvinkatakiya/smart-task-manager) • [🐛 Report Bug](https://github.com/Dhruvinkatakiya/smart-task-manager/issues) • [📖 Documentation](DEPLOYMENT_EVALUATION_REPORT.md)

</div>

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Dhruvin Katakiya**

- GitHub: [@Dhruvinkatakiya](https://github.com/Dhruvinkatakiya)
- Repository: [smart-task-manager](https://github.com/Dhruvinkatakiya/smart-task-manager)

---

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [React Documentation](https://reactjs.org/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## 🎯 Project Evaluation

This project achieved a **perfect score of 20/20** across all evaluation metrics:

| Metric                     | Score   | Status |
| -------------------------- | ------- | ------ |
| Microservices Architecture | 2.5/2.5 | ✅     |
| Docker Containerization    | 4.0/4.0 | ✅     |
| CI/CD Pipeline             | 2.5/2.5 | ✅     |
| Kubernetes Orchestration   | 2.5/2.5 | ✅     |
| Infrastructure as Code     | 2.5/2.5 | ✅     |
| DevSecOps Practices        | 2.0/2.0 | ✅     |
| Cloud/Local Deployment     | 2.0/2.0 | ✅     |
| Public Link Accessibility  | 2.0/2.0 | ✅     |

See [DEPLOYMENT_EVALUATION_REPORT.md](DEPLOYMENT_EVALUATION_REPORT.md) for detailed evaluation.

---

<div align="center">

**Made with ❤️ by Dhruvin Katakiya**

**Star this repository if you found it helpful!**

</div>
