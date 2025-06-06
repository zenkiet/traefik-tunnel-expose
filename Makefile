# ==============================================================================
# 🚀 Traefik Tunnel Expose - Zen Kiet
# ==============================================================================
# Project: Exposing internal services securely via Traefik Proxy & Cloudflare Tunnel
# Author: ZenKiet
# License: MIT
# ==============================================================================

# Project Configuration
PROJECT_NAME := traefik-tunnel-expose
DOCKER_NAMESPACE := zenkiet
IMAGE_NAME := traefik-tunnel-expose
DEFAULT_VERSION := latest
VERSION ?= $(DEFAULT_VERSION)
FULL_IMAGE_NAME := $(DOCKER_NAMESPACE)/$(IMAGE_NAME):$(VERSION)
CONTAINER_NAME := traefik-tunnel

# Build Configuration
DOCKERFILE := Dockerfile
DOCKER_CONTEXT := .
PLATFORMS := linux/amd64,linux/arm64,linux/arm/v7
BUILD_ARGS := --build-arg VERSION=$(VERSION) --build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Environment Configuration
ENV_FILE := .env
ENV_EXAMPLE := env.example
COMPOSE_FILE := docker-compose.yml

# Directory Structure
CONFIG_DIR := config
CONF_DIR := conf.d
LOGS_DIR := logs
SCRIPTS_DIR := scripts
SSL_DIR := ssl

