.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help lint test prerequisites brew git_pull

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_-]+:.*## / {printf "  %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## Run static checks
	./scripts/lint.sh

test: ## Run repository invariant tests
	./scripts/test.sh

prerequisites: ## Verify Xcode CLT and install Homebrew if missing
	./scripts/prerequisites.sh

brew: ## Install missing Brewfile packages (no proactive upgrade or cleanup)
	./scripts/brew.sh

git_pull: ## Refresh local main after a PR merge
	./scripts/git_pull.sh
