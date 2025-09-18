#!/bin/bash

echo "🔧 Mobile Connection Test Script"
echo "=================================="
echo ""

# Get server IP addresses
echo "📍 Server IP Addresses:"
hostname -I | tr ' ' '\n' | grep -E '^(192\.168\.|10\.|172\.|100\.)' | while read ip; do
    echo "   - $ip"
done
echo ""

# Test VNC ports
echo "🔌 Testing VNC Ports:"
for port in 5900 5901; do
    if ss -tuln | grep -q ":$port "; then
        echo "   ✅ Port $port is open"
    else
        echo "   ❌ Port $port is closed"
    fi
done
echo ""

# Test Web ports
echo "🌐 Testing Web Ports:"
for port in 3000 4000 8080; do
    if ss -tuln | grep -q ":$port "; then
        echo "   ✅ Port $port is open"
    else
        echo "   ❌ Port $port is closed"
    fi
done
echo ""

# Test API endpoint
echo "🚀 Testing API Health:"
if curl -s --connect-timeout 5 http://localhost:8080/api/health > /dev/null; then
    echo "   ✅ API server is responding"
    curl -s http://localhost:8080/api/health | python3 -c "import sys, json; print('   📊 Status:', json.load(sys.stdin)['status'])" 2>/dev/null || echo "   📊 API responding but response format unexpected"
else
    echo "   ❌ API server is not responding"
fi
echo ""

# VNC process check
echo "📺 VNC Server Status:"
if pgrep -f "x11vnc.*5900" > /dev/null; then
    echo "   ✅ Standard VNC server (port 5900) is running"
else
    echo "   ❌ Standard VNC server (port 5900) is not running"
fi

if pgrep -f "x11vnc.*5901" > /dev/null; then
    echo "   ✅ SSL VNC server (port 5901) is running"
else
    echo "   ❌ SSL VNC server (port 5901) is not running"
fi
echo ""

# Container status
echo "🐳 Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(dwarf|dashy|manager)" || echo "   ❌ No mobile containers running"
echo ""

echo "📱 Mobile Connection Summary:"
echo "   Use VNC Viewer app with:"
echo "   - Address: [Your_Server_IP]:5900"
echo "   - Password: password"
echo ""
echo "   Access web interface at:"
echo "   - http://[Your_Server_IP]:3000/mobile"
echo ""
echo "Replace [Your_Server_IP] with one of the IP addresses listed above."

