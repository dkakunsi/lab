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
	@echo "  make publish-dev-aio VERSION=1.0.0"
	@echo "  make publish-ops VERSION=1.0.0"
	@echo "  make publish-dev-aio REGISTRY=ghcr.io VERSION=1.0.0"

.PHONY: publish-dev-aio
publish-dev-aio: ## Build and push multi-architecture dev image
	@echo "Building and pushing multi-architecture Docker image for dev..."
	docker buildx build \
		--push \
		--platform linux/amd64,linux/arm64 \
		--file ./dev/aio.Dockerfile \
		--tag $(REGISTRY)/dkakunsi/lab/dev-aio:$(VERSION) \
		--tag $(REGISTRY)/dkakunsi/lab/dev-aio:latest \
		./dev
	@echo "Successfully built and pushed multi-architecture Docker image for dev"

.PHONY: publish-ops
publish-ops: ## Build and push multi-architecture ops image
	@echo "Building and pushing multi-architecture Docker image for ops..."
	docker buildx build \
		--push \
		--platform linux/amd64,linux/arm64 \
		--file ./ops/ops.Dockerfile \
		--tag $(REGISTRY)/dkakunsi/lab/ops:$(VERSION) \
		--tag $(REGISTRY)/dkakunsi/lab/ops:latest \
		./ops
	@echo "Successfully built and pushed multi-architecture Docker image for ops"

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
