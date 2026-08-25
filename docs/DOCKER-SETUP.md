# IRIS AI Hub Studio - Docker Setup Guide

> **🎯 Complete Docker infrastructure for the IRIS AI Hub Studio project**
> 
> *Based on patterns from [iris-mcp-blueprint](https://github.com/pietrodileo/iris-mcp-blueprint)*

---

## 📚 Table of Contents

- [🎯 Overview](#-overview)
- [🐳 Docker Architecture](#-docker-architecture)
- [📁 Project Structure](#-project-structure)
- [🚀 Quick Start](#-quick-start)
- [📋 Detailed Setup](#-detailed-setup)
- [🔧 Configuration Options](#-configuration-options)
- [🧪 Verification](#-verification)
- [🛠️ Development Workflow](#-development-workflow)
- [🔄 Updates and Maintenance](#-updates-and-maintenance)
- [❓ Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

The IRIS AI Hub Studio uses a **multi-container Docker architecture** to provide:

- **IRIS with AI Hub EAP** - Primary database with AI capabilities
- **Backend API** - Node.js server for agent management and tool execution
- **Frontend UI** - React + TypeScript interface for AI development

This setup follows the proven patterns from the [iris-mcp-blueprint](https://github.com/pietrodileo/iris-mcp-blueprint) repository, adapted for the AI Hub EAP requirements.

---

## 🐳 Docker Architecture

### Container Services

| Service | Container Name | Ports | Purpose |
|---------|---------------|-------|---------|
| **IRIS + AI Hub** | `iris-ai-hub-studio` | 9091, 9092, 53773 | Primary database with AI Hub EAP |
| **Backend API** | `ai-hub-backend` | 3000, 3001 | Node.js API server |
| **Frontend UI** | `ai-hub-frontend` | 5173, 4173 | React development server |

### Port Mapping

| Container Port | Host Port | Service |
|---------------|-----------|---------|
| 1972 | 9091 | IRIS SuperServer (ODBC, JDBC) |
| 52773 | 9092 | IRIS Management Portal / REST APIs |
| 53773 | 53773 | AI Hub WebSocket |
| 3000 | 3000 | Backend API server |
| 3001 | 3001 | Backend development server |
| 5173 | 5173 | Frontend Vite development server |
| 4173 | 4173 | Frontend Vite preview server |

### Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| `./storage/iris` | `/durable/iris` | IRIS database files |
| `./storage/ai-hub` | `/opt/irisapp/ai-hub` | AI Hub data and models |
| `./src` | `/opt/irisapp/src` | Application source code |
| `./logs` | `/opt/irisapp/logs` | Application logs |

---

## 📁 Project Structure

```
iris-ai-hub-studio/
├── docker-compose.yml          # Main Docker Compose configuration
├── Dockerfile                  # IRIS + AI Hub Dockerfile
├── Dockerfile.backend          # Backend API Dockerfile
├── Dockerfile.frontend         # Frontend UI Dockerfile
├── docker-entrypoint.sh        # IRIS container entrypoint script
├── iris.script                 # IRIS initialization script
├── docker-commands.txt         # Common Docker commands reference
├── .gitignore                  # Git ignore file
│
├── docs/
│   └── DOCKER-SETUP.md         # This file
│
├── src/                        # IRIS application source code
│   ├── AIHub/                  # AI Hub specific classes
│   ├── Agent/                  # Agent implementations
│   ├── Tool/                   # Tool implementations
│   ├── Skill/                  # Skill implementations
│   └── MCP/                    # MCP integration classes
│
├── backend/                    # Node.js backend
│   ├── src/
│   ├── package.json
│   └── config/
│
├── frontend/                   # React frontend
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── vite.config.js
│
├── storage/                    # Durable storage (git ignored)
│   ├── iris/                   # IRIS database files
│   └── ai-hub/                 # AI Hub data
│
└── logs/                       # Application logs (git ignored)
```

---

## 🚀 Quick Start

### Prerequisites

- **Docker** with Docker Compose v2+ installed
- **Docker Desktop** (recommended for development)
- **Ports 9091, 9092, 3000, 5173, 53773** available on your system
- **Minimum 8GB RAM** allocated to Docker (16GB recommended)
- **Minimum 4 CPU cores** allocated to Docker

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/your-username/iris-ai-hub-studio.git
cd iris-ai-hub-studio

# Initialize git submodules (if any)
git submodule update --init --recursive
```

### 2. Start the IRIS Container (Minimal Setup)

```bash
# Build and start only the IRIS container
docker compose up -d iris-ai-hub

# Wait for IRIS to become healthy (check with)
docker ps

# Verify IRIS is running
curl -f http://localhost:9092/csp/sys/UtilHome.csp
```

### 3. Start the Full Stack

```bash
# Build and start all containers
docker compose up -d --build

# Wait for all services to start (this may take a few minutes)
docker compose ps
```

### 4. Access the Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **IRIS Management Portal** | http://localhost:9092/csp/sys/UtilHome.csp | _SYSTEM / SYS |
| **AI Hub Studio UI** | http://localhost:5173 | - |
| **Backend API** | http://localhost:3000 | - |
| **API Documentation** | http://localhost:3000/api-docs | - |

---

## 📋 Detailed Setup

### Step 1: Environment Configuration

#### Docker Resource Allocation

1. Open Docker Desktop settings
2. Navigate to **Resources**
3. Allocate at least:
   - **Memory**: 8GB (16GB recommended)
   - **CPU**: 4 cores
   - **Swap**: 2GB
   - **Disk**: 20GB minimum

#### Network Configuration

Ensure the following ports are available:
- **9091** - IRIS SuperServer
- **9092** - IRIS Management Portal
- **3000** - Backend API
- **5173** - Frontend development server
- **53773** - AI Hub WebSocket

If ports are in use, modify the port mappings in `docker-compose.yml`.

### Step 2: Build the Images

#### Build All Images

```bash
# Build all images from scratch (no cache)
docker compose build --no-cache

# Or build specific services
docker compose build iris-ai-hub
docker compose build ai-hub-backend
docker compose build ai-hub-frontend
```

#### Build with Cache (Faster)

```bash
# Use Docker cache for faster builds
docker compose build
```

### Step 3: Start the Containers

#### Start All Services

```bash
# Start all containers in background
docker compose up -d

# Start with build (if images need rebuilding)
docker compose up -d --build
```

#### Start Specific Services

```bash
# Start only IRIS
docker compose up -d iris-ai-hub

# Start IRIS and backend
docker compose up -d iris-ai-hub ai-hub-backend
```

### Step 4: Verify Services

#### Check Container Status

```bash
# List all containers
docker compose ps

# Check container logs
docker compose logs -f

# Check specific service logs
docker compose logs -f iris-ai-hub
```

#### Verify IRIS is Running

```bash
# Check IRIS Management Portal
curl -f http://localhost:9092/csp/sys/UtilHome.csp

# Check IRIS REST API
curl -f http://localhost:9092/csp/healthshare/health/api/v1/health

# Check AI Hub health (once configured)
curl -f http://localhost:9092/ai-hub/api/health
```

#### Verify Backend is Running

```bash
# Check backend health
curl -f http://localhost:3000/health

# Check API documentation
curl -f http://localhost:3000/api-docs
```

#### Verify Frontend is Running

```bash
# Check frontend is serving
curl -f http://localhost:5173
```

---

## 🔧 Configuration Options

### Docker Compose Configuration

The `docker-compose.yml` file supports several configuration options:

#### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ISC_DATA_DIRECTORY` | `/durable/iris` | IRIS data directory |
| `AI_HUB_ENABLED` | `1` | Enable AI Hub features |
| `AI_HUB_PORT` | `53773` | AI Hub WebSocket port |
| `AI_HUB_WS_PORT` | `53773` | AI Hub WebSocket port |

#### Port Configuration

Modify the port mappings in `docker-compose.yml`:

```yaml
ports:
  - "HOST_PORT:CONTAINER_PORT"
```

Example: Change IRIS Management Portal to port 8080:

```yaml
ports:
  - "8080:52773"  # Management Portal
```

### IRIS Configuration

#### Custom IRIS Instance Name

Modify the `IRIS_INSTANCE` variable in `docker-entrypoint.sh`:

```bash
IRIS_INSTANCE="MY_IRIS_INSTANCE"
```

#### Custom Namespace

Modify the namespace in `iris.script`:

```objectscript
zn "MY_NAMESPACE"
```

### AI Hub Configuration

#### Enable/Disable AI Hub

Set the `AI_HUB_ENABLED` environment variable:

```yaml
environment:
  - AI_HUB_ENABLED=0  # Disable AI Hub
```

#### Custom AI Hub Ports

Modify the AI Hub ports in `docker-compose.yml`:

```yaml
environment:
  - AI_HUB_PORT=54773
  - AI_HUB_WS_PORT=55773
```

---

## 🧪 Verification

### Verification Script

Run the verification script to ensure everything is working:

```bash
# Make the script executable
chmod +x verify-ai-hub.sh

# Run verification
./verify-ai-hub.sh
```

### Manual Verification Steps

#### 1. IRIS Container

```bash
# Check container is running
docker ps | grep iris-ai-hub-studio

# Check IRIS is healthy
docker inspect --format='{{json .State.Health}}' iris-ai-hub-studio

# Check IRIS logs
docker logs iris-ai-hub-studio

# Check entrypoint logs
docker exec -it iris-ai-hub-studio cat /opt/irisapp/logs/entrypoint.log
```

#### 2. IRIS Functionality

```bash
# Test IRIS session
docker exec -it iris-ai-hub-studio iris session IRIS -U %SYS "write \"IRIS is working\""

# Test ObjectScript execution
docker exec -it iris-ai-hub-studio iris session IRIS -U USER "do ##class(AIHub.Status).Display()"

# Test AI Hub classes
docker exec -it iris-ai-hub-studio iris session IRIS -U USER "write ##class(AIHub.Agent.Registry).Count()"
```

#### 3. REST API

```bash
# Test IRIS REST API
curl -f http://localhost:9092/csp/sys/UtilHome.csp

# Test AI Hub REST endpoints (once configured)
curl -f http://localhost:9092/ai-hub/api/agents
curl -f http://localhost:9092/ai-hub/api/tools
curl -f http://localhost:9092/ai-hub/api/skills
```

#### 4. Backend API

```bash
# Test backend health
curl -f http://localhost:3000/health

# Test API endpoints
curl -f http://localhost:3000/api/agents
curl -f http://localhost:3000/api/tools
```

#### 5. Frontend

```bash
# Test frontend is serving
curl -f http://localhost:5173

# Open in browser
open http://localhost:5173
```

---

## 🛠️ Development Workflow

### Making Changes

#### 1. Modify Source Code

Edit files in the `src/` directory. Changes are automatically reflected in the container due to volume mounting.

#### 2. Rebuild and Restart

```bash
# For IRIS changes - restart the container
docker compose restart iris-ai-hub

# For backend changes - rebuild and restart
docker compose up -d --build ai-hub-backend

# For frontend changes - rebuild and restart
docker compose up -d --build ai-hub-frontend
```

### Hot Reloading

#### IRIS Development

IRIS does not support hot reloading. After making changes to ObjectScript classes:

```bash
# Restart IRIS container
docker compose restart iris-ai-hub

# Or reload specific classes
docker exec -it iris-ai-hub-studio iris session IRIS -U USER "do $System.OBJ.Import(\"/opt/irisapp/src\",\"ckd\")"
```

#### Backend Development

The backend supports hot reloading in development mode:

```bash
# Backend will automatically reload when files change
# No need to restart the container
```

#### Frontend Development

The frontend supports hot reloading in development mode:

```bash
# Frontend will automatically reload when files change
# No need to restart the container
```

### Debugging

#### IRIS Debugging

```bash
# Open IRIS session for debugging
docker exec -it iris-ai-hub-studio iris session IRIS -U USER

# View IRIS logs
docker exec -it iris-ai-hub-studio cat /opt/irisapp/logs/iris.log

# View entrypoint logs
docker exec -it iris-ai-hub-studio cat /opt/irisapp/logs/entrypoint.log
```

#### Backend Debugging

```bash
# View backend logs
docker compose logs -f ai-hub-backend

# Open shell in backend container
docker exec -it ai-hub-backend sh

# Run backend in debug mode
# Modify Dockerfile.backend CMD to: ["npm", "run", "debug"]
```

#### Frontend Debugging

```bash
# View frontend logs
docker compose logs -f ai-hub-frontend

# Open shell in frontend container
docker exec -it ai-hub-frontend sh
```

---

## 🔄 Updates and Maintenance

### Updating IRIS Base Image

To update to a newer version of IRIS or AI Hub:

```bash
# Pull the latest base image
docker pull intersystemsdc/iris-ai-hub:latest

# Rebuild all images
docker compose build --no-cache --pull

# Restart containers
docker compose up -d --force-recreate
```

### Updating Dependencies

#### Backend Dependencies

```bash
# Update package.json in backend/
# Then rebuild
docker compose build --no-cache ai-hub-backend
```

#### Frontend Dependencies

```bash
# Update package.json in frontend/
# Then rebuild
docker compose build --no-cache ai-hub-frontend
```

### Cleaning Up

#### Remove Unused Containers and Images

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove all unused objects
docker system prune

# Remove everything (containers, networks, images, volumes)
docker system prune -a --volumes
```

#### Reset to Clean State

```bash
# Stop and remove all containers
docker compose down

# Remove all images
docker rmi -f $(docker images -q)

# Remove all volumes
docker volume prune -f

# Remove all networks
docker network prune -f

# Then rebuild from scratch
docker compose up -d --build
```

---

## ❓ Troubleshooting

### Common Issues

#### 1. Port Already in Use

**Error**: `Error: Port X is already in use`

**Solution**:
```bash
# Find which process is using the port
lsof -i :9092

# Kill the process
kill -9 <PID>

# Or change the port mapping in docker-compose.yml
```

#### 2. IRIS Not Starting

**Error**: IRIS container exits immediately

**Solution**:
```bash
# Check logs
docker logs iris-ai-hub-studio

# Check entrypoint logs
docker exec -it iris-ai-hub-studio cat /opt/irisapp/logs/entrypoint.log

# Increase Docker resources (memory/CPU)
```

#### 3. AI Hub Not Available

**Error**: AI Hub classes not found

**Solution**:
```bash
# Ensure AI Hub is installed
# Check if using the correct base image
docker inspect iris-ai-hub-studio | grep -i "iris-ai-hub"

# Or install AI Hub via ZPM
docker exec -it iris-ai-hub-studio iris session IRIS -U USER "zpm \"load ai-hub\""
```

#### 4. Connection Refused

**Error**: `Connection refused` when accessing services

**Solution**:
```bash
# Check if containers are running
docker ps

# Check container logs
docker compose logs -f

# Verify ports are mapped correctly
docker port iris-ai-hub-studio

# Wait for services to fully start (can take several minutes)
```

#### 5. Permission Issues

**Error**: Permission denied when accessing files

**Solution**:
```bash
# Ensure proper permissions on host directories
chmod -R 755 ./storage
chmod -R 755 ./logs

# Or run as root temporarily
sudo chown -R $USER:$USER ./
```

### Debug Commands

#### Check Docker System Info

```bash
# Docker system information
docker info

# Docker disk usage
docker system df

# Docker events (real-time)
docker events
```

#### Inspect Containers

```bash
# Inspect container details
docker inspect iris-ai-hub-studio

# View container processes
docker top iris-ai-hub-studio

# View container resource usage
docker stats
```

#### Network Debugging

```bash
# List networks
docker network ls

# Inspect network
docker network inspect iris-ai-hub-studio_iris-ai-hub-studio-network

# Test connectivity between containers
docker exec -it iris-ai-hub-studio ping ai-hub-backend
```

---

## 📖 Additional Resources

### Docker Documentation

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker for Developers](https://docker-curriculum.com/)

### InterSystems IRIS Documentation

- [IRIS Documentation](https://docs.intersystems.com/)
- [IRIS Docker Images](https://hub.docker.com/r/intersystems/iris-community)
- [IRIS AI Hub Documentation](https://docs.intersystems.com/aihub/)

### AI Hub Resources

- [AI Hub GitHub](https://github.com/intersystems/ai-hub)
- [AI Hub Examples](https://github.com/intersystems/ai-hub-examples)
- [AI Hub API Reference](https://docs.intersystems.com/aihub/api/)

---

## 🎯 Summary

This Docker setup provides a **complete development environment** for the IRIS AI Hub Studio project. The architecture follows proven patterns from the iris-mcp-blueprint repository, ensuring reliability and maintainability.

### Key Features

✅ **Multi-container architecture** for isolation and scalability  
✅ **Volume mounting** for persistent data and easy development  
✅ **Health checks** for service reliability  
✅ **Hot reloading** for backend and frontend development  
✅ **Comprehensive logging** for debugging  
✅ **Easy configuration** via environment variables  
✅ **Production-ready** Dockerfiles  

### Quick Reference

| Task | Command |
|------|---------|
| Start all services | `docker compose up -d` |
| Stop all services | `docker compose down` |
| View logs | `docker compose logs -f` |
| Restart IRIS | `docker compose restart iris-ai-hub` |
| Rebuild all | `docker compose up -d --build` |
| Clean everything | `docker system prune -a --volumes` |

---

**🚀 You're now ready to develop with the IRIS AI Hub Studio!**

For questions or issues, refer to the [troubleshooting section](#-troubleshooting) or check the [official documentation](https://docs.intersystems.com/aihub/).