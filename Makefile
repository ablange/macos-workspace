.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help lint test

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_-]+:.*## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## Run static checks
	./scripts/lint.sh

test: ## Run repository invariant tests
	./scripts/test.sh
