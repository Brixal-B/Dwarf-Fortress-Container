#!/bin/bash

echo "Starting Dwarf Fortress container..."

# Start Xvfb for headless display
Xvfb :99 -screen 0 1024x768x24 &
XVFB_PID=$!

# Start VNC server (optional, for remote access)
x11vnc -display :99 -forever -nopw -quiet -listen 0.0.0.0 -xkb &
VNC_PID=$!

# Start window manager
fluxbox &
WM_PID=$!

echo "Display server started on :99"
echo "VNC server available on port 5900 (no password)"

# Change to DF directory
cd /opt/dwarf-fortress/df

echo "Available commands:"
echo "  ./df - Run Dwarf Fortress"
echo "  ./dfhack - Run Dwarf Fortress with DFHack"
echo "  ./dfhack-run - Run DFHack scripts"

echo ""
echo "Starting DFHack-enabled Dwarf Fortress..."

# Function to cleanup on exit
cleanup() {
    echo "Cleaning up..."
    kill $XVFB_PID $VNC_PID $WM_PID 2>/dev/null || true
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
