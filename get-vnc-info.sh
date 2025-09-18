#!/bin/bash

# Get VNC connection information
echo "🏰 Dwarf Fortress VNC Access Information"
echo "========================================"

# Get external IP
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "Unable to determine")

# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "Unable to determine")

echo ""
echo "📱 For Terminus Mobile App:"
echo "   Host: $EXTERNAL_IP"
echo "   Port: 5900"
echo "   Protocol: VNC"
echo ""
echo "🏠 For Local Network Access:"
echo "   Host: $LOCAL_IP"
echo "   Port: 5900"
echo "   Protocol: VNC"
echo ""
echo "🌐 Web Management Interface:"
echo "   Dashboard: http://$EXTERNAL_IP:3000"
echo "   API: http://$EXTERNAL_IP:8080"
echo "   Dashy: http://$EXTERNAL_IP:4000"
echo ""
echo "📋 Terminus Configuration:"
echo "   1. Open Terminus app"
echo "   2. Add new connection"
echo "   3. Select 'VNC' protocol"
echo "   4. Enter Host: $EXTERNAL_IP"
echo "   5. Enter Port: 5900"
echo "   6. Save and connect"
echo ""
echo "⚠️  Security Note:"
echo "   VNC is configured without password for convenience."
echo "   Consider adding authentication for production use."