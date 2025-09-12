# Dwarf Fortress Docker Container Makefile

# Variables
IMAGE_NAME = dwarf-fortress-ai
CONTAINER_NAME = dwarf-fortress-container
COMPOSE_FILE = docker-compose.yml

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Dwarf Fortress Docker Container"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Build Commands
.PHONY: build
build: ## Build the Docker image
	docker build -t $(IMAGE_NAME) .

.PHONY: build-no-cache
build-no-cache: ## Build the Docker image without using cache
	docker build --no-cache -t $(IMAGE_NAME) .

##@ Run Commands
.PHONY: run
run: ## Run the container with docker-compose
	docker-compose up

.PHONY: run-detached
run-detached: ## Run the container in background
	docker-compose up -d

.PHONY: run-build
run-build: ## Build and run the container
	docker-compose up --build

.PHONY: run-build-detached
run-build-detached: ## Build and run the container in background
	docker-compose up --build -d

.PHONY: run-docker
run-docker: build ## Run the container with docker directly
	docker run -it --name $(CONTAINER_NAME) \
		-p 5900:5900 \
		-v $$(pwd)/saves:/opt/dwarf-fortress/df/data/save \
		-v $$(pwd)/output:/opt/dwarf-fortress/output \
		$(IMAGE_NAME)

##@ Management Commands
.PHONY: stop
stop: ## Stop the running containers
	docker-compose down

.PHONY: restart
restart: ## Restart the containers
	docker-compose restart

.PHONY: logs
logs: ## Show container logs
	docker-compose logs -f dwarf-fortress

.PHONY: shell
shell: ## Access the running container shell
	docker-compose exec dwarf-fortress bash

.PHONY: status
status: ## Show container status
	docker-compose ps

##@ Cleanup Commands
.PHONY: clean
clean: ## Remove containers and images
	docker-compose down
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

.PHONY: clean-all
clean-all: ## Remove containers, images, and volumes
	docker-compose down -v
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	docker system prune -f

.PHONY: clean-volumes
clean-volumes: ## Remove only the volumes (saves, logs, output)
	rm -rf saves/ logs/ output/

##@ Development Commands
.PHONY: dev-shell
dev-shell: ## Run a development shell (mounts current directory)
	docker run -it --rm \
		-v $$(pwd):/workspace \
		-w /workspace \
		ubuntu:22.04 bash

.PHONY: validate
validate: ## Validate Docker and compose files
	docker-compose config

##@ Setup Commands
.PHONY: setup-dirs
setup-dirs: ## Create necessary directories for volume mounts
	mkdir -p saves logs output

.PHONY: install
install: setup-dirs build ## Full installation: setup directories and build image

##@ Quick Start
.PHONY: quick-start
quick-start: install run-build ## Complete setup and run (recommended for first time)

.PHONY: quick-start-detached
quick-start-detached: install run-build-detached ## Complete setup and run in background
