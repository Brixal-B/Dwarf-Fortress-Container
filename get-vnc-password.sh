#!/bin/bash

echo "=== VNC Connection Information ==="
echo ""
echo "Tailscale IP: 100.112.142.83"
echo "VNC Port: 5900"
echo ""

# Get current password from container
echo "Current VNC Password:"
docker exec dwarf-fortress-ai cat /home/dfuser/.vncpasswd.info 2>/dev/null || echo "Password info not available"

echo ""
echo "Connection Details:"
echo "  Host: 100.112.142.83:5900"
echo "  Password: [See above]"
echo ""
echo "To connect from any device on your Tailscale VPN:"
echo "  1. Install a VNC client"
echo "  2. Connect to: 100.112.142.83:5900"
echo "  3. Use the password shown above"
echo ""
echo "VNC Status:"
docker exec dwarf-fortress-ai ps aux | grep x11vnc | grep -v grep && echo "✓ VNC server is running" || echo "✗ VNC server is not running"