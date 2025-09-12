# Dwarf Fortress Container Architecture

## System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              HOST SYSTEM (Proxmox LXC)                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        DOCKER ENGINE                                    │   │
│  │                                                                         │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │               DWARF FORTRESS CONTAINER                          │   │   │
│  │  │                                                                 │   │   │
│  │  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │   │   │
│  │  │  │   Display       │  │   Dwarf         │  │   DFHack        │ │   │   │
│  │  │  │   Server        │  │   Fortress      │  │   Engine        │ │   │   │
│  │  │  │                 │  │                 │  │                 │ │   │   │
│  │  │  │  ┌──────────┐   │  │  ┌──────────┐   │  │  ┌──────────┐   │ │   │   │
│  │  │  │  │   Xvfb   │   │  │  │    df    │   │  │  │  dfhack  │   │ │   │   │
│  │  │  │  │  :99     │◄──┼──┼──┤          │   │  │  │          │   │ │   │   │
│  │  │  │  └──────────┘   │  │  └──────────┘   │  │  └──────────┘   │ │   │   │
│  │  │  │                 │  │                 │  │                 │ │   │   │
│  │  │  │  ┌──────────┐   │  │  ┌──────────┐   │  │  ┌──────────┐   │ │   │   │
│  │  │  │  │  x11vnc  │   │  │  │ Game     │   │  │  │ Lua      │   │ │   │   │
│  │  │  │  │  :5900   │   │  │  │ Engine   │   │  │  │ Scripts  │   │ │   │   │
│  │  │  │  └──────────┘   │  │  └──────────┘   │  │  └──────────┘   │ │   │   │
│  │  │  │                 │  │                 │  │                 │ │   │   │
│  │  │  │  ┌──────────┐   │  │                 │  │  ┌──────────┐   │ │   │   │
│  │  │  │  │ fluxbox  │   │  │                 │  │  │ AI Data  │   │ │   │   │
│  │  │  │  │    WM    │   │  │                 │  │  │ Export   │   │ │   │   │
│  │  │  │  └──────────┘   │  │                 │  │  └──────────┘   │ │   │   │
│  │  │  └─────────────────┘  └─────────────────┘  └─────────────────┘ │   │   │
│  │  │                                                                 │   │   │
│  │  └─────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                         │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        VOLUME MOUNTS                                    │   │
│  │                                                                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
│  │  │    saves/   │  │    logs/    │  │   output/   │  │   config/   │   │   │
│  │  │             │  │             │  │             │  │             │   │   │
│  │  │ Game Saves  │  │ Debug Logs  │  │ AI Analysis │  │ DF Settings │   │   │
│  │  │ World Data  │  │ Error Logs  │  │ Export Data │  │ DFHack CFG  │   │   │
│  │  │             │  │ Game Logs   │  │ JSON Output │  │             │   │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Container Startup Sequence

