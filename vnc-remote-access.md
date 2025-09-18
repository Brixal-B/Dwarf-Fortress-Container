# VNC Remote Access Guide

## 🔐 Current VNC Configuration
- **Tailscale IP**: `100.112.142.83`
- **VNC Port**: `5900`
- **VNC Password**: `5CnJ2lhJxUVGKLVt`
- **Security**: Password protected, accessible only via Tailscale VPN

## 📱 How to Connect from Remote Devices

### Option 1: Direct VNC Connection (Easiest)
**From any device connected to your Tailscale VPN:**

1. **Install a VNC client:**
   - **Windows**: RealVNC Viewer, TightVNC, UltraVNC
   - **macOS**: Built-in Screen Sharing, RealVNC Viewer
   - **iOS/Android**: VNC Viewer by RealVNC
   - **Linux**: `sudo apt install vinagre` or `sudo apt install remmina`

2. **Connect using:**
   - **Host**: `100.112.142.83:5900`
   - **Password**: `5CnJ2lhJxUVGKLVt`

### Option 2: SSH Tunnel (Most Secure)
**For additional security, use SSH tunneling:**

1. **On your remote device, run:**
   ```bash
   ssh -L 5900:127.0.0.1:5900 root@100.112.142.83
   ```

2. **Then connect VNC client to:**
   - **Host**: `127.0.0.1:5900` (localhost)
   - **Password**: `5CnJ2lhJxUVGKLVt`

## 🔧 Management Commands

### Get Current VNC Info
```bash
cd /root/dwarf-fortress-container
./vnc-info.sh
```

### Change VNC Password
```bash
cd /root/dwarf-fortress-container
docker-compose down
docker exec dwarf-fortress-ai rm /opt/dwarf-fortress/.vncpasswd
docker-compose up -d
docker logs dwarf-fortress-ai | grep "VNC Password"
```

### Check VNC Status
```bash
docker exec dwarf-fortress-ai ps aux | grep x11vnc
ss -tlnp | grep 5900
```

## 🛡️ Security Features
- ✅ Password authentication required
- ✅ Accessible only via Tailscale VPN (100.x.x.x network)
- ✅ Firewall rules block external access
- ✅ VNC traffic encrypted through Tailscale

## 📋 Troubleshooting

### Can't Connect?
1. **Check Tailscale connection**: Ensure your device is connected to Tailscale
2. **Verify IP**: Confirm the Tailscale IP is still `100.112.142.83`
3. **Check firewall**: `iptables -L INPUT -n | grep 5900`
4. **Test connectivity**: `ping 100.112.142.83`

### Connection Refused?
1. **Check container status**: `docker ps | grep dwarf-fortress`
2. **Check VNC process**: `docker exec dwarf-fortress-ai ps aux | grep x11vnc`
3. **Restart container**: `docker-compose restart dwarf-fortress`

### Wrong Password?
1. **Get current password**: `docker logs dwarf-fortress-ai | grep "VNC Password"`
2. **Reset password**: Follow the "Change VNC Password" steps above