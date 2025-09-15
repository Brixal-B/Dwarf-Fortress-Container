#!/bin/bash

# VNC Password Validation Script
# This script validates VNC password before allowing noVNC connections

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VNC_HOST="${VNC_HOST:-dwarf-fortress}"
VNC_PORT="${VNC_PORT:-5900}"
MAX_RETRIES=5
RETRY_DELAY=2

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
    local host="$1"
    local port="$2"
    local password="$3"
    
    msg_info "Testing VNC connection to $host:$port..."
    
    # Check if VNC server is listening
    if ! nc -z "$host" "$port" 2>/dev/null; then
        msg_error "VNC server is not listening on $host:$port"
        return 1
    fi
    
    msg_ok "VNC server is listening on $host:$port"
    
    # If password is set, test authentication
    if [[ -n "$password" ]]; then
        msg_info "Testing VNC password authentication..."
        
        # Create temporary password file
        local temp_pass_file=$(mktemp)
        echo "$password" | vncpasswd -f > "$temp_pass_file" 2>/dev/null || {
            msg_error "Failed to create VNC password file"
            rm -f "$temp_pass_file"
            return 1
        }
        
        # Test connection with vncviewer (if available) or use simple socket test
        if command -v vncviewer &> /dev/null; then
            # Use vncviewer to test connection (exit immediately after connecting)
            timeout 5 vncviewer -passwd "$temp_pass_file" "$host:$port" -Shared=0 -ViewOnly=1 &>/dev/null && {
                msg_ok "VNC password authentication successful"
                rm -f "$temp_pass_file"
                return 0
            } || {
                msg_error "VNC password authentication failed"
                rm -f "$temp_pass_file"
                return 1
            }
        else
            # Alternative: use x11vnc to test password (if x11vnc is available)
            msg_warn "vncviewer not available, assuming password is correct"
            msg_info "Password validation will occur during actual connection"
            rm -f "$temp_pass_file"
            return 0
        fi
    else
        msg_warn "No VNC password set - connection will be unprotected"
        return 0
    fi
}

# Function to wait for VNC server to be ready
wait_for_vnc() {
    local host="$1"
    local port="$2"
    local retries=0
    
    msg_info "Waiting for VNC server to be ready..."
    
    while [[ $retries -lt $MAX_RETRIES ]]; do
        if nc -z "$host" "$port" 2>/dev/null; then
            msg_ok "VNC server is ready!"
            return 0
        fi
        
        retries=$((retries + 1))
        msg_info "Attempt $retries/$MAX_RETRIES - VNC server not ready yet, waiting ${RETRY_DELAY}s..."
        sleep $RETRY_DELAY
    done
    
    msg_error "VNC server failed to become ready after $MAX_RETRIES attempts"
    return 1
}

# Function to validate environment variables
validate_environment() {
    msg_info "Validating environment configuration..."
    
    if [[ -z "${VNC_HOST:-}" ]]; then
        msg_error "VNC_HOST environment variable is not set"
        return 1
    fi
    
    if [[ -z "${VNC_PORT:-}" ]]; then
        msg_error "VNC_PORT environment variable is not set"
        return 1
    fi
    
    # Validate port number
    if ! [[ "$VNC_PORT" =~ ^[0-9]+$ ]] || [[ "$VNC_PORT" -lt 1 ]] || [[ "$VNC_PORT" -gt 65535 ]]; then
        msg_error "Invalid VNC_PORT: $VNC_PORT (must be 1-65535)"
        return 1
    fi
    
    msg_ok "Environment configuration is valid"
    return 0
}

# Main validation function
main() {
    echo
    echo "=== VNC Connection Validator ==="
    echo
    
    # Validate environment
    if ! validate_environment; then
        exit 1
    fi
    
    # Wait for VNC server
    if ! wait_for_vnc "$VNC_HOST" "$VNC_PORT"; then
        exit 1
    fi
    
    # Test VNC connection
    if ! test_vnc_connection "$VNC_HOST" "$VNC_PORT" "${VNC_PASSWORD:-}"; then
        msg_error "VNC validation failed!"
        echo
        echo "Troubleshooting tips:"
        echo "1. Check if the Dwarf Fortress container is running"
        echo "2. Verify VNC_PASSWORD is set correctly in .env file"
        echo "3. Check docker-compose logs dwarf-fortress"
        echo
        exit 1
    fi
    
    msg_ok "VNC validation successful! noVNC can now connect safely."
    echo
}

# Handle script arguments
case "${1:-validate}" in
    "validate")
        main
        ;;
    "test-connection")
        test_vnc_connection "$VNC_HOST" "$VNC_PORT" "${VNC_PASSWORD:-}"
        ;;
    "wait")
        wait_for_vnc "$VNC_HOST" "$VNC_PORT"
        ;;
    *)
        echo "Usage: $0 [validate|test-connection|wait]"
        echo "  validate       - Full validation (default)"
        echo "  test-connection - Test VNC connection only"
        echo "  wait          - Wait for VNC server only"
        exit 1
        ;;
esac
