#!/bin/bash
# ------------------------------------------------------------------------------
# IRIS AI Hub Studio - AI Hub Setup Script
# 
# This script automates the setup of the AI Hub pre-release container.
# Run this script after downloading the AI Hub Docker image.
# 
# Usage:
#   ./setup-ai-hub.sh [path-to-docker-image]
# 
# Example:
#   ./setup-ai-hub.sh ~/Downloads/iris-2026.3.0AI.106.0-docker.tar.gz
# ------------------------------------------------------------------------------

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_IMAGE_NAME="docker.iscinternal.com/docker-intersystems/intersystems/iris:2026.3.0AI.136.0"
CONTAINER_NAME="iris-ai-hub-studio"
LICENSE_DIR="${SCRIPT_DIR}/license"

# ------------------------------------------------------------------------------
# Colors for output
# ------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# Logging functions
# ------------------------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# ------------------------------------------------------------------------------
# Check prerequisites
# ------------------------------------------------------------------------------

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    log_success "Docker is installed and running."
}

# ------------------------------------------------------------------------------
# Load Docker image
# ------------------------------------------------------------------------------

load_docker_image() {
    local image_path="$1"
    
    if [ -z "$image_path" ]; then
        log_warning "No Docker image path provided. Looking for default image..."
        
        # Check if image already exists
        if docker image inspect "${DOCKER_IMAGE_NAME}" &> /dev/null; then
            log_success "Docker image ${DOCKER_IMAGE_NAME} already exists."
            return 0
        fi
        
        # Look for common download locations
        local possible_paths=(
            "${HOME}/Downloads/iris-2026.3.0AI.136.0-docker.tar.gz"
            "${SCRIPT_DIR}/iris-2026.3.0AI.136.0-docker.tar.gz"
            "/tmp/iris-2026.3.0AI.136.0-docker.tar.gz"
        )
        
        for path in "${possible_paths[@]}"; do
            if [ -f "$path" ]; then
                image_path="$path"
                break
            fi
        done
        
        if [ -z "$image_path" ]; then
            log_error "Docker image not found. Please download iris-2026.3.0AI.106.0-docker.tar.gz first."
            log_info "Download from: https://github.com/intersystems-community/ai-hub-dev-template"
            exit 1
        fi
    fi
    
    if [ ! -f "$image_path" ]; then
        log_error "Docker image file not found: $image_path"
        exit 1
    fi
    
    log_info "Loading Docker image from: $image_path"
    
    if docker image load -i "$image_path" | grep -q "Loaded image"; then
        log_success "Docker image loaded successfully."
    else
        log_error "Failed to load Docker image."
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Create license directory and placeholder
# ------------------------------------------------------------------------------

setup_license() {
    log_info "Setting up license directory..."
    
    # Create license directory if it doesn't exist
    mkdir -p "${LICENSE_DIR}"
    
    # Create placeholder license key if it doesn't exist
    local license_file="${LICENSE_DIR}/iris-container-x64.key"
    if [ ! -f "$license_file" ]; then
        log_info "Creating placeholder license key..."
        touch "$license_file"
        log_warning "Using placeholder license key. For production, replace with actual license."
    else
        log_info "License key already exists."
    fi
    
    log_success "License directory setup complete."
}

# ------------------------------------------------------------------------------
# Build and start containers
# ------------------------------------------------------------------------------

start_containers() {
    log_info "Starting AI Hub containers..."
    
    # Check if we should use the AI Hub specific compose file
    local compose_file="docker-compose-ai-hub.yml"
    
    if [ -f "$compose_file" ]; then
        log_info "Using AI Hub specific compose file: $compose_file"
        
        # Stop any existing containers
        if docker compose -f "$compose_file" ps &> /dev/null; then
            log_info "Stopping existing containers..."
            docker compose -f "$compose_file" down
        fi
        
        # Build and start
        log_info "Building and starting containers..."
        docker compose -f "$compose_file" up -d --build
        
        # Check if containers started successfully
        sleep 10
        if docker compose -f "$compose_file" ps | grep -q "Up"; then
            log_success "Containers started successfully."
        else
            log_error "Failed to start containers."
            docker compose -f "$compose_file" logs
            exit 1
        fi
    else
        log_error "AI Hub compose file not found: $compose_file"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Verify setup
# ------------------------------------------------------------------------------

verify_setup() {
    log_info "Verifying AI Hub setup..."
    
    # Check if container is running
    if docker ps | grep -q "${CONTAINER_NAME}"; then
        log_success "Container ${CONTAINER_NAME} is running."
    else
        log_error "Container ${CONTAINER_NAME} is not running."
        exit 1
    fi
    
    # Check ports
    log_info "Checking port availability..."
    local ports=(1972 52773 53773)
    for port in "${ports[@]}"; do
        if docker port "${CONTAINER_NAME}" | grep -q "${port}"; then
            log_success "Port ${port} is mapped."
        else
            log_warning "Port ${port} is not mapped."
        fi
    done
    
    # Check IRIS health
    log_info "Checking IRIS health..."
    local max_retries=10
    local retry_count=0
    
    while [ ${retry_count} -lt ${max_retries} ]; do
        if curl -s -f -o /dev/null "http://localhost:1972/csp/sys/UtilHome.csp" 2>/dev/null; then
            log_success "IRIS Management Portal is accessible at http://localhost:1972/csp/sys/UtilHome.csp"
            break
        fi
        retry_count=$((retry_count + 1))
        sleep 5
        log_info "Waiting for IRIS to become available... (${retry_count}/${max_retries})"
    done
    
    if [ ${retry_count} -eq ${max_retries} ]; then
        log_warning "IRIS Management Portal not accessible yet. It may take a few minutes to start."
    fi
}

# ------------------------------------------------------------------------------
# Display access information
# ------------------------------------------------------------------------------

display_access_info() {
    echo ""
    echo "==============================================================================="
    echo "                    IRIS AI Hub Studio - Setup Complete"
    echo "==============================================================================="
    echo ""
    echo "Access URLs:"
    echo "  🌐 IRIS Management Portal: http://localhost:1972/csp/sys/UtilHome.csp"
    echo "  🔌 AI Hub WebSocket:        ws://localhost:53773"
    echo "  📡 IRIS REST API:          http://localhost:1972"
    echo "  🎯 Backend API:            http://localhost:3000"
    echo "  💻 Frontend Dev Server:    http://localhost:5173"
    echo ""
    echo "Default Credentials:"
    echo "  Username: _SYSTEM"
    echo "  Password: SYS"
    echo "  Namespace: AIHubStudio"
    echo ""
    echo "Docker Commands:"
    echo "  View logs:        docker compose -f docker-compose-ai-hub.yml logs -f iris-ai-hub"
    echo "  Stop containers: docker compose -f docker-compose-ai-hub.yml down"
    echo "  Restart:         docker compose -f docker-compose-ai-hub.yml restart"
    echo ""
    echo "Next Steps:"
    echo "  1. Access the IRIS Management Portal to verify installation"
    echo "  2. Import your ObjectScript classes in the AIHubStudio namespace"
    echo "  3. Configure API keys using the AIHubStudio.Config class"
    echo "  4. Start developing your AI agents!"
    echo ""
    echo "==============================================================================="
}

# ------------------------------------------------------------------------------
# Main execution
# ------------------------------------------------------------------------------

main() {
    echo ""
    echo "==============================================================================="
    echo "              IRIS AI Hub Studio - AI Hub Setup Script"
    echo "==============================================================================="
    echo ""
    
    # Parse arguments
    local image_path=""
    if [ $# -ge 1 ]; then
        image_path="$1"
    fi
    
    # Step 1: Check prerequisites
    check_prerequisites
    echo ""
    
    # Step 2: Load Docker image
    load_docker_image "$image_path"
    echo ""
    
    # Step 3: Setup license
    setup_license
    echo ""
    
    # Step 4: Start containers
    start_containers
    echo ""
    
    # Step 5: Verify setup
    verify_setup
    echo ""
    
    # Step 6: Display access information
    display_access_info
}

# Run main function
main "$@"