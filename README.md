# Dwarf Fortress Docker Container for AI Analysis

[![Build and Test Docker Image](https://github.com/username/dwarf-fortress-container/actions/workflows/docker-build.yml/badge.svg)](https://github.com/username/dwarf-fortress-container/actions/workflows/docker-build.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/username/dwarf-fortress-ai.svg)](https://hub.docker.com/r/username/dwarf-fortress-ai)

This Docker container provides a ready-to-use environment for running Dwarf Fortress with DFHack, specifically designed for AI analysis of game outputs.

## Features

- **Dwarf Fortress**: Latest stable version (50.14)
- **DFHack**: Latest compatible version with scripting capabilities
- **Headless Operation**: Runs with Xvfb for server environments
- **VNC Access**: Remote desktop access via VNC (port 5900)
- **Volume Mounts**: Easy access to saves, logs, and output files
- **AI-Ready**: Optimized for automated analysis and data extraction
- **Easy Deployment**: Git-based package with automated builds

## Container Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    HOST SYSTEM                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │            DOCKER CONTAINER                     │   │
│  │                                                 │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │   │
│  │  │   Display   │  │   Dwarf     │  │ DFHack  │ │   │
│  │  │   Server    │  │  Fortress   │  │ Engine  │ │   │
│  │  │             │  │             │  │         │ │   │
│  │  │ Xvfb  :99   │◄─┤ Game Engine │◄─┤ AI Hook │ │   │
│  │  │ VNC  :5900  │  │             │  │ Scripts │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────┘ │   │
│  │                                                 │   │
│  │  Volume Mounts:                                 │   │
│  │  ./saves/   ──► Game Save Files                 │   │
│  │  ./logs/    ──► Debug & Error Logs              │   │
│  │  ./output/  ──► AI Analysis Data                │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

For detailed architecture diagrams, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Installation

### Method 1: Git Clone (Recommended)

```bash
# Clone the repository
git clone https://github.com/Brixal-B/dwarf-fortress-container.git
cd dwarf-fortress-container

# Quick start with make
make quick-start

# Or manually with docker-compose
docker-compose up --build
```

### Method 2: Docker Hub

```bash
# Pull the pre-built image
docker pull username/dwarf-fortress-ai:latest

# Run directly
docker run -it --name dwarf-fortress \
  -p 5900:5900 \
  -v $(pwd)/saves:/opt/dwarf-fortress/df/data/save \
  -v $(pwd)/output:/opt/dwarf-fortress/output \
  username/dwarf-fortress-ai:latest
```

## Quick Start

### Build and Run with Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up --build

# Run in background
docker-compose up -d --build

# Access the running container
docker-compose exec dwarf-fortress bash
```

### Build and Run with Docker

```bash
# Build the image
docker build -t dwarf-fortress-ai .

# Run the container
docker run -it --name df-container \
  -p 5900:5900 \
  -v $(pwd)/saves:/opt/dwarf-fortress/df/data/save \
  -v $(pwd)/output:/opt/dwarf-fortress/output \
  dwarf-fortress-ai
```

## Usage

### Interactive Mode

When you run the container interactively, you'll get a bash shell where you can:

```bash
# Start Dwarf Fortress with DFHack
./dfhack

# Run DFHack scripts
./dfhack-run

# Access the game directory
cd /opt/dwarf-fortress/df
```

### Remote Access via VNC

The container exposes a VNC server on port 5900 for remote desktop access:

```bash
# Connect with any VNC client to:
localhost:5900
# No password required
```

## Directory Structure

```
/opt/dwarf-fortress/
├── df/                 # Dwarf Fortress installation
│   ├── data/save/      # Game saves (mounted from ./saves)
│   ├── dfhack          # DFHack executable
│   └── dfhack-run      # DFHack script runner
├── output/             # Output directory for AI analysis (mounted)
└── logs/               # Log files (mounted)
```

## AI Analysis Setup

### Mounted Volumes

The container automatically mounts several directories for easy AI access:

- `./saves/` → Game save files
- `./logs/` → Game logs and stderr output
- `./output/` → Custom output directory for analysis results

### DFHack Scripts for AI Analysis

Create custom DFHack scripts in the container to extract game data:

```lua
-- Example: Extract fortress information
local json = require('json')
local fortress_data = {
    population = df.global.ui.race_id,
    wealth = df.global.ui.tasks.wealth.total,
    -- Add more data points as needed
}

-- Output to mounted directory
local file = io.open('/opt/dwarf-fortress/output/fortress_data.json', 'w')
file:write(json.encode(fortress_data))
file:close()
```

## Useful DFHack Commands for AI Analysis

```bash
# Export fortress information
exportlegends info

# List all units
ls -unit

# Export world data
exportlegends legends

# Custom Lua scripts
script /path/to/your/analysis/script.lua
```

## Container Management

### Using Make Commands (If Available)

```bash
# Build and run
make quick-start

# Run in background
make run-detached

# View logs
make logs

# Access container shell
make shell

# Stop containers
make stop

# Clean up everything
make clean-all

# See all available commands
make help
```

### Alternative: Using Manager Scripts (No Make Required)

If you don't have `make` installed, use the provided manager scripts:

#### On Linux/macOS:
```bash
# Make script executable (Linux/macOS only)
chmod +x df-manager.sh

# Build and run
./df-manager.sh start

# Run in background
./df-manager.sh start-bg

# View logs
./df-manager.sh logs

# Access container shell
./df-manager.sh shell

# See all commands
./df-manager.sh help
```

#### On Windows PowerShell:
```powershell
# Build and run
.\df-manager.ps1 start

# Run in background
.\df-manager.ps1 start-bg

# View logs
.\df-manager.ps1 logs

# Access container shell
.\df-manager.ps1 shell

# See all commands
.\df-manager.ps1 help
```

#### On Windows Command Prompt:
```cmd
# Build and run
df-manager.bat start

# Run in background
df-manager.bat start-bg

# View logs
df-manager.bat logs

# Access container shell
df-manager.bat shell

# See all commands
df-manager.bat help
```

### Using Docker Compose

```bash
# Stop the container
docker-compose down

# View logs
docker-compose logs dwarf-fortress

# Access running container
docker-compose exec dwarf-fortress bash

# Restart container
docker-compose restart dwarf-fortress
```

## Troubleshooting

### Display Issues

If you encounter display issues:
```bash
# Check if Xvfb is running
ps aux | grep Xvfb

# Restart display server
Xvfb :99 -screen 0 1024x768x24 &
```

### DFHack Issues

```bash
# Check DFHack installation
./dfhack --version

# Verify DFHack integration
ls -la /opt/dwarf-fortress/df/hack/
```

### Memory Issues

If the container runs out of memory:
- Increase Docker memory limits
- Modify resource limits in `docker-compose.yml`
- Monitor usage with `docker stats`

## Development

### Customizing the Container

1. Modify `Dockerfile` for additional packages
2. Update `download_df.sh` for different versions
3. Customize `start.sh` for different startup behavior

### Adding AI Analysis Tools

```dockerfile
# Add to Dockerfile
RUN pip3 install pandas numpy matplotlib seaborn
```

## License

This container setup is provided as-is. Dwarf Fortress and DFHack have their own respective licenses.

## Support

For issues related to:
- **Container setup**: Check this README and Docker logs
- **Dwarf Fortress**: Visit [Bay 12 Games](http://www.bay12games.com/)
- **DFHack**: Visit [DFHack GitHub](https://github.com/DFHack/dfhack)
