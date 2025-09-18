# iPhone Setup Guide for Dwarf Fortress Container

## 📱 **Quick Start**

### **Step 1: Download VNC Viewer**
1. Open App Store on your iPhone
2. Search for "VNC Viewer"
3. Download the free app by RealVNC

### **Step 2: Connect to VNC**
1. Open VNC Viewer
2. Tap the "+" button
3. Enter connection details:
   - **Address**: `192.168.4.90:5900`
   - **Name**: `Dwarf Fortress Server`
   - **Password**: Leave blank
4. Tap "Save" then "Connect"

### **Step 3: Access Web Interface**
Open Safari and go to:
- **Mobile Interface**: `http://192.168.4.90:3000/mobile`
- **Full Dashboard**: `http://192.168.4.90:3000`
- **API Status**: `http://192.168.4.90:8080/api/health`

## 🎮 **iPhone Gaming Tips**

### **Touch Controls**
- **Tap**: Left mouse click
- **Long Press**: Right mouse click
- **Pinch**: Zoom in/out
- **Two-finger drag**: Scroll
- **Three-finger tap**: Middle mouse click

### **Performance Optimization**
- **Use WiFi**: Avoid cellular for better performance
- **Landscape Mode**: Better for gaming
- **Lower VNC Quality**: Adjust in VNC Viewer settings
- **Close Background Apps**: Free up memory

### **VNC Viewer Settings**
1. Open VNC Viewer
2. Tap the connection name
3. Tap "Edit"
4. Adjust settings:
   - **Quality**: Medium or Low for better performance
   - **Scaling**: Fit to screen
   - **Color Depth**: 16-bit for faster connection

## 🔧 **Troubleshooting**

### **Connection Issues**
- **Check WiFi**: Ensure iPhone is on same network as server
- **Test Connection**: Try pinging `192.168.4.90` from iPhone
- **Restart VNC**: Restart the container if needed

### **Performance Issues**
- **Reduce Quality**: Lower VNC quality settings
- **Close Apps**: Close other apps on iPhone
- **WiFi Only**: Don't use cellular data

### **Touch Issues**
- **Calibrate**: Use VNC Viewer's touch calibration
- **Zoom**: Pinch to zoom for better precision
- **Orientation**: Try landscape mode

## 📱 **Mobile Web Interface**

The mobile web interface (`http://192.168.4.90:3000/mobile`) provides:
- **Container Controls**: Start/stop/restart containers
- **Status Monitoring**: Real-time container status
- **Quick Access**: Direct links to all services
- **Touch-Friendly**: Optimized for mobile use

## 🎯 **What You Can Do**

### **From VNC (Direct Game Access)**
- Play Dwarf Fortress directly
- Use DFHack commands
- Access terminal/command line
- Full desktop environment

### **From Web Interface (Management)**
- Monitor container status
- Control containers (start/stop/restart)
- View logs and statistics
- Access API endpoints
- Manage saves and data

## 🔒 **Security Notes**

- **No Password**: Current setup has no VNC password
- **Local Network**: Only accessible from same WiFi network
- **Firewall**: Port 5900 should be blocked from internet

## 🚀 **Quick Commands**

Once connected via VNC, try these commands:
```bash
# Check if DFHack is working
./dfhack --version

# Start Dwarf Fortress
./dfhack

# Export fortress data
script /opt/dwarf-fortress/scripts/export_fortress_data.lua

# Check API status
curl http://localhost:8080/api/health
```

## 📞 **Support**

If you encounter issues:
1. Check the web management interface: `http://192.168.4.90:3000`
2. View logs: `http://192.168.4.90:3000/logs`
3. API health check: `http://192.168.4.90:8080/api/health`

## 🎮 **Enjoy Gaming!**

You now have full access to Dwarf Fortress from your iPhone! 🏰⛏️