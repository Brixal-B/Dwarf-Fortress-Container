#!/usr/bin/env python3
"""
Dwarf Fortress Container Web Management Server
A comprehensive web UI for managing all aspects of the container setup
"""

from flask import Flask, render_template, jsonify, request, redirect, url_for, flash
from flask_cors import CORS
import json
import os
import subprocess
import datetime
import threading
import time
import signal
import sys
from pathlib import Path

app = Flask(__name__)
app.secret_key = 'df-container-management-2024'
CORS(app)

# Configuration
BASE_DIR = Path(__file__).parent
COMPOSE_FILE = BASE_DIR / 'docker-compose.yml'
ENV_FILE = BASE_DIR / '.env'

class ContainerManager:
    """Manages Docker container operations"""
    
    def __init__(self):
        self.services = [
            'dwarf-fortress',
            'dashy'
        ]
    
    def run_command(self, command, capture_output=True):
        """Run a shell command and return result"""
        try:
            if capture_output:
                result = subprocess.run(
                    command, 
                    shell=True, 
                    capture_output=True, 
                    text=True,
                    cwd=BASE_DIR
                )
                return {
                    'success': result.returncode == 0,
                    'stdout': result.stdout,
                    'stderr': result.stderr,
                    'returncode': result.returncode
                }
            else:
                # For non-blocking operations
                subprocess.Popen(command, shell=True, cwd=BASE_DIR)
                return {'success': True, 'message': 'Command started'}
        except Exception as e:
            return {
                'success': False, 
                'error': str(e),
                'returncode': -1
            }
    
    def get_container_status(self):
        """Get status of all containers"""
        result = self.run_command('docker-compose ps --format json')
        containers = []
        
        if result['success'] and result['stdout']:
            try:
                # Parse each line as JSON (docker-compose ps --format json outputs one JSON per line)
                lines = result['stdout'].strip().split('\n')
                for line in lines:
                    if line.strip():
                        container = json.loads(line)
                        containers.append({
                            'name': container.get('Name', ''),
                            'service': container.get('Service', ''),
                            'state': container.get('State', ''),
                            'status': container.get('Status', ''),
                            'ports': container.get('Publishers', [])
                        })
            except json.JSONDecodeError:
                # Fallback to simple parsing
                pass
        
        return containers
    
    def start_service(self, service=None):
        """Start all services or a specific service"""
        if service:
            command = f'docker-compose up -d {service}'
        else:
            command = 'docker-compose up -d'
        return self.run_command(command)
    
    def stop_service(self, service=None):
        """Stop all services or a specific service"""
        if service:
            command = f'docker-compose stop {service}'
        else:
            command = 'docker-compose stop'
        return self.run_command(command)
    
    def restart_service(self, service=None):
        """Restart all services or a specific service"""
        if service:
            command = f'docker-compose restart {service}'
        else:
            command = 'docker-compose restart'
        return self.run_command(command)
    
    def build_service(self, service=None, no_cache=False):
        """Build services"""
        cache_flag = '--no-cache' if no_cache else ''
        if service:
            command = f'docker-compose build {cache_flag} {service}'
        else:
            command = f'docker-compose build {cache_flag}'
        return self.run_command(command)
    
    def get_logs(self, service=None, lines=100):
        """Get container logs"""
        if service:
            command = f'docker-compose logs --tail={lines} {service}'
        else:
            command = f'docker-compose logs --tail={lines}'
        return self.run_command(command)
    
    def get_service_health(self):
        """Get health status of services"""
        health_status = {}
        
        # Check API server
        api_result = self.run_command('curl -f http://localhost:8080/api/health')
        health_status['api'] = api_result['success']
        
        # Check Dashy
        dashy_result = self.run_command('curl -f http://localhost:4000')
        health_status['dashy'] = dashy_result['success']
        
        return health_status

class SystemInfo:
    """Collects system information"""
    
    @staticmethod
    def get_disk_usage():
        """Get disk usage for mounted volumes"""
        volumes = ['saves', 'logs', 'output']
        usage = {}
        
        for volume in volumes:
            path = BASE_DIR / volume
            if path.exists():
                result = subprocess.run(['du', '-sh', str(path)], capture_output=True, text=True)
                if result.returncode == 0:
                    size = result.stdout.split()[0]
                    usage[volume] = size
                else:
                    usage[volume] = 'N/A'
            else:
                usage[volume] = 'Not found'
        
        return usage
    
    @staticmethod
    def get_docker_stats():
        """Get Docker resource usage"""
        result = subprocess.run(
            ['docker', 'stats', '--no-stream', '--format', 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}'],
            capture_output=True, text=True
        )
        
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')[1:]  # Skip header
            stats = []
            for line in lines:
                if 'dwarf-fortress' in line or 'dashy' in line or 'web-manager' in line:
                    parts = line.split('\t')
                    if len(parts) >= 5:
                        stats.append({
                            'name': parts[0],
                            'cpu': parts[1],
                            'memory': parts[2],
                            'network': parts[3],
                            'block_io': parts[4]
                        })
            return stats
        return []

