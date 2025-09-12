# Dwarf Fortress Docker Manager PowerShell Script
# Use this script if you don't have 'make' installed on Windows

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

$ImageName = "dwarf-fortress-ai"
$ContainerName = "dwarf-fortress-container"

function Show-Help {
    Write-Host "Dwarf Fortress Docker Container Manager" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\df-manager.ps1 [command]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  start           Build and start the container"
    Write-Host "  start-bg        Build and start in background"
    Write-Host "  stop            Stop the container"
    Write-Host "  restart         Restart the container"
    Write-Host "  logs            Show container logs"
    Write-Host "  shell           Access container shell"
    Write-Host "  status          Show container status"
    Write-Host "  clean           Remove containers and images"
    Write-Host "  clean-all       Remove everything including volumes"
    Write-Host "  setup           Create necessary directories"
    Write-Host "  help            Show this help message"
    Write-Host ""
}

function Setup-Dirs {
    Write-Host "Creating necessary directories..." -ForegroundColor Yellow
    $dirs = @("saves", "logs", "output")
    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
    }
    Write-Host "Directories created: saves/, logs/, output/" -ForegroundColor Green
}

function Start-Container {
    Write-Host "Building and starting Dwarf Fortress container..." -ForegroundColor Yellow
    Setup-Dirs
    docker-compose up --build
}

function Start-Background {
    Write-Host "Building and starting container in background..." -ForegroundColor Yellow
    Setup-Dirs
    docker-compose up --build -d
    Write-Host "Container started in background. Use '.\df-manager.ps1 logs' to view logs." -ForegroundColor Green
}

function Stop-Container {
    Write-Host "Stopping containers..." -ForegroundColor Yellow
    docker-compose down
}

function Restart-Container {
    Write-Host "Restarting containers..." -ForegroundColor Yellow
    docker-compose restart
}

function Show-Logs {
    Write-Host "Showing container logs (Press Ctrl+C to exit)..." -ForegroundColor Yellow
    docker-compose logs -f dwarf-fortress
}

function Shell-Access {
    Write-Host "Accessing container shell..." -ForegroundColor Yellow
    docker-compose exec dwarf-fortress bash
}

function Show-Status {
    Write-Host "Container status:" -ForegroundColor Yellow
    docker-compose ps
}

function Clean-Container {
    Write-Host "Cleaning up containers and images..." -ForegroundColor Yellow
    docker-compose down
    docker rmi $ImageName 2>$null
    Write-Host "Cleanup complete." -ForegroundColor Green
}

function Clean-All {
    Write-Host "Cleaning up everything (containers, images, volumes)..." -ForegroundColor Yellow
    docker-compose down -v
    docker rmi $ImageName 2>$null
    Write-Host "Full cleanup complete." -ForegroundColor Green
}

# Main script logic
switch ($Command.ToLower()) {
    "start" { Start-Container }
    "start-bg" { Start-Background }
    "stop" { Stop-Container }
    "restart" { Restart-Container }
    "logs" { Show-Logs }
    "shell" { Shell-Access }
    "status" { Show-Status }
    "clean" { Clean-Container }
    "clean-all" { Clean-All }
    "setup" { Setup-Dirs }
    "help" { Show-Help }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
        exit 1
    }
}