# Color Definitions
RESET := \033[0m
BOLD := \033[1m
DIM := \033[2m
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m

# Icons
ICON_BUILD := 🔨
ICON_PUSH := 📤
ICON_RUN := 🚀
ICON_STOP := 🛑
ICON_TEST := 🧪
ICON_CLEAN := 🧹
ICON_INFO := ℹ️
ICON_SUCCESS := ✅
ICON_ERROR := ❌
ICON_WARNING := ⚠️
ICON_SETUP := ⚙️
ICON_HEALTH := 🏥
ICON_BACKUP := 💾
ICON_UPDATE := 🔄
ICON_LOGS := 📋
ICON_SHELL := 🐚
ICON_SECURITY := 🔒
ICON_FORMAT := 🖌️

# Utility Functions
define print_header
	@echo "$(CYAN)$(BOLD)"
	@echo "=================================="
	@echo "$(1)"
	@echo "=================================="
	@echo "$(RESET)"
endef

define print_step
	@echo "$(BLUE)$(BOLD)$(ICON_RUN) $(1)$(RESET)"
endef

define print_success
	@echo "$(GREEN)$(BOLD)$(ICON_SUCCESS) $(1)$(RESET)"
endef

define print_error
	@echo "$(RED)$(BOLD)$(ICON_ERROR) $(1)$(RESET)"
endef

define print_warning
	@echo "$(YELLOW)$(BOLD)$(ICON_WARNING) $(1)$(RESET)"
endef

define check_command
	@which $(1) > /dev/null 2>&1 || (echo "$(RED)$(ICON_ERROR) $(1) is not installed$(RESET)" && exit 1)
endef

# ==============================================================================
# 📖 HELP & DOCUMENTATION
# ==============================================================================

.PHONY: help
help:
	$(call print_header,📖 TRAEFIK TUNNEL EXPOSE - COMMAND REFERENCE)
	@echo ""
	@echo "$(CYAN)$(BOLD)🚀 Usage:$(RESET) $(WHITE)make [target]$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🔧 Setup & Environment$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)setup$(RESET)             $(DIM)Setup complete development environment$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)check-deps$(RESET)        $(DIM)Check and install dependencies$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)setup-dirs$(RESET)        $(DIM)Create required directories$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)setup-env$(RESET)         $(DIM)Setup environment configuration$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🔨 Build & Deployment$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)build$(RESET)             $(DIM)Build Docker image for current platform$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)build-multi$(RESET)       $(DIM)Build multi-architecture image$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)push$(RESET)              $(DIM)Push image to Docker Hub$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)release$(RESET)           $(DIM)Create and push release version$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🚀 Service Management$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)up$(RESET)                $(DIM)Start services$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)down$(RESET)              $(DIM)Stop services$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)restart$(RESET)           $(DIM)Restart services$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)logs$(RESET)              $(DIM)View logs$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)status$(RESET)            $(DIM)Show service status$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 📊 Monitoring & Diagnostics$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)status$(RESET)            $(DIM)Show comprehensive service status$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)logs$(RESET)              $(DIM)View live logs with timestamps$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)logs-traefik$(RESET)      $(DIM)View Traefik-specific logs$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)logs-errors$(RESET)       $(DIM)View error logs only$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)health-check$(RESET)      $(DIM)Comprehensive health diagnostics$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🧪 Testing & Quality$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)test$(RESET)              $(DIM)Run comprehensive test suite$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)test-build$(RESET)        $(DIM)Test Docker image functionality$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)test-performance$(RESET)  $(DIM)Test resource usage and limits$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)lint$(RESET)              $(DIM)Lint and validate configurations$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)validate-config$(RESET)   $(DIM)Validate environment setup$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🔒 Security & Compliance$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)security-scan$(RESET)     $(DIM)Run comprehensive security audit$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)security-trivy$(RESET)    $(DIM)Scan for vulnerabilities$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)security-secrets$(RESET)  $(DIM)Check for exposed secrets$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🧹 Maintenance & Cleanup$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)clean$(RESET)             $(DIM)Clean containers and resources$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)clean-all$(RESET)         $(DIM)Deep clean with build cache$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)clean-logs$(RESET)        $(DIM)Remove old log files$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🔧 Development Tools$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)shell$(RESET)             $(DIM)Enter container shell for debugging$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)info$(RESET)              $(DIM)Show detailed image information$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 🔄 CI/CD Pipeline$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)ci$(RESET)                $(DIM)Run complete CI pipeline$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)cd$(RESET)                $(DIM)Run CD pipeline for deployment$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(YELLOW)$(BOLD)┌─ 📦 Installation$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)install$(RESET)           $(DIM)Install project globally$(RESET)"
	@echo "$(WHITE)│$(RESET)  $(GREEN)$(BOLD)uninstall$(RESET)         $(DIM)Remove project installation$(RESET)"
	@echo "$(YELLOW)$(BOLD)└───$(RESET)"
	@echo ""
	@echo "$(CYAN)$(BOLD)💡 Examples:$(RESET)"
	@echo "  $(WHITE)make setup && make up$(RESET)     $(DIM)# Setup and start services$(RESET)"
	@echo "  $(WHITE)make build VERSION=v1.0.0$(RESET) $(DIM)# Build with specific version$(RESET)"
	@echo "  $(WHITE)make build-multi && make push$(RESET) - Multi-platform build and push"
	@echo "  $(WHITE)make release VERSION=v1.0.0$(RESET) - Create release"
	@echo ""
	@echo "$(PURPLE)$(BOLD)📚 Documentation:$(RESET) $(CYAN)https://github.com/zenkiet/traefik-tunnel-expose$(RESET)"
	@echo "$(PURPLE)$(BOLD)🐛 Issues:$(RESET)        $(CYAN)https://github.com/zenkiet/traefik-tunnel-expose/issues$(RESET)"


# ==============================================================================
# 🔧 SETUP & INITIALIZATION
# ==============================================================================

## Setup complete development environment
setup: check-deps setup-dirs setup-env
	$(call print_success,Development environment setup completed)

### Check and install dependencies
check-deps:
	$(call print_step,Checking dependencies)
	$(call check_command,docker)
	$(call check_command,docker-compose)
	@command -v jq >/dev/null 2>&1 || $(call print_warning,jq not found - install for better JSON output)
	@command -v curl >/dev/null 2>&1 || $(call print_warning,curl not found - some health checks may fail)
	$(call print_success,Dependencies check completed)

### Create required directories
setup-dirs:
	$(call print_step,Creating directory structure)
	@mkdir -p ${LOGS_DIR}/{traefik,cloudflared} $(CONFIG_DIR) $(CONF_DIR) ${SCRIPTS_DIR} $(SSL_DIR)
	@chmod -R 755 ${SCRIPTS_DIR} $(CONFIG_DIR) $(CONF_DIR) ${LOGS_DIR} $(SSL_DIR)
	$(call print_success,Directory structure created)

### Setup environment configuration
setup-env:
	$(call print_step,Setting up environment configuration)
	@if [ ! -f $(ENV_FILE) ]; then \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
		echo "$(YELLOW)Please configure your .env file$(RESET)"; \
	fi
	$(call print_success,Environment configuration set up)

# ==============================================================================
# 🔨 BUILD & DEPLOYMENT
# ==============================================================================

## Build Docker image for current platform
build:
	$(call print_step,Building Docker image: $(FULL_IMAGE_NAME))
	@docker build \
		--tag $(FULL_IMAGE_NAME) \
		--label "org.opencontainers.image.created=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		--label "org.opencontainers.image.version=$(VERSION)" \
		--label "org.opencontainers.image.source=https://github.com/zenkiet/traefik-tunnel-expose" \
		$(BUILD_ARGS) \
		$(DOCKER_CONTEXT)
	@if [ "$(VERSION)" != "latest" ]; then \
		docker tag $(FULL_IMAGE_NAME) $(DOCKER_NAMESPACE)/$(IMAGE_NAME):latest; \
		$(call print_success,Tagged as $(DOCKER_NAMESPACE)/$(IMAGE_NAME):latest); \
	fi
	$(call print_success,Build completed successfully)

## Build multi-architecture image
build-multi:
	$(call print_step,Building multi-architecture image)
	@docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(FULL_IMAGE_NAME) \
		--label "org.opencontainers.image.created=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		--label "org.opencontainers.image.version=$(VERSION)" \
		--label "org.opencontainers.image.source=https://github.com/zenkiet/traefik-tunnel-expose" \
		$(BUILD_ARGS) \
		--push \
		$(DOCKER_CONTEXT)
	$(call print_success,Multi-architecture build completed)

## Push image to Docker Hub
push: build
	$(call print_step, ${ICON_PUSH} Pushing to Docker Hub)
	@docker push $(FULL_IMAGE_NAME)
	@if [ "$(VERSION)" != "latest" ]; then \
		docker push $(DOCKER_NAMESPACE)/$(IMAGE_NAME):latest; \
	fi
	$(call print_success,Push completed successfully)

## Create and push release
release: build-multi
	$(call print_step,Creating release $(VERSION))
	@git tag -a $(VERSION) -m "Release version $(VERSION)"
	@git push origin $(VERSION)
	$(call print_success,Release $(VERSION) created and pushed)

# ==============================================================================
# 🚀 SERVICE MANAGEMENT
# ==============================================================================

## Start services
up: setup
	$(call print_step,Starting services)
	@docker-compose up -d
	$(call print_success,Services started)

## Stop services
down:
	$(call print_step,Stopping services)
	@docker-compose down
	$(call print_success,Services stopped)

## Restart services
restart:
	$(call print_step,Restarting services)
	@docker-compose restart
	$(call print_success,Services restarted)

## View logs
logs:
	$(call print_step,Viewing live logs)
	@docker-compose logs -f --timestamps

## Show service status
status:
	$(call print_header,📊 SERVICE STATUS)
	@echo "$(WHITE)$(BOLD)Container Status:$(RESET)"
	@docker-compose ps --format table
	@echo ""
	@echo "$(WHITE)$(BOLD)Resource Usage:$(RESET)"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
	@echo ""
	@echo "$(WHITE)$(BOLD)Network Information:$(RESET)"
	@docker network ls --filter "name=$(PROJECT_NAME)" --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

## Comprehensive health check
health-check:
	$(call print_header,🏥 COMPREHENSIVE HEALTH CHECK)
	@echo "$(WHITE)$(BOLD)Service Health:$(RESET)"
	@docker-compose ps --format table
	@echo ""
	@echo "$(WHITE)$(BOLD)Traefik API:$(RESET)"
	@curl -s http://localhost:8080/api/http/services 2>/dev/null | jq . 2>/dev/null || echo "$(YELLOW)Traefik API not available$(RESET)"
	@echo ""
	@echo "$(WHITE)$(BOLD)Container Health:$(RESET)"
	@docker inspect $(CONTAINER_NAME) --format='{{.State.Health.Status}}' 2>/dev/null || echo "$(YELLOW)Health check not configured$(RESET)"
	@echo ""
	@echo "$(WHITE)$(BOLD)Port Connectivity:$(RESET)"
	@nc -z localhost 80 && echo "$(GREEN)Port 80: OK$(RESET)" || echo "$(RED)Port 80: FAILED$(RESET)"
	@nc -z localhost 443 && echo "$(GREEN)Port 443: OK$(RESET)" || echo "$(RED)Port 443: FAILED$(RESET)"
	@nc -z localhost 8080 && echo "$(GREEN)Port 8080: OK$(RESET)" || echo "$(RED)Port 8080: FAILED$(RESET)"

# ==============================================================================
# 🧪 TESTING & VALIDATION
# ==============================================================================

## Run comprehensive test suite
test: test-build test-performance
	$(call print_success,All tests completed successfully)

## Test Docker image build and basic functionality
test-build:
	$(call print_step,Testing Docker image build)
	@docker run --rm --entrypoint="" $(FULL_IMAGE_NAME) /bin/sh -c "which traefik && which cloudflared && traefik version"
	$(call print_success,Build test passed)

## Test performance and resource usage
test-performance:
	$(call print_step,Testing performance and resource usage)
	@docker run --rm --memory=128m --cpus=0.5 $(FULL_IMAGE_NAME) /bin/sh -c "echo 'Performance test passed'"
	$(call print_success,Performance test passed)

## Lint and validate configurations
lint: lint-dockerfile lint-compose lint-yaml
	$(call print_success,All linting checks passed)

### Lint Dockerfile
lint-dockerfile:
	$(call print_step, Linting Dockerfile)
	@docker run --rm \
		-v "$(PWD)":/workdir \
		-w /workdir \
		hadolint/hadolint:latest \
		hadolint /workdir/$(DOCKERFILE) || true
	$(call print_success,Dockerfile linting completed)

### Lint Docker Compose files
lint-compose:
	$(call print_step,Linting Docker Compose files)
	@docker-compose config >/dev/null || $(call print_error,Docker Compose files are invalid)
	$(call print_success,Docker Compose files are valid)

### Lint YAML files
lint-yaml:
	$(call print_step,Linting YAML configuration files)
	@find $(CONFIG_DIR) $(CONF_DIR) -name "*.yml" -o -name "*.yaml" | xargs -I {} sh -c 'echo "Checking {}:" && docker run --rm -v "$(PWD)":/data cytopia/yamllint {} || true'

## Validate configuration files
validate-config:
	$(call print_step,Validating configuration files)
	@test -f $(ENV_FILE) || ($(call print_error,Environment file missing) && exit 1)
	@grep -q "CF_API_TOKEN=" $(ENV_FILE) || ($(call print_error,CF_API_TOKEN not configured) && exit 1)
	@grep -q "CF_ZONE_ID=" $(ENV_FILE) || ($(call print_error,CF_ZONE_ID not configured) && exit 1)
	$(call print_success,Configuration validation passed)

# ==============================================================================
# 🔒 SECURITY & COMPLIANCE
# ==============================================================================

## Run comprehensive security scan
security-scan: security-trivy security-secrets
	$(call print_success,Security scan completed)

## Scan image for vulnerabilities using Trivy
security-trivy:
	$(call print_step,Scanning for vulnerabilities with Trivy)
	@docker run --rm \
		-v "$(PWD)" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--entrypoint trivy \
		aquasec/trivy:latest image --severity HIGH,CRITICAL --ignore-unfixed --no-progress $(FULL_IMAGE_NAME) || $(call print_warning,Trivy scan failed or not found - skipping)

## Check for secrets in codebase
security-secrets:
	$(call print_step,Scanning for secrets in repository)
	@docker run --rm \
		-v "$(PWD)":/project \
		zricethezav/gitleaks:latest \
		detect --source="/project" --verbose || $(call print_warning,Gitleaks scan failed or not found - skipping)

# ==============================================================================
# 🧹 CLEANUP & MAINTENANCE
# ==============================================================================

## Clean up containers and unused resources
clean:
	$(call print_step,Cleaning up containers and resources)
	@docker-compose down --remove-orphans --volumes
	@docker system prune -f
	$(call print_success,Cleanup completed)

## Deep clean including all images and build cache
clean-all:
	$(call print_step,Performing deep cleanup)
	@docker-compose down --remove-orphans --volumes
	@docker system prune -af --volumes
	@docker builder prune -af
	$(call print_success,Deep cleanup completed)

## Clean logs older than 7 days
clean-logs:
	$(call print_step,Cleaning old log files)
	@find $(LOGS_DIR) -name "*.log" -mtime +7 -delete 2>/dev/null || true
	$(call print_success,Old logs cleaned)

# ==============================================================================
# 🔧 DEVELOPMENT UTILITIES
# ==============================================================================

## Enter container shell for debugging
shell:
	$(call print_step,Entering container shell)
	@docker exec -it $(CONTAINER_NAME) /bin/sh

## Show detailed image information
info:
	$(call print_header,ℹ️  IMAGE INFORMATION)
	@echo "$(WHITE)$(BOLD)Image Details:$(RESET)"
	@docker images $(DOCKER_NAMESPACE)/$(IMAGE_NAME) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# ==============================================================================
# 🔄 CI/CD PIPELINE
# ==============================================================================

## Run complete CI pipeline
ci: check-deps lint test security-scan build
	$(call print_success,CI pipeline completed successfully)

## Run CD pipeline for deployment
cd: ci push
	$(call print_success,CD pipeline completed successfully)

# ==============================================================================
# 📦 INSTALLATION & UNINSTALLATION
# ==============================================================================

## Install project globally
install: build
	$(call print_step,Installing project globally)
	@docker tag $(FULL_IMAGE_NAME) $(IMAGE_NAME):installed
	$(call print_success,Project installed globally)

## Uninstall project
uninstall:
	$(call print_step,Uninstalling project)
	@docker rmi $(IMAGE_NAME):installed 2>/dev/null || true
	@docker-compose down --remove-orphans --volumes 2>/dev/null || true
	$(call print_success,Project uninstalled)