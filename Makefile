# Image configuration
REGISTRY ?= ghcr.io
VERSION ?= latest

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables:"
	@echo "  REGISTRY         Docker registry (default: ghcr.io)"
	@echo "  VERSION          Image version/tag (default: latest)"
	@echo ""
	@echo "Examples:"
	@echo "  make publish-dev VERSION=1.0.0"
	@echo "  make publish-dev REGISTRY=ghcr.io VERSION=1.0.0"

.PHONY: publish-dev
publish-dev: ## Build and push multi-architecture image
	@echo "Building and pushing multi-architecture Docker image for dev-container..."
	docker buildx build \
		--push \
		--platform linux/amd64,linux/arm64 \
		--file ./dev-container/Dockerfile \
		--tag $(REGISTRY)/dkakunsi/lab/devcontainer:$(VERSION) \
		--tag $(REGISTRY)/dkakunsi/lab/devcontainer:latest \
		./dev-container
	@echo "Successfully built and pushed multi-architecture Docker image for dev-container"

.PHONY: login
login: ## Login to the Docker registry
	@echo "Logging in to registry: $(REGISTRY)"
	@if [ "$(REGISTRY)" = "ghcr.io" ]; then \
		echo "For GitHub Container Registry, use: docker login ghcr.io -u USERNAME"; \
		docker login ghcr.io; \
	elif [ "$(REGISTRY)" = "docker.io" ]; then \
		docker login; \
	else \
		docker login $(REGISTRY); \
	fi

.DEFAULT_GOAL := help
