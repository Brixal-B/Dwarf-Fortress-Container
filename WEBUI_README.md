# 🌐 Web Management UI for Dwarf Fortress Container

A comprehensive web-based management interface for the Dwarf Fortress container ecosystem, providing real-time monitoring, container control, and system management capabilities.

## 🚀 Features

### 📊 Dashboard Overview
- **Real-time Container Status**: Monitor all containers (dwarf-fortress, dashy, web-manager)
- **Service Health Monitoring**: Check API server and Dashy dashboard connectivity
- **Resource Usage Charts**: Visual representation of CPU, memory, and storage usage
- **Quick Actions**: Start, stop, restart, and rebuild containers with one click
- **Fortress Statistics**: Integration with the Dwarf Fortress API for game data

### 🔧 Container Management
- **Individual Container Control**: Manage each service independently
- **Bulk Operations**: Control all containers simultaneously
- **Real-time Log Viewing**: Stream and filter container logs
- **Build Management**: Trigger container rebuilds with optional cache clearing
- **Health Monitoring**: Automatic health checks for all services

### 📋 Log Management
- **Multi-service Logs**: View logs from all containers in one interface
- **Real-time Streaming**: Auto-refreshing log display
- **Advanced Filtering**: Filter by log level (ERROR, WARN, INFO, DEBUG)
- **Search Functionality**: Full-text search with regex support
- **Export Capability**: Download logs for offline analysis

### ⚙️ Configuration Management
- **Environment Variables**: Edit .env file through web interface
- **Resource Limits**: Configure CPU and memory constraints
- **Backup Operations**: Create and restore system backups
- **System Maintenance**: Docker cleanup and container updates

### 🏰 Fortress Statistics
- **Live Game Data**: Real-time fortress statistics from DFHack API
- **Population Analytics**: Detailed population breakdown with charts
- **Wealth Analysis**: Economic overview with category breakdowns
- **Data Export**: Export fortress data as JSON

## 🛠️ Installation & Setup

### Quick Start

The web management interface is included in the main docker-compose.yml and will start automatically:

```bash
# Clone and setup (if not already done)
git checkout webui-management
docker-compose up --build
```

### Access Points

Once running, access the services at:

- **Web Management UI**: http://localhost:3000
- **Dwarf Fortress API**: http://localhost:8080
- **Dashy Dashboard**: http://localhost:4000

### Service Architecture

