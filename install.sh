#!/usr/bin/env bash

# Dwarf Fortress Container - Proxmox Helper Script Style Installer
# This script automates the installation of Dwarf Fortress with DFHack in a Docker container

set -euo pipefail
shopt -s inherit_errexit nullglob

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Application info
APP="Dwarf Fortress Container"
REPO="Brixal-B/dwarf-fortress-container"
BRANCH="main"

# Header function
header_info() {
    cat <<"EOF"
    ____                   ____   ______          __                   
   / __ \_      ______ _ / __/ /_/ ____/___  ____/ /________  ___ _____
  / / / / | /| / / __ `// // __/ /_   / __ \/ __  / ___/ _ \/ __ `/ ___/
 / /_/ /| |/ |/ / /_/ // // /_/ __/ / /_/ / /_/ / /  /  __/ /_/ (__  )
/_____/ |__/|__/\__,_//_/ \__/_/    \____/\__,_/_/   \___/\__,_/____/
                                                                      
    AI-Ready Dwarf Fortress Container with DFHack
EOF
}

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

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

# System requirements check
check_requirements() {
    msg_info "Checking system requirements..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        msg_error "This script should not be run as root"
        exit 1
    fi
    
    # Check for Docker
    if ! command -v docker &> /dev/null; then
        msg_error "Docker is not installed. Please install Docker first."
        echo "Run: curl -fsSL https://get.docker.com | sh"
        exit 1
    fi
    
    # Check Docker service
    if ! systemctl is-active --quiet docker; then
        msg_error "Docker service is not running. Starting Docker..."
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
    
    # Check if user is in docker group
    if ! groups $USER | grep &>/dev/null '\bdocker\b'; then
        msg_warn "User not in docker group. Adding user to docker group..."
        sudo usermod -aG docker $USER
        msg_warn "Please log out and back in, then run this script again."
        exit 1
    fi
    
    # Check for git
    if ! command -v git &> /dev/null; then
        msg_info "Installing git..."
        sudo apt-get update && sudo apt-get install -y git
    fi
    
    # Check for docker-compose
    if ! command -v docker-compose &> /dev/null; then
        msg_info "Installing docker-compose..."
        sudo apt-get install -y docker-compose
    fi
    
    msg_ok "System requirements satisfied"
}

# Get installation options
get_options() {
    echo
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         Installation Options          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo
    
    # Installation directory
    echo -e "${WHITE}Installation Directory:${NC}"
    read -p "Enter installation path [/opt/dwarf-fortress]: " INSTALL_DIR
    INSTALL_DIR=${INSTALL_DIR:-/opt/dwarf-fortress}
    
    # Port configuration
    echo -e "${WHITE}VNC Port Configuration:${NC}"
    read -p "VNC port for remote access [5900]: " VNC_PORT
    VNC_PORT=${VNC_PORT:-5900}
    
    # Resource limits
    echo -e "${WHITE}Resource Limits:${NC}"
    read -p "Memory limit in GB [4]: " MEMORY_LIMIT
    MEMORY_LIMIT=${MEMORY_LIMIT:-4}
    
    read -p "CPU cores [2]: " CPU_CORES
    CPU_CORES=${CPU_CORES:-2}
    
    # Auto-start option
    echo -e "${WHITE}Auto-start Configuration:${NC}"
    read -p "Start container automatically? [y/N]: " AUTO_START
    AUTO_START=${AUTO_START:-n}
    
    echo
    echo -e "${CYAN}Configuration Summary:${NC}"
    echo -e "  Installation Directory: ${GREEN}$INSTALL_DIR${NC}"
    echo -e "  VNC Port: ${GREEN}$VNC_PORT${NC}"
    echo -e "  Memory Limit: ${GREEN}${MEMORY_LIMIT}GB${NC}"
    echo -e "  CPU Cores: ${GREEN}$CPU_CORES${NC}"
    echo -e "  Auto-start: ${GREEN}$AUTO_START${NC}"
    echo
    
    read -p "Continue with installation? [Y/n]: " CONFIRM
    CONFIRM=${CONFIRM:-y}
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        msg_error "Installation cancelled"
        exit 1
    fi
}

# Clone repository
clone_repository() {
    msg_info "Cloning Dwarf Fortress container repository..."
    
    # Create installation directory
    if [[ ! -d "$INSTALL_DIR" ]]; then
        sudo mkdir -p "$INSTALL_DIR"
        sudo chown $USER:$USER "$INSTALL_DIR"
    fi
    
    # Clone repository
    cd "$INSTALL_DIR"
    if [[ -d ".git" ]]; then
        msg_info "Repository already exists. Updating..."
        git pull origin $BRANCH
    else
        git clone https://github.com/$REPO.git .
    fi
    
    msg_ok "Repository cloned successfully"
}

