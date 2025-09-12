@echo off
REM Dwarf Fortress Docker Manager Batch Script
REM Use this script if you don't have 'make' installed on Windows

setlocal
set IMAGE_NAME=dwarf-fortress-ai
set CONTAINER_NAME=dwarf-fortress-container

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="start" goto start
if "%1"=="start-bg" goto start-bg
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="logs" goto logs
if "%1"=="shell" goto shell
if "%1"=="status" goto status
if "%1"=="clean" goto clean
if "%1"=="clean-all" goto clean-all
if "%1"=="setup" goto setup

echo Unknown command: %1
echo.
goto help

:help
echo Dwarf Fortress Docker Container Manager
echo.
echo Usage: df-manager.bat [command]
echo.
echo Commands:
echo   start           Build and start the container
echo   start-bg        Build and start in background
echo   stop            Stop the container
echo   restart         Restart the container
echo   logs            Show container logs
echo   shell           Access container shell
echo   status          Show container status
echo   clean           Remove containers and images
echo   clean-all       Remove everything including volumes
echo   setup           Create necessary directories
echo   help            Show this help message
echo.
goto end

:setup
echo Creating necessary directories...
if not exist "saves" mkdir saves
if not exist "logs" mkdir logs
if not exist "output" mkdir output
echo Directories created: saves/, logs/, output/
goto end

:start
echo Building and starting Dwarf Fortress container...
call :setup
docker-compose up --build
goto end

:start-bg
echo Building and starting container in background...
call :setup
docker-compose up --build -d
echo Container started in background. Use 'df-manager.bat logs' to view logs.
goto end

:stop
echo Stopping containers...
docker-compose down
goto end

:restart
echo Restarting containers...
docker-compose restart
goto end

:logs
echo Showing container logs (Press Ctrl+C to exit)...
docker-compose logs -f dwarf-fortress
goto end

:shell
echo Accessing container shell...
docker-compose exec dwarf-fortress bash
goto end

:status
echo Container status:
docker-compose ps
goto end

:clean
echo Cleaning up containers and images...
docker-compose down
docker rmi %IMAGE_NAME% 2>nul
echo Cleanup complete.
goto end

:clean-all
echo Cleaning up everything (containers, images, volumes)...
docker-compose down -v
docker rmi %IMAGE_NAME% 2>nul
echo Full cleanup complete.
goto end

:end
endlocal
