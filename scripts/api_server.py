#!/usr/bin/env python3
"""
Simple API Server for ARM-compatible Dwarf Fortress setup
This provides basic API endpoints without requiring the full DFHack integration
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os
import glob
from datetime import datetime
import subprocess

app = Flask(__name__)
CORS(app)

# Configuration
OUTPUT_DIR = '/home/steam/output'
SAVES_DIR = '/home/steam/df/data/save'

def ensure_output_dir():
    """Ensure output directory exists"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

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
        "service": "dwarf-fortress-api-arm",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0-arm",
        "platform": "ARM Compatible"
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
    
    # Return ARM-compatible default data
    return jsonify({
        "status": "arm_mode",
        "message": "ARM-compatible mode - Dwarf Fortress not yet running",
        "timestamp": datetime.now().isoformat(),
        "platform": "ARM",
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
            "name": "ARM Fortress",
            "year": 0,
            "season": "Unknown"
        }
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

@app.route('/api/system-info')
def system_info():
    """Get system information"""
    try:
        # Get basic system info
        result = subprocess.run(['uname', '-a'], capture_output=True, text=True)
        uname_output = result.stdout.strip() if result.returncode == 0 else "Unknown"
        
        # Get memory info
        mem_result = subprocess.run(['free', '-h'], capture_output=True, text=True)
        mem_output = mem_result.stdout.strip() if mem_result.returncode == 0 else "Unknown"
        
        return jsonify({
            "system": uname_output,
            "memory": mem_output,
            "platform": "ARM Compatible",
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/steam-status')
def steam_status():
    """Check Steam/Proton status"""
    try:
        # Check if Steam is available
        steam_result = subprocess.run(['which', 'steam'], capture_output=True, text=True)
        steam_available = steam_result.returncode == 0
        
        return jsonify({
            "steam_available": steam_available,
            "steam_path": steam_result.stdout.strip() if steam_available else None,
            "message": "Steam/Proton integration ready" if steam_available else "Steam not found - install Steam for Dwarf Fortress",
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("ARM-Compatible Dwarf Fortress API Server")
    print("WARNING: This is a backup server. The main API server is already running on port 8080.")
    print("Use this only if the main container is not running or on ARM architecture.")
    print("To start anyway, uncomment the app.run line below and change the port.")
    # app.run(host='0.0.0.0', port=8081, debug=False)  # Changed to port 8081 to avoid conflicts