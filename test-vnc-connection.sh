#!/bin/bash

# VNC Connection Test Script
# Simple script to test VNC connection with password validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables from .env file if it exists
if [[ -f .env ]]; then
    source .env
fi

# Configuration
VNC_HOST="${VNC_HOST:-localhost}"
VNC_PORT="${VNC_PORT:-5900}"

# Message functions
msg_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

msg_ok() {
    echo -e "${GREEN}[✓]${NC} $1"
}

msg_error() {
    echo -e "${RED}[✗]${NC} $1"
}

msg_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

# Function to test VNC connection
test_vnc_connection() {
    msg_info "Testing VNC connection to $VNC_HOST:$VNC_PORT..."
    
    # Check if VNC server is listening
    if nc -z "$VNC_HOST" "$VNC_PORT" 2>/dev/null; then
        msg_ok "VNC server is listening on $VNC_HOST:$VNC_PORT"
        
        if [[ -n "${VNC_PASSWORD:-}" ]]; then
            msg_info "VNC password is configured (${#VNC_PASSWORD} characters)"
            msg_warn "Password validation requires manual testing with VNC client"
        else
            msg_warn "No VNC password configured - connection is unprotected"
        fi
        
        return 0
    else
        msg_error "VNC server is not listening on $VNC_HOST:$VNC_PORT"
        return 1
    fi
}

# Function to show connection info
show_connection_info() {
    echo
    echo "=== VNC Connection Information ==="
    echo
    echo -e "Host: ${CYAN}$VNC_HOST${NC}"
    echo -e "Port: ${CYAN}$VNC_PORT${NC}"
    
    if [[ -n "${VNC_PASSWORD:-}" ]]; then
        echo -e "Password: ${GREEN}Set (${#VNC_PASSWORD} chars)${NC}"
    else
        echo -e "Password: ${YELLOW}Not set${NC}"
    fi
    
    echo
    echo "Connection URLs:"
    echo -e "  VNC: ${CYAN}vnc://$VNC_HOST:$VNC_PORT${NC}"
    echo -e "  noVNC Web: ${CYAN}http://$VNC_HOST:6080${NC}"
    echo
}

# Function to check container status
check_container_status() {
    msg_info "Checking container status..."
    
    if command -v docker-compose &> /dev/null; then
        echo
        echo "Container Status:"
        docker-compose ps
        echo
        
        echo "Health Status:"
        docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
        echo
    else
        msg_warn "docker-compose not found, cannot check container status"
    fi
}

# Main function
main() {
    clear
    echo
    echo "=== VNC Connection Test ==="
    echo
    
    # Load configuration
    if [[ ! -f .env ]]; then
        msg_warn "No .env file found, using default values"
    fi
    
    # Show connection info
    show_connection_info
    
    # Check container status
    check_container_status
    
    # Test VNC connection
    if test_vnc_connection; then
        echo
        msg_ok "VNC connection test completed successfully!"
        echo
        echo "Next steps:"
        echo "1. Open your VNC client and connect to: $VNC_HOST:$VNC_PORT"
        echo "2. Or use the web interface at: http://$VNC_HOST:6080"
        if [[ -n "${VNC_PASSWORD:-}" ]]; then
            echo "3. Enter the VNC password when prompted"
        fi
        echo
    else
        echo
        msg_error "VNC connection test failed!"
        echo
        echo "Troubleshooting:"
        echo "1. Check if containers are running: docker-compose ps"
        echo "2. Check container logs: docker-compose logs dwarf-fortress"
        echo "3. Verify .env file contains correct VNC_PASSWORD"
        echo "4. Try restarting containers: docker-compose restart"
        echo
        exit 1
    fi
}

# Handle script arguments
case "${1:-test}" in
    "test")
        main
        ;;
    "info")
        show_connection_info
        ;;
    "status")
        check_container_status
        ;;
    *)
        echo "Usage: $0 [test|info|status]"
        echo "  test   - Full connection test (default)"
        echo "  info   - Show connection information"
        echo "  status - Check container status"
        exit 1
        ;;
esac
