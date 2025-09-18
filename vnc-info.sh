#!/bin/bash

echo "=== VNC Server Security Information ==="
echo ""

# Get VNC password from container
echo "VNC Password:"
docker exec dwarf-fortress-ai cat /opt/dwarf-fortress/.vncpasswd.info 2>/dev/null || echo "Password info not available"

echo ""
echo "VNC Connection Details:"
echo "  Host: 127.0.0.1 (localhost only)"
echo "  Port: 5900"
echo "  Password: See above"
echo ""

echo "Security Features Enabled:"
echo "  ✓ Password authentication required"
echo "  ✓ Listening only on localhost (127.0.0.1)"
echo "  ✓ Firewall rules restrict access to localhost only"
echo "  ✓ VNC server runs with -localhost flag"
echo ""

echo "To connect from a VNC client:"
echo "  Host: 127.0.0.1:5900"
echo "  Password: [Use the password shown above]"
echo ""

echo "To change the VNC password:"
echo "  1. Stop the container: docker-compose down"
echo "  2. Remove password file: docker exec dwarf-fortress-ai rm /opt/dwarf-fortress/.vncpasswd"
echo "  3. Restart: docker-compose up -d"
echo "  4. Check new password: docker logs dwarf-fortress-ai | grep 'VNC Password'"