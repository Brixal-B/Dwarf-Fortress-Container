#!/bin/bash

echo "Starting Dwarf Fortress container..."

# Start Xvfb for headless display
echo "Starting X virtual framebuffer..."
Xvfb :99 -screen 0 1024x768x24 &
XVFB_PID=$!

# Wait for X server to be ready
echo "Waiting for X server to initialize..."
sleep 3

# Verify X server is running
DISPLAY=:99 xdpyinfo >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "X server is ready on display :99"
else
    echo "Warning: X server may not be fully ready"
fi

# Start window manager for headless operation
fluxbox &
WM_PID=$!

# Create VNC password file if it doesn't exist
if [ ! -f ~/.vnc/.vncpasswd ]; then
    echo "Creating VNC password file..."
    mkdir -p ~/.vnc
    # Generate a random password and store it
    VNC_PASSWORD=$(openssl rand -base64 12)
    echo "$VNC_PASSWORD" | x11vnc -storepasswd /dev/stdin ~/.vnc/.vncpasswd
    echo "VNC Password: $VNC_PASSWORD" > ~/.vnc/.vncpasswd.info
    echo "VNC Password: $VNC_PASSWORD"
    echo "VNC Password saved to ~/.vnc/.vncpasswd"
else
    echo "Using existing VNC password from ~/.vnc/.vncpasswd"
    echo "VNC Password: $(cat ~/.vnc/.vncpasswd.info 2>/dev/null | grep 'VNC Password:' | cut -d' ' -f3)"
fi

# Start VNC server for remote access with password authentication
echo "Starting secure VNC server on port 5900..."
# Listen on both localhost and Tailscale interface for VPN access
# Use passwd for iPhone RealVNC compatibility
x11vnc -display :99 -passwd password -listen 0.0.0.0 -xkb -rfbport 5900 -forever -shared &
VNC_PID=$!

# Start SSL-encrypted VNC server on port 5901
echo "Starting SSL-encrypted VNC server on port 5901..."
# Use passwd for iPhone RealVNC compatibility
x11vnc -display :99 -passwd password -listen 0.0.0.0 -xkb -rfbport 5901 -ssl SAVE -forever -shared &
VNC_SSL_PID=$!

echo "Display server started on :99 (headless mode)"
echo "VNC server started on port 5900 for remote access"

# Change to DF directory
cd /opt/dwarf-fortress/df

echo "Available commands:"
echo "  ./df - Run Dwarf Fortress"
echo "  ./dfhack - Run Dwarf Fortress with DFHack"
echo "  ./dfhack-run - Run DFHack scripts"

# Start API server in background
echo "Starting Dwarf Fortress API server on port 8080..."
cd /opt/dwarf-fortress
python3 df_api_server.py &
API_PID=$!
echo "API server started (PID: $API_PID)"

# Return to DF directory
cd /opt/dwarf-fortress/df

echo ""
echo "Starting DFHack-enabled Dwarf Fortress..."

# Function to cleanup on exit
cleanup() {
    echo "Cleaning up..."
    kill $XVFB_PID $WM_PID $VNC_PID $VNC_SSL_PID $API_PID 2>/dev/null || true
    exit
}

# Set trap for cleanup
trap cleanup SIGTERM SIGINT

# Check if running in interactive mode
if [ -t 0 ]; then
    echo "Interactive mode detected. Starting bash shell."
    echo "Run './dfhack' to start Dwarf Fortress with DFHack support."
    exec /bin/bash
else
    echo "Non-interactive mode. Starting DFHack directly."
    # Run DFHack in the background and wait
    ./dfhack &
    DF_PID=$!
    wait $DF_PID
fi