# Configure installation
configure_installation() {
    msg_info "Configuring installation..."
    
    # Create custom docker-compose override
    cat > docker-compose.override.yml <<EOF
version: '3.8'

services:
  dwarf-fortress:
    ports:
      - "${VNC_PORT}:5900"
    deploy:
      resources:
        limits:
          cpus: '${CPU_CORES}.0'
          memory: ${MEMORY_LIMIT}G
        reservations:
          cpus: '1.0'
          memory: 2G
EOF
    
    # Create data directories
    mkdir -p saves logs output config
    
    # Make scripts executable
    chmod +x df-manager.sh download_df.sh start.sh
    
    msg_ok "Installation configured"
}

# Build container
build_container() {
    msg_info "Building Dwarf Fortress container (this may take a while)..."
    
    echo -e "${YELLOW}Building container in background...${NC}"
    docker-compose build --no-cache > build.log 2>&1 &
    BUILD_PID=$!
    
    # Show spinner while building
    spinner $BUILD_PID
    wait $BUILD_PID
    BUILD_STATUS=$?
    
    if [[ $BUILD_STATUS -eq 0 ]]; then
        msg_ok "Container built successfully"
        rm -f build.log
    else
        msg_error "Container build failed. Check build.log for details."
        exit 1
    fi
}

# Create systemd service (optional)
create_service() {
    if [[ $AUTO_START =~ ^[Yy]$ ]]; then
        msg_info "Creating systemd service for auto-start..."
        
        sudo tee /etc/systemd/system/dwarf-fortress.service > /dev/null <<EOF
[Unit]
Description=Dwarf Fortress Container
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable dwarf-fortress.service
        
        msg_ok "Systemd service created and enabled"
    fi
}

# Start container
start_container() {
    msg_info "Starting Dwarf Fortress container..."
    
    if [[ $AUTO_START =~ ^[Yy]$ ]]; then
        sudo systemctl start dwarf-fortress.service
    else
        docker-compose up -d
    fi
    
    # Wait for container to be ready
    sleep 5
    
    if docker-compose ps | grep -q "Up"; then
        msg_ok "Container started successfully"
    else
        msg_error "Failed to start container"
        exit 1
    fi
}

# Installation summary
show_summary() {
    echo
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Installation Complete         ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}Installation Details:${NC}"
    echo -e "  Location: ${CYAN}$INSTALL_DIR${NC}"
    echo -e "  VNC Access: ${CYAN}$(hostname -I | awk '{print $1}'):$VNC_PORT${NC}"
    echo -e "  Status: ${GREEN}Running${NC}"
    echo
    echo -e "${WHITE}Management Commands:${NC}"
    echo -e "  Start:   ${CYAN}cd $INSTALL_DIR && ./df-manager.sh start${NC}"
    echo -e "  Stop:    ${CYAN}cd $INSTALL_DIR && ./df-manager.sh stop${NC}"
    echo -e "  Logs:    ${CYAN}cd $INSTALL_DIR && ./df-manager.sh logs${NC}"
    echo -e "  Shell:   ${CYAN}cd $INSTALL_DIR && ./df-manager.sh shell${NC}"
    echo -e "  Status:  ${CYAN}cd $INSTALL_DIR && ./df-manager.sh status${NC}"
    echo
    echo -e "${WHITE}Data Directories:${NC}"
    echo -e "  Saves:   ${CYAN}$INSTALL_DIR/saves/${NC}"
    echo -e "  Logs:    ${CYAN}$INSTALL_DIR/logs/${NC}"
    echo -e "  Output:  ${CYAN}$INSTALL_DIR/output/${NC}"
    echo -e "  Config:  ${CYAN}$INSTALL_DIR/config/${NC}"
    echo
    echo -e "${WHITE}VNC Connection:${NC}"
    echo -e "  Host: ${CYAN}$(hostname -I | awk '{print $1}')${NC}"
    echo -e "  Port: ${CYAN}$VNC_PORT${NC}"
    echo -e "  Password: ${CYAN}None required${NC}"
    echo
    echo -e "${YELLOW}🎮 Happy Fortress Building! 🎮${NC}"
    echo
}

# Cleanup function
cleanup() {
    if [[ -f build.log ]]; then
        rm -f build.log
    fi
}

# Signal handlers
trap cleanup EXIT
trap 'msg_error "Installation interrupted"; exit 1' INT TERM

# Main installation flow
main() {
    clear
    header_info
    echo
    echo -e "${CYAN}Welcome to the Dwarf Fortress Container installer!${NC}"
    echo -e "${WHITE}This script will install and configure Dwarf Fortress with DFHack in a Docker container.${NC}"
    echo
    
    check_requirements
    get_options
    clone_repository
    configure_installation
    build_container
    create_service
    start_container
    show_summary
}

# Run main function
main "$@"
