#!/bin/bash

# Dwarf Fortress Docker Manager Script
# Use this script if you don't have 'make' installed

IMAGE_NAME="dwarf-fortress-ai"
CONTAINER_NAME="dwarf-fortress-container"

show_help() {
    echo "Dwarf Fortress Docker Container Manager"
    echo ""
    echo "Usage: ./df-manager.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start           Build and start the container"
    echo "  start-bg        Build and start in background"
    echo "  stop            Stop the container"
    echo "  restart         Restart the container"
    echo "  logs            Show container logs"
    echo "  shell           Access container shell"
    echo "  status          Show container status"
    echo "  clean           Remove containers and images"
    echo "  clean-all       Remove everything including volumes"
    echo "  setup           Create necessary directories"
    echo "  help            Show this help message"
    echo ""
}

setup_dirs() {
    echo "Creating necessary directories..."
    mkdir -p saves logs output
    echo "Directories created: saves/, logs/, output/"
}

start_container() {
    echo "Building and starting Dwarf Fortress container..."
    docker-compose up --build
}

start_background() {
    echo "Building and starting container in background..."
    docker-compose up --build -d
    echo "Container started in background. Use './df-manager.sh logs' to view logs."
}

stop_container() {
    echo "Stopping containers..."
    docker-compose down
}

restart_container() {
    echo "Restarting containers..."
    docker-compose restart
}

show_logs() {
    echo "Showing container logs (Press Ctrl+C to exit)..."
    docker-compose logs -f dwarf-fortress
}

shell_access() {
    echo "Accessing container shell..."
    docker-compose exec dwarf-fortress bash
}

show_status() {
    echo "Container status:"
    docker-compose ps
}

clean_container() {
    echo "Cleaning up containers and images..."
    docker-compose down
    docker rmi $IMAGE_NAME 2>/dev/null || true
    echo "Cleanup complete."
}

clean_all() {
    echo "Cleaning up everything (containers, images, volumes)..."
    docker-compose down -v
    docker rmi $IMAGE_NAME 2>/dev/null || true
    echo "Full cleanup complete."
}

# Main script logic
case "$1" in
    "start")
        setup_dirs
        start_container
        ;;
    "start-bg")
        setup_dirs
        start_background
        ;;
    "stop")
        stop_container
        ;;
    "restart")
        restart_container
        ;;
    "logs")
        show_logs
        ;;
    "shell")
        shell_access
        ;;
    "status")
        show_status
        ;;
    "clean")
        clean_container
        ;;
    "clean-all")
        clean_all
        ;;
    "setup")
        setup_dirs
        ;;
    "help"|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
