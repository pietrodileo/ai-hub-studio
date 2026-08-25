#!/bin/bash

# ------------------------------------------------------------------------------
# IRIS AI Hub Studio - Verification Script
# 
# This script verifies that all Docker containers are running correctly
# and that the AI Hub Studio is properly configured.
# ------------------------------------------------------------------------------

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# ------------------------------------------------------------------------------
# Utility Functions
# ------------------------------------------------------------------------------

function print_header() {
    echo -e "${BLUE}================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    echo ""
}

function print_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "[TEST $TOTAL_TESTS] $1... "
}

function print_pass() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}PASS${NC}"
}

function print_fail() {
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}FAIL${NC}"
}

function print_warning() {
    echo -e "${YELLOW}WARNING${NC}"
}

function print_summary() {
    echo ""
    echo -e "${BLUE}================================================================================${NC}"
    echo -e "${BLUE}VERIFICATION SUMMARY${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}All tests passed! ✓${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed! ✗${NC}"
        exit 1
    fi
}

function check_command() {
    if command -v $1 >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function check_docker() {
    if docker info >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function check_docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Main Verification
# ------------------------------------------------------------------------------

print_header "IRIS AI Hub Studio - Verification Script"

# Check prerequisites
print_test "Checking Docker is installed"
if check_docker; then
    print_pass
else
    print_fail
    echo "  Docker is not installed or not running"
    print_summary
    exit 1
fi

print_test "Checking Docker Compose is available"
if check_docker_compose; then
    print_pass
else
    print_fail
    echo "  Docker Compose is not available"
    print_summary
    exit 1
fi

# Check if containers are running
print_header "Container Status Checks"

print_test "Checking if IRIS container is running"
if docker ps --format '{{.Names}}' | grep -q "iris-ai-hub-studio"; then
    print_pass
else
    print_fail
    echo "  IRIS container is not running"
    echo "  Run: docker compose up -d iris-ai-hub"
fi

print_test "Checking if backend container is running"
if docker ps --format '{{.Names}}' | grep -q "ai-hub-backend"; then
    print_pass
else
    print_warning
    echo "  Backend container is not running (optional)"
    echo "  Run: docker compose up -d ai-hub-backend"
fi

print_test "Checking if frontend container is running"
if docker ps --format '{{.Names}}' | grep -q "ai-hub-frontend"; then
    print_pass
else
    print_warning
    echo "  Frontend container is not running (optional)"
    echo "  Run: docker compose up -d ai-hub-frontend"
fi

# Check container health
print_header "Container Health Checks"

print_test "Checking IRIS container health"
if docker inspect --format='{{.State.Health.Status}}' iris-ai-hub-studio 2>/dev/null | grep -q "healthy"; then
    print_pass
else
    print_fail
    echo "  IRIS container is not healthy"
    echo "  Check logs: docker logs iris-ai-hub-studio"
fi

# Check port availability
print_header "Port Availability Checks"

PORTS=("9091" "9092" "53773" "3000" "5173")
PORT_NAMES=("IRIS SuperServer" "IRIS Management Portal" "AI Hub WebSocket" "Backend API" "Frontend UI")

for i in ${!PORTS[*]}; do
    PORT=${PORTS[$i]}
    PORT_NAME=${PORT_NAMES[$i]}
    
    print_test "Checking if port $PORT ($PORT_NAME) is available"
    if nc -z localhost $PORT 2>/dev/null; then
        print_pass
    else
        print_fail
        echo "  Port $PORT is not responding"
        echo "  Service: $PORT_NAME"
    fi
done

# Check IRIS functionality
print_header "IRIS Functionality Checks"

print_test "Checking IRIS Management Portal"
if curl -s -f http://localhost:9092/csp/sys/UtilHome.csp >/dev/null 2>&1; then
    print_pass
else
    print_fail
    echo "  IRIS Management Portal is not accessible"
    echo "  URL: http://localhost:9092/csp/sys/UtilHome.csp"
fi

print_test "Checking IRIS REST API"
if curl -s -f http://localhost:9092/csp/healthshare/health/api/v1/health >/dev/null 2>&1; then
    print_pass
else
    print_fail
    echo "  IRIS REST API is not accessible"
    echo "  URL: http://localhost:9092/csp/healthshare/health/api/v1/health"
fi

# Check AI Hub functionality
print_header "AI Hub Functionality Checks"

print_test "Checking AI Hub classes are loaded"
if docker exec -it iris-ai-hub-studio iris session IRIS -U USER "write \"TEST\"" >/dev/null 2>&1; then
    print_pass
else
    print_fail
    echo "  Cannot execute IRIS session"
    echo "  Check: docker exec -it iris-ai-hub-studio iris session IRIS -U USER"
fi

print_test "Checking AI Hub Studio Agent classes"
if docker exec -it iris-ai-hub-studio iris session IRIS -U USER "write ##class(AIHubStudio.Agent.Registry).Count()" >/dev/null 2>&1; then
    print_pass
else
    print_warning
    echo "  AI Hub Studio Agent classes not found (may need to be created)"
fi

# Check backend functionality
print_header "Backend API Checks"

print_test "Checking backend health endpoint"
if curl -s -f http://localhost:3000/health >/dev/null 2>&1; then
    print_pass
else
    print_warning
    echo "  Backend API is not accessible (backend container may not be running)"
    echo "  URL: http://localhost:3000/health"
fi

# Check frontend functionality
print_header "Frontend UI Checks"

print_test "Checking frontend is serving"
if curl -s -f http://localhost:5173 >/dev/null 2>&1; then
    print_pass
else
    print_warning
    echo "  Frontend UI is not accessible (frontend container may not be running)"
    echo "  URL: http://localhost:5173"
fi

# Check file system
print_header "File System Checks"

print_test "Checking storage directory exists"
if [ -d "./storage/iris" ]; then
    print_pass
else
    print_fail
    echo "  Storage directory does not exist"
    echo "  Create: mkdir -p ./storage/iris"
fi

print_test "Checking logs directory exists"
if [ -d "./logs" ]; then
    print_pass
else
    print_fail
    echo "  Logs directory does not exist"
    echo "  Create: mkdir -p ./logs"
fi

print_test "Checking source directory exists"
if [ -d "./src" ]; then
    print_pass
else
    print_fail
    echo "  Source directory does not exist"
    echo "  Create: mkdir -p ./src"
fi

# Check Docker images
print_header "Docker Image Checks"

print_test "Checking IRIS Docker image exists"
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "iris-ai-hub-studio:latest"; then
    print_pass
else
    print_fail
    echo "  IRIS Docker image not found"
    echo "  Build: docker compose build iris-ai-hub"
fi

# Print summary
print_summary