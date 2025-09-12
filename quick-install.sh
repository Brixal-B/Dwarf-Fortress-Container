#!/usr/bin/env bash

# Quick Install Script - Minimal version for copy-paste
# This is the ultra-simplified version like Proxmox Helper Scripts

set -e

# Colors
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
R='\033[0;31m'
NC='\033[0m'

echo -e "${B}🏰 Dwarf Fortress Container Quick Install${NC}"
echo -e "${Y}Installing Dwarf Fortress + DFHack in Docker...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${Y}Installing Docker...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo -e "${R}Please log out and back in, then run this script again.${NC}"
    exit 1
fi

# Install directory
INSTALL_DIR="/opt/dwarf-fortress"
echo -e "${Y}Installing to: ${INSTALL_DIR}${NC}"

# Create directory and clone
sudo mkdir -p $INSTALL_DIR
sudo chown $USER:$USER $INSTALL_DIR
cd $INSTALL_DIR

if [[ ! -d ".git" ]]; then
    git clone https://github.com/Brixal-B/dwarf-fortress-container.git .
fi

# Make executable and start
chmod +x df-manager.sh
echo -e "${Y}Building and starting container...${NC}"
./df-manager.sh start

# Get IP for VNC connection
IP=$(hostname -I | awk '{print $1}')

echo -e "${G}✅ Installation Complete!${NC}"
echo -e "${B}VNC Access: ${IP}:5900${NC}"
echo -e "${B}Manage: cd ${INSTALL_DIR} && ./df-manager.sh [start|stop|logs|shell]${NC}"