```
1. Docker Container Initialization
   ├── Ubuntu Base Image Loaded
   ├── Dependencies Installed
   └── User 'dfuser' Created

2. Download & Installation Phase
   ├── download_df.sh Executed
   │   ├── Dwarf Fortress Downloaded
   │   ├── DFHack Downloaded
   │   └── Integration Completed
   └── File Permissions Set

3. Display Server Startup
   ├── Xvfb Started (Virtual Display :99)
   ├── x11vnc Started (VNC Server :5900)
   └── fluxbox Started (Window Manager)

4. Application Layer
   ├── Dwarf Fortress Binary Ready
   ├── DFHack Integration Active
   └── Lua Scripting Environment Available

5. Service Exposure
   ├── VNC Port 5900 Exposed
   ├── Volume Mounts Active
   └── Container Ready for Interaction
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  DATA FLOW                                      │
└─────────────────────────────────────────────────────────────────────────────────┘

INPUT FLOW:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   User/AI   │───▶│    VNC      │───▶│    Xvfb     │───▶│   Dwarf     │
│   Commands  │    │  Port 5900  │    │   :99       │    │  Fortress   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                               │
                                                               ▼
                                                        ┌─────────────┐
                                                        │   DFHack    │
                                                        │   Engine    │
                                                        └─────────────┘

OUTPUT FLOW:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Game      │───▶│   DFHack    │───▶│   Lua       │───▶│   Output    │
│   State     │    │   Monitor   │    │   Scripts   │    │   Files     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                                                        │
       ▼                                                        ▼
┌─────────────┐                                          ┌─────────────┐
│   Save      │                                          │   Host      │
│   Files     │                                          │   System    │
└─────────────┘                                          └─────────────┘
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              NETWORK TOPOLOGY                                   │
└─────────────────────────────────────────────────────────────────────────────────┘

EXTERNAL ACCESS:
Internet ◄──► Proxmox Host ◄──► LXC Container ◄──► Docker Bridge ◄──► DF Container
                     │                   │                    │              │
                Port 5900           Port 5900           Port 5900      Port 5900
                   (VNC)              (VNC)              (VNC)          (VNC)

INTERNAL CONTAINER NETWORK:
┌─────────────────────────────────────────────────────────────────────────────────┐
│  Container Internal (172.x.x.x/16)                                             │
│                                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │    Xvfb     │    │   x11vnc    │    │   Dwarf     │    │   DFHack    │     │
│  │   :99       │◄───┤   :5900     │    │  Fortress   │◄───┤   Engine    │     │
│  │             │    │             │    │             │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Process Hierarchy

```
Container Start (PID 1: start.sh)
│
├── Xvfb (Virtual Display Server)
│   └── DISPLAY=:99
│
├── x11vnc (VNC Server)
│   ├── Listens on 0.0.0.0:5900
│   └── Connects to DISPLAY=:99
│
├── fluxbox (Window Manager)
│   └── Manages X11 windows
│
└── Application Layer
    ├── dfhack (Main Process)
    │   ├── Dwarf Fortress Engine
    │   ├── DFHack Hooks
    │   └── Lua Script Engine
    │
    └── Background Services
        ├── File Monitoring
        ├── Log Generation
        └── AI Data Export
```

## Volume Mount Strategy

```
HOST FILESYSTEM                    CONTAINER FILESYSTEM
                                   
./saves/                    ──────▶ /opt/dwarf-fortress/df/data/save/
   ├── region1/                      ├── region1/
   ├── region2/                      ├── region2/
   └── ...                           └── ...

./logs/                     ──────▶ /opt/dwarf-fortress/df/stderr.txt
   ├── error.log                     └── (redirected output)
   └── debug.log

./output/                   ──────▶ /opt/dwarf-fortress/output/
   ├── analysis.json                 ├── analysis.json
   ├── fortress_data.csv             ├── fortress_data.csv
   └── ai_reports/                   └── ai_reports/

./config/                   ──────▶ /opt/dwarf-fortress/df/data/init/
   ├── init.txt                      ├── init.txt
   ├── d_init.txt                    ├── d_init.txt
   └── dfhack.init                   └── dfhack.init
```

## AI Analysis Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           AI ANALYSIS WORKFLOW                                  │
└─────────────────────────────────────────────────────────────────────────────────┘

GAME EVENTS:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Game      │───▶│   DFHack    │───▶│   Event     │───▶│   Lua       │
│   Engine    │    │   Hooks     │    │   Capture   │    │   Scripts   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                               │
                                                               ▼
DATA PROCESSING:                                        ┌─────────────┐
┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │   JSON      │
│   Raw       │───▶│   Data      │───▶│   Export    │◄─┤   Export    │
│   Game      │    │   Filter    │    │   Format    │  │   Engine    │
│   Data      │    │   Transform │    │   (JSON)    │  └─────────────┘
└─────────────┘    └─────────────┘    └─────────────┘
                                            │
                                            ▼
AI CONSUMPTION:                       ┌─────────────┐
┌─────────────┐    ┌─────────────┐   │   Output    │
│   AI        │◄───┤   Host      │◄──┤   Volume    │
│   Model     │    │   System    │   │   Mount     │
│   Analysis  │    │   Access    │   └─────────────┘
└─────────────┘    └─────────────┘
```

## Error Handling & Recovery

```
Container Health Check:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Process   │───▶│   Health    │───▶│   Action    │
│   Monitor   │    │   Check     │    │   Response  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Xvfb      │    │   Running   │    │   Restart   │
│   dfhack    │    │   Crashed   │    │   Cleanup   │
│   x11vnc    │    │   Hung      │    │   Recovery  │
└─────────────┘    └─────────────┘    └─────────────┘
```

This architecture provides a robust, scalable solution for running Dwarf Fortress in a containerized environment with full AI analysis capabilities and remote access support.
