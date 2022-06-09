SHELL := /bin/bash
export SHELLOPTS := errexit:pipefail

TEST_OUTPUT_FILE?=$(PWD)/logs

lint: ## Run go fmt and golangci-lint linters
	goimports -w ./test
	golangci-lint run ./test
	tflint
	tflint ./test

test: ## Run tests
	mkdir -p $(dir $(TEST_OUTPUT_FILE))
	go test -timeout 60m -v ./test | tee $(TEST_OUTPUT_FILE)

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: lint test help
