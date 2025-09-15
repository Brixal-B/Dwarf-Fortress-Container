# Dwarf Fortress API Integration

This document explains how to use the newly added API server for dashboard integration with Dashy or other tools.

## 🚀 Quick Start

The API server automatically starts with your Dwarf Fortress container and provides real-time fortress data.

### Test the API

```bash
# Health check
curl http://localhost:8080/api/health

# Get fortress statistics
curl http://localhost:8080/api/fortress-stats

# Get population data
curl http://localhost:8080/api/fortress-stats/population
```

## 📊 Available Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Server health check |
| `/api/fortress-stats` | GET | Complete fortress statistics |
| `/api/fortress-stats/population` | GET | Detailed population data |
| `/api/fortress-stats/wealth` | GET | Wealth breakdown |
| `/api/saves` | GET | List available save files |
| `/api/logs` | GET | Recent game logs |
| `/api/output-files` | GET | List exported data files |
| `/api/export-data` | POST | Trigger data export |

## 🎮 Data Export from Game

### Manual Export
Run this command in DFHack console:
```
script /opt/dwarf-fortress/scripts/export_fortress_data.lua
```

### Automatic Export
The script can be scheduled to run periodically. Data is saved to `/opt/dwarf-fortress/output/fortress_data.json`.

## 🖥️ Dashy Dashboard Integration

### 1. Copy Example Configuration
```bash
cp dashy-example.yml /path/to/your/dashy/conf.yml
```

### 2. Docker Compose with Dashy
Add this to your `docker-compose.yml`:

```yaml
services:
  dwarf-fortress:
    # ... existing configuration
    
  dashy:
    image: lissy93/dashy:latest
    container_name: dashy-df
    ports:
      - "4000:80"
    volumes:
      - ./dashy-example.yml:/app/public/conf.yml
    depends_on:
      - dwarf-fortress
    restart: unless-stopped
```

### 3. Access Dashboard
- Dashboard: http://localhost:4000
- VNC Game Access: vnc://localhost:5900
- API Direct: http://localhost:8080/api/health

## 📁 Data Structure

### Fortress Stats Response
```json
{
  "timestamp": "2024-01-15T14:30:00Z",
  "fortress_info": {
    "name": "Mountainhomes",
    "year": 125,
    "season": "Late Spring"
  },
  "population": {
    "total": 156,
    "dwarves": 134,
    "animals": 22,
    "military": 8
  },
  "wealth": {
    "total": 485230,
    "weapons": 12450,
    "armor": 8900,
    "furniture": 234500
  },
  "status": {
    "mood": "Content",
    "alerts": []
  }
}
```

## 🔧 Customization

### Adding Custom Endpoints
Edit `df_api_server.py` to add new endpoints:

```python
@app.route('/api/custom-data')
def custom_data():
    # Your custom logic here
    return jsonify({"custom": "data"})
```

### Custom DFHack Export Scripts
Create scripts in `/opt/dwarf-fortress/scripts/` and run them via:
```
script /opt/dwarf-fortress/scripts/your_script.lua
```

### Widget Configuration
Dashy widgets support various data transformations:

```yaml
- type: api-data
  title: "Custom Widget"
  options:
    url: http://localhost:8080/api/fortress-stats
    dataPath: population.dwarves
    prefix: "👥 "
    suffix: " citizens"
    # Transform data
    multiplier: 1
    round: 0
```

## 🐛 Troubleshooting

### API Server Not Starting
```bash
# Check if port is available
docker-compose logs dwarf-fortress | grep "8080"

# Restart container
docker-compose restart dwarf-fortress
```

### No Data Available
```bash
# Check if game is running and data exported
curl http://localhost:8080/api/fortress-stats

# Manually trigger export
curl -X POST http://localhost:8080/api/export-data
```

### CORS Issues
The API server includes CORS headers. If issues persist, use Dashy's proxy:

```yaml
- type: api-data
  useProxy: true
  options:
    url: http://localhost:8080/api/fortress-stats
```

## 🔐 Security Notes

- API runs on localhost by default
- No authentication implemented (suitable for local use)
- For remote access, consider adding authentication
- Data files are accessible via mounted volumes

## 📈 Performance

- API responses are lightweight JSON
- Data updates when DFHack script runs
- Dashy widgets refresh every 30 seconds by default
- Minimal impact on game performance

## 🆕 What's New

✅ **Added Features:**
- Flask API server with 8 endpoints
- Enhanced DFHack Lua export script
- Complete Dashy dashboard configuration
- Automatic API server startup
- Sample data generation for testing
- Comprehensive error handling
- CORS support for web integration

The fortress data is now ready for beautiful dashboard visualization! 🏰