# Initialize manager
container_manager = ContainerManager()

@app.route('/')
def dashboard():
    """Main dashboard"""
    return render_template('dashboard.html')

@app.route('/api/status')
def api_status():
    """Get overall system status"""
    containers = container_manager.get_container_status()
    health = container_manager.get_service_health()
    disk_usage = SystemInfo.get_disk_usage()
    docker_stats = SystemInfo.get_docker_stats()
    
    return jsonify({
        'containers': containers,
        'health': health,
        'disk_usage': disk_usage,
        'docker_stats': docker_stats,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/api/containers')
def api_containers():
    """Get container status"""
    return jsonify(container_manager.get_container_status())

@app.route('/api/start', methods=['POST'])
def api_start():
    """Start containers"""
    service = request.json.get('service') if request.json else None
    result = container_manager.start_service(service)
    return jsonify(result)

@app.route('/api/stop', methods=['POST'])
def api_stop():
    """Stop containers"""
    service = request.json.get('service') if request.json else None
    result = container_manager.stop_service(service)
    return jsonify(result)

@app.route('/api/restart', methods=['POST'])
def api_restart():
    """Restart containers"""
    service = request.json.get('service') if request.json else None
    result = container_manager.restart_service(service)
    return jsonify(result)

@app.route('/api/build', methods=['POST'])
def api_build():
    """Build containers"""
    data = request.json or {}
    service = data.get('service')
    no_cache = data.get('no_cache', False)
    result = container_manager.build_service(service, no_cache)
    return jsonify(result)

@app.route('/api/logs')
def api_logs():
    """Get container logs"""
    service = request.args.get('service')
    lines = int(request.args.get('lines', 100))
    result = container_manager.get_logs(service, lines)
    return jsonify(result)

@app.route('/api/fortress-stats')
def api_fortress_stats():
    """Proxy to the fortress API"""
    try:
        result = subprocess.run(
            ['curl', '-s', 'http://localhost:8080/api/fortress-stats'],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
        else:
            return jsonify({'error': 'Fortress API not available'})
    except Exception as e:
        return jsonify({'error': str(e)})

@app.route('/api/config')
def api_config():
    """Get current configuration"""
    config = {}
    
    # Read .env file
    if ENV_FILE.exists():
        with open(ENV_FILE, 'r') as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    config[key] = value
    
    return jsonify(config)

@app.route('/api/config', methods=['POST'])
def api_update_config():
    """Update configuration"""
    new_config = request.json
    
    # Read existing config
    existing_config = {}
    if ENV_FILE.exists():
        with open(ENV_FILE, 'r') as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    existing_config[key] = value
    
    # Update with new values
    existing_config.update(new_config)
    
    # Write back to file
    with open(ENV_FILE, 'w') as f:
        f.write('# Dwarf Fortress Container Configuration\n')
        f.write(f'# Updated: {datetime.datetime.now().isoformat()}\n\n')
        for key, value in existing_config.items():
            f.write(f'{key}={value}\n')
    
    return jsonify({'success': True, 'message': 'Configuration updated'})

@app.route('/logs')
def logs_page():
    """Logs viewing page"""
    return render_template('logs.html')

@app.route('/config')
def config_page():
    """Configuration page"""
    return render_template('config.html')

@app.route('/fortress')
def fortress_page():
    """Fortress statistics page"""
    return render_template('fortress.html')

@app.route('/mobile')
def mobile_page():
    """Mobile-optimized interface"""
    return render_template('mobile.html')

def signal_handler(sig, frame):
    """Handle shutdown signals"""
    print("\nShutting down Web Management Server...")
    sys.exit(0)

if __name__ == '__main__':
    # Handle shutdown gracefully
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    print("Starting Dwarf Fortress Web Management Server...")
    print("Dashboard will be available at: http://localhost:3000")
    
    app.run(host='0.0.0.0', port=3000, debug=False, threaded=True)