```
┌─────────────────────────────────────────────────────┐
│                  HOST SYSTEM                        │
│  ┌─────────────────────────────────────────────┐   │
│  │            DOCKER ENVIRONMENT               │   │
│  │                                             │   │
│  │  ┌─────────────┐  ┌─────────────┐          │   │
│  │  │   Dwarf     │  │    Dashy    │          │   │
│  │  │  Fortress   │  │  Dashboard  │          │   │
│  │  │ (+ DFHack)  │  │             │          │   │
│  │  │    :8080    │  │    :4000    │          │   │
│  │  └─────────────┘  └─────────────┘          │   │
│  │                                             │   │
│  │  ┌─────────────────────────────────────┐   │   │
│  │  │        Web Management UI           │   │   │
│  │  │                                     │   │   │
│  │  │  • Container Control               │   │   │
│  │  │  • Log Management                  │   │   │
│  │  │  • System Monitoring               │   │   │
│  │  │  • Configuration                   │   │   │
│  │  │                                     │   │   │
│  │  │            :3000                    │   │   │
│  │  └─────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## 🎮 Usage Guide

### Dashboard Navigation

1. **Dashboard Tab**: System overview and quick actions
2. **Fortress Tab**: Game statistics and analytics
3. **Logs Tab**: Container log management
4. **Config Tab**: System configuration

### Container Management

#### Start/Stop/Restart Containers
```
Dashboard → Quick Actions → [Start All] [Stop All] [Restart All]
```

#### Individual Container Control
- Each container card has dedicated control buttons
- Real-time status updates
- Automatic health monitoring

#### View Container Logs
```
Logs Tab → Select Service → Choose Lines → Refresh
```

### Fortress Data Integration

#### Enable Live Data
1. Start Dwarf Fortress via Dashy dashboard
2. In DFHack console, run:
   ```
   script /opt/dwarf-fortress/scripts/export_fortress_data.lua
   ```
3. Data appears automatically in Fortress tab

#### Data Features
- **Population Charts**: Pie chart of dwarves, animals, military, visitors
- **Wealth Breakdown**: Bar chart of weapons, armor, furniture, other
- **Real-time Updates**: Automatic refresh every 30 seconds
- **Export Capability**: Download data as JSON

### Configuration Management

#### Environment Variables
- Edit .env file through web interface
- Compose project name configuration
- API port settings

#### Resource Management
- CPU and memory limits (UI ready, implementation in progress)
- Container resource monitoring
- System cleanup tools

## 🔧 Technical Details

### Technology Stack

**Backend**:
- Flask 2.3.3 (Python web framework)
- Docker API integration
- Real-time subprocess management
- JSON configuration handling

**Frontend**:
- Bootstrap 5.3.0 (responsive design)
- Chart.js (data visualization)
- Vanilla JavaScript (no heavy frameworks)
- Progressive Web App features

**Container Integration**:
- Docker Socket mounting for container control
- Compose file management
- Health check integration
- Log streaming

### Security Features

- **Non-root Container**: Web manager runs as unprivileged user
- **Read-only Mounts**: Project files mounted read-only
- **Resource Limits**: CPU/memory constraints applied
- **Health Monitoring**: Automatic failure detection

### File Structure

```
/root/dwarf-fortress-container/
├── web_management_server.py    # Main Flask application
├── Dockerfile.webmanager       # Container definition
├── requirements.webmanager.txt # Python dependencies
├── templates/                  # HTML templates
│   ├── base.html              # Common layout
│   ├── dashboard.html         # Main dashboard
│   ├── logs.html              # Log viewer
│   ├── config.html            # Configuration
│   └── fortress.html          # Game statistics
└── static/                     # Static assets (if needed)
```

## 🎯 API Endpoints

### Container Management
- `GET /api/status` - Full system status
- `GET /api/containers` - Container list
- `POST /api/start` - Start containers
- `POST /api/stop` - Stop containers
- `POST /api/restart` - Restart containers
- `POST /api/build` - Build containers

### Log Management
- `GET /api/logs?service=<name>&lines=<count>` - Get logs

### Configuration
- `GET /api/config` - Get configuration
- `POST /api/config` - Update configuration

### Fortress Data
- `GET /api/fortress-stats` - Proxy to fortress API

## 🚨 Troubleshooting

### Web UI Not Accessible
```bash
# Check web manager container
docker-compose ps web-manager

# View web manager logs
docker-compose logs web-manager

# Restart web manager
docker-compose restart web-manager
```

### Container Control Issues
```bash
# Verify Docker socket permissions
ls -la /var/run/docker.sock

# Check web manager has Docker access
docker-compose exec web-manager docker ps
```

### Fortress Data Not Loading
1. Ensure Dwarf Fortress container is running
2. Check API server at http://localhost:8080/api/health
3. Run DFHack export script in game
4. Verify output directory has fortress_data.json

### Log Viewing Problems
```bash
# Check log directory permissions
ls -la logs/

# Verify container has access to logs
docker-compose logs dwarf-fortress
```

## 🔄 Updates & Maintenance

### Updating the Web UI
```bash
# Pull latest changes
git pull origin webui-management

# Rebuild web manager
docker-compose build web-manager

# Restart services
docker-compose restart web-manager
```

### Backup Configuration
The web UI includes backup functionality in Config → Backup tab:
- Create system backups
- Export configuration
- Restore previous states

## 🤝 Contributing

To extend the web management interface:

1. **Backend Extensions**: Add routes to `web_management_server.py`
2. **Frontend Features**: Extend templates with new functionality
3. **Container Integration**: Modify Docker Compose for new services
4. **API Integration**: Add new endpoints for additional data sources

## 📝 Changelog

### Version 1.0.0 (Current)
- ✅ Complete dashboard with real-time monitoring
- ✅ Container management (start/stop/restart/build)
- ✅ Advanced log viewer with filtering and search
- ✅ Configuration management interface
- ✅ Fortress statistics integration
- ✅ Responsive design for mobile/desktop
- ✅ Health monitoring and alerts
- ✅ Resource usage visualization

### Future Enhancements
- 🔄 Advanced backup/restore functionality
- 🔄 User authentication and access control
- 🔄 Custom dashboard widgets
- 🔄 Advanced DFHack script management
- 🔄 Performance metrics history
- 🔄 Container orchestration scheduling

---

🏰 **Happy Fortress Management!** 🏰

The web management interface provides a comprehensive solution for managing your Dwarf Fortress container environment. Whether you're monitoring system performance, analyzing fortress data, or troubleshooting issues, everything is accessible through an intuitive web interface.
