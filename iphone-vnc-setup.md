# iPhone RealVNC Connection Guide

## 🔐 **Fixed Authentication Issue**

The "authentication method requested can't be provided by this computer" error has been **FIXED**! 

Your VNC server now uses iPhone-compatible authentication methods.

---

## 📱 **iPhone RealVNC Setup**

### **Connection Method 1: Direct Connection (Easiest)**

**Step 1: Open RealVNC Viewer on iPhone**

**Step 2: Add New Connection**
- Tap the "+" button
- Choose "Add connection"

**Step 3: Enter Connection Details**
- **Address**: `100.112.142.83:5900`
- **Name**: `Dwarf Fortress Server`
- **Password**: `password`

**Step 4: Connect**
- Tap "Connect"
- The authentication should now work!

---

### **Connection Method 2: SSL Encrypted Connection**

**Step 1: Add SSL Connection**
- **Address**: `100.112.142.83:5901`
- **Name**: `Dwarf Fortress SSL`
- **Password**: `password`
- **Protocol**: Select "SSL" or "Encrypted"

**Step 2: Accept Certificate**
- When prompted, accept the self-signed certificate
- This is safe since you control the server

---

## 🛡️ **Security Options**

### **Option A: SSH Tunnel (Most Secure)**

**For maximum security, use SSH tunneling:**

**Step 1: Install SSH Client**
- Download "Terminal" or "SSH Client" from App Store
- Or use "Termux" for advanced users

**Step 2: Create SSH Tunnel**
```bash
ssh -L 5900:127.0.0.1:5900 root@100.112.142.83
```

**Step 3: Connect RealVNC**
- **Address**: `127.0.0.1:5900`
- **Password**: `password`

---

## 🔧 **Troubleshooting**

### **Still Getting Authentication Error?**

**Try these solutions:**

1. **Clear RealVNC Cache**
   - Delete and re-add the connection
   - Restart RealVNC app

2. **Check Network**
   - Ensure you're connected to Tailscale VPN
   - Verify you can ping `100.112.142.83`

3. **Try Different Port**
   - Port 5900: Standard VNC
   - Port 5901: SSL VNC

4. **Update RealVNC**
   - Make sure you have the latest version

### **Connection Refused?**

**Check these:**
- Tailscale VPN is connected
- Server is running: `docker ps | grep dwarf-fortress`
- Firewall allows your connection

---

## 📊 **Current Server Status**

✅ **Standard VNC**: Port 5900 (iPhone compatible)  
✅ **SSL VNC**: Port 5901 (Encrypted)  
✅ **Password**: `password`  
✅ **Authentication**: iPhone compatible  
✅ **Tailscale IP**: `100.112.142.83`  

---

## 🎯 **Quick Connection Steps**

1. **Open RealVNC Viewer**
2. **Add Connection**:
   - Address: `100.112.142.83:5900`
   - Password: `password`
3. **Connect** ✅

**That's it!** The authentication error should be resolved.

---

## 🔒 **Security Notes**

- **Password**: `password` (consider changing this)
- **Network**: Only accessible via Tailscale VPN
- **Encryption**: Available on port 5901
- **SSH Tunnel**: Recommended for maximum security

Your iPhone RealVNC connection should now work perfectly! 🎉