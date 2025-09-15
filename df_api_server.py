#!/usr/bin/env python3
"""
Dwarf Fortress API Server
Serves game data via REST API for dashboard integration
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os
import glob
from datetime import datetime
import threading
import time

app = Flask(__name__)
CORS(app)

# Configuration
OUTPUT_DIR = '/opt/dwarf-fortress/output'
SAVES_DIR = '/opt/dwarf-fortress/df/data/save'

def ensure_output_dir():
    """Ensure output directory exists"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_latest_file(pattern):
    """Get the most recently modified file matching pattern"""
    files = glob.glob(pattern)
    if not files:
        return None
    return max(files, key=os.path.getmtime)

def safe_read_json(filepath):
    """Safely read JSON file with error handling"""
    try:
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                return json.load(f)
    except (json.JSONDecodeError, IOError) as e:
        app.logger.warning(f"Error reading {filepath}: {e}")
    return None

@app.route('/api/health')
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "running",
        "service": "dwarf-fortress-api",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    })

@app.route('/api/fortress-stats')
def fortress_stats():
    """Get current fortress statistics"""
    ensure_output_dir()
    
    # Try to read the main fortress data file
    data_file = os.path.join(OUTPUT_DIR, 'fortress_data.json')
    fortress_data = safe_read_json(data_file)
    
    if fortress_data:
        return jsonify(fortress_data)
    
    # If no data file exists, return default structure
    return jsonify({
        "status": "no_data",
        "message": "No fortress data available yet. Start the game and run data export.",
        "timestamp": datetime.now().isoformat(),
        "population": {
            "total": 0,
            "dwarves": 0,
            "animals": 0
        },
        "wealth": {
            "total": 0,
            "weapons": 0,
            "armor": 0,
            "furniture": 0
        },
        "fortress_info": {
            "name": "Unknown",
            "year": 0,
            "season": "Unknown"
        }
    })

@app.route('/api/fortress-stats/population')
def population_stats():
    """Get detailed population statistics"""
    data_file = os.path.join(OUTPUT_DIR, 'fortress_data.json')
    fortress_data = safe_read_json(data_file)
    
    if fortress_data and 'population' in fortress_data:
        return jsonify(fortress_data['population'])
    
    return jsonify({
        "total": 0,
        "dwarves": 0,
        "animals": 0,
        "visitors": 0
    })

@app.route('/api/fortress-stats/wealth')
def wealth_stats():
    """Get detailed wealth statistics"""
    data_file = os.path.join(OUTPUT_DIR, 'fortress_data.json')
    fortress_data = safe_read_json(data_file)
    
    if fortress_data and 'wealth' in fortress_data:
        return jsonify(fortress_data['wealth'])
    
    return jsonify({
        "total": 0,
        "weapons": 0,
        "armor": 0,
        "furniture": 0,
        "other": 0
    })

@app.route('/api/saves')
def list_saves():
    """List available save files"""
    try:
        saves = []
        if os.path.exists(SAVES_DIR):
            for item in os.listdir(SAVES_DIR):
                save_path = os.path.join(SAVES_DIR, item)
                if os.path.isdir(save_path):
                    stat = os.stat(save_path)
                    saves.append({
                        "name": item,
                        "modified": datetime.fromtimestamp(stat.st_mtime).isoformat(),
                        "size": stat.st_size
                    })
        
        return jsonify({
            "saves": sorted(saves, key=lambda x: x['modified'], reverse=True),
            "count": len(saves)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/logs')
def get_logs():
    """Get recent log entries"""
    try:
        log_files = []
        logs_dir = '/opt/dwarf-fortress/df'
        
        # Look for common log files
        for log_name in ['stderr.txt', 'stdout.txt', 'dfhack.log']:
            log_path = os.path.join(logs_dir, log_name)
            if os.path.exists(log_path):
                # Read last 50 lines
                with open(log_path, 'r') as f:
                    lines = f.readlines()
                    recent_lines = lines[-50:] if len(lines) > 50 else lines
                    log_files.append({
                        "file": log_name,
                        "lines": [line.strip() for line in recent_lines if line.strip()],
                        "total_lines": len(lines)
                    })
        
        return jsonify({
            "logs": log_files,
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/output-files')
def list_output_files():
    """List files in the output directory"""
    try:
        files = []
        if os.path.exists(OUTPUT_DIR):
            for filename in os.listdir(OUTPUT_DIR):
                filepath = os.path.join(OUTPUT_DIR, filename)
                if os.path.isfile(filepath):
                    stat = os.stat(filepath)
                    files.append({
                        "name": filename,
                        "size": stat.st_size,
                        "modified": datetime.fromtimestamp(stat.st_mtime).isoformat(),
                        "extension": os.path.splitext(filename)[1]
                    })
        
        return jsonify({
            "files": sorted(files, key=lambda x: x['modified'], reverse=True),
            "count": len(files)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/export-data', methods=['POST'])
def trigger_export():
    """Trigger data export (placeholder for DFHack integration)"""
    # This endpoint could be used to trigger DFHack scripts
    return jsonify({
        "message": "Data export triggered",
        "timestamp": datetime.now().isoformat(),
        "note": "Run DFHack script: 'script /opt/dwarf-fortress/scripts/export_fortress_data.lua'"
    })

def create_sample_data():
    """Create sample data file for testing"""
    ensure_output_dir()
    sample_data = {
        "timestamp": datetime.now().isoformat(),
        "population": {
            "total": 156,
            "dwarves": 134,
            "animals": 22,
            "visitors": 0
        },
        "wealth": {
            "total": 485230,
            "weapons": 12450,
            "armor": 8900,
            "furniture": 234500,
            "other": 229380
        },
        "fortress_info": {
            "name": "Mountainhomes",
            "year": 125,
            "season": "Late Spring"
        },
        "status": "active"
    }
    
    sample_file = os.path.join(OUTPUT_DIR, 'fortress_data.json')
    with open(sample_file, 'w') as f:
        json.dump(sample_data, f, indent=2)
    
    app.logger.info(f"Created sample data at {sample_file}")

if __name__ == '__main__':
    # Create sample data on startup for testing
    create_sample_data()
    
    app.logger.info("Starting Dwarf Fortress API Server on port 8080")
    app.run(host='0.0.0.0', port=8080, debug=False)
