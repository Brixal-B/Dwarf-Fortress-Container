#!/bin/bash

# Test script for ARM-compatible Dwarf Fortress setup

echo "🧪 Testing ARM-Compatible Dwarf Fortress Setup"
echo "=============================================="

# Test 1: Check if Docker is running
echo "📦 Testing Docker..."
if docker --version > /dev/null 2>&1; then
    echo "✅ Docker is available"
    docker --version
else
    echo "❌ Docker not found"
    exit 1
fi

# Test 2: Check Docker Compose
echo "🔧 Testing Docker Compose..."
if docker-compose --version > /dev/null 2>&1; then
    echo "✅ Docker Compose is available"
    docker-compose --version
else
    echo "❌ Docker Compose not found"
    exit 1
fi

# Test 3: Check ARM architecture
echo "🏗️ Testing Architecture..."
ARCH=$(uname -m)
echo "Current architecture: $ARCH"

if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    echo "✅ ARM64 architecture detected"
    echo "💡 Using ARM-compatible setup"
    COMPOSE_FILE="docker-compose.arm.yml"
else
    echo "ℹ️ Non-ARM architecture detected"
    echo "💡 Using standard x86 setup with emulation"
    COMPOSE_FILE="docker-compose.yml"
fi

# Test 4: Check if compose file exists
echo "📋 Testing Compose File..."
if [ -f "$COMPOSE_FILE" ]; then
    echo "✅ $COMPOSE_FILE found"
else
    echo "❌ $COMPOSE_FILE not found"
    exit 1
fi

# Test 5: Validate compose file
echo "🔍 Validating Compose File..."
if docker-compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
    echo "✅ Compose file is valid"
else
    echo "❌ Compose file validation failed"
    docker-compose -f "$COMPOSE_FILE" config
    exit 1
fi

# Test 6: Check required directories
echo "📁 Testing Directories..."
for dir in saves logs output; do
    if [ -d "$dir" ]; then
        echo "✅ $dir directory exists"
    else
        echo "⚠️ $dir directory missing, creating..."
        mkdir -p "$dir"
    fi
done

# Test 7: Check network connectivity
echo "🌐 Testing Network..."
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "✅ Internet connectivity available"
else
    echo "⚠️ No internet connectivity"
fi

# Test 8: Check available ports
echo "🔌 Testing Ports..."
for port in 3000 4000 5900 8080; do
    if netstat -tlnp 2>/dev/null | grep ":$port " > /dev/null; then
        echo "⚠️ Port $port is already in use"
    else
        echo "✅ Port $port is available"
    fi
done

echo ""
echo "🎯 Setup Summary:"
echo "=================="
echo "Architecture: $ARCH"
echo "Compose File: $COMPOSE_FILE"
echo "Status: Ready to deploy"

echo ""
echo "🚀 Next Steps:"
echo "=============="
echo "1. Run: docker-compose -f $COMPOSE_FILE up --build -d"
echo "2. Access web interface: http://192.168.4.90:3000"
echo "3. Connect VNC: 192.168.4.90:5900"
echo "4. Mobile interface: http://192.168.4.90:3000/mobile"

echo ""
echo "✅ ARM setup test completed successfully!"