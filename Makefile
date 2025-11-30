# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=gofmt
GOLINT=golangci-lint

# Binary names
BINARY_SERVER=server
BINARY_MIGRATOR=migrator
BINARY_WORKER=worker

# Build directories
BUILD_DIR=bin

# Application paths
CMD_SERVER_PATH=./cmd/server
CMD_MIGRATOR_PATH=./cmd/migrator
CMD_WORKER_PATH=./cmd/worker

# Docker
DOCKER_IMAGE_NAME=my-awesome-app
DOCKER_IMAGE_TAG=latest
DOCKER_IMAGE=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

# Linter config
LINTER_CONFIG=.golangci.yml

# .PHONY defines targets that are not files
.PHONY: help build build-all run run-server run-migrator run-worker test test-coverage lint clean fmt tidy deps generate docker-build docker-run docker-compose-up docker-compose-down migrate-up migrate-down

# Default target
.DEFAULT_GOAL := help

# ==============================================================================
# Help
# ==============================================================================
help: ## Show this help message
	@echo Usage: make [target]
	@echo Available targets:
	@powershell -NoProfile -ExecutionPolicy Bypass -Command "$$content = Get-Content '$(MAKEFILE_LIST)'; foreach ($$line in $$content) { if ($$line -match '^([a-zA-Z0-9_-]+):.*?## (.+)$$' -and $$line -notmatch '^\s') { Write-Host ('  {0,-20} {1}' -f $$matches[1], $$matches[2]) } }"

# ==============================================================================
# Build
# ==============================================================================
build-all: build-server build-migrator build-worker ## Build all binaries

build-server: ## Build the server binary
	@echo "Building server..."
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) -o $(BUILD_DIR)/$(BINARY_SERVER) $(CMD_SERVER_PATH)

build-migrator: ## Build the migrator binary
	@echo "Building migrator..."
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) -o $(BUILD_DIR)/$(BINARY_MIGRATOR) $(CMD_MIGRATOR_PATH)

build-worker: ## Build the worker binary
	@echo "Building worker..."
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) -o $(BUILD_DIR)/$(BINARY_WORKER) $(CMD_WORKER_PATH)

# ==============================================================================
# Run
# ==============================================================================
run-server: ## Run the server in development mode
	@echo "Running server..."
	$(GOCMD) run $(CMD_SERVER_PATH)

run-migrator: ## Run the migrator
	@echo "Running migrator..."
	$(GOCMD) run $(CMD_MIGRATOR_PATH)

run-worker: ## Run the worker
	@echo "Running worker..."
	$(GOCMD) run $(CMD_WORKER_PATH)

# ==============================================================================
# Test & Quality
# ==============================================================================
test: ## Run all tests
	@echo "Running tests..."
	$(GOTEST) -v -race ./...

test-coverage: ## Run tests with coverage report
	@echo "Running tests with coverage..."
	$(GOTEST) -v -race -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

lint: ## Run the linter
	@echo "Running linter..."
	$(GOLINT) run --config $(LINTER_CONFIG)

fmt: ## Format the code
	@echo "Formatting code..."
	$(GOFMT) -s -w .

tidy: ## Tidy go.mod
	@echo "Tidying dependencies..."
	$(GOMOD) tidy

deps: ## Download dependencies
	@echo "Downloading dependencies..."
	$(GOMOD) download

generate: ## Run go generate
	@echo "Running go generate..."
	$(GOCMD) generate ./...

# ==============================================================================
# Database
# ==============================================================================
migrate-up: ## Run database migrations up
	@echo "Running database migrations up..."
	$(GOCMD) run $(CMD_MIGRATOR_PATH) up

migrate-down: ## Run database migrations down
	@echo "Running database migrations down..."
	$(GOCMD) run $(CMD_MIGRATOR_PATH) down

# ==============================================================================
# Docker
# ==============================================================================
docker-build: ## Build the Docker image
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE) -f deployments/docker/Dockerfile .

docker-run: ## Run the Docker container
	@echo "Running Docker container..."
	docker run --rm -p 8080:8080 $(DOCKER_IMAGE)

docker-compose-up: ## Start services with docker-compose
	@echo "Starting docker-compose services..."
	docker-compose -f docker-compose.yml up -d

docker-compose-down: ## Stop services with docker-compose
	@echo "Stopping docker-compose services..."
	docker-compose -f docker-compose.yml down

# ==============================================================================
# Cleanup
# ==============================================================================
clean: ## Clean build artifacts
	@echo "Cleaning..."
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)
	rm -f coverage.out coverage.html

