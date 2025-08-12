# WF Tool - Go Build Makefile
# Build outputs go to dist/ directory to avoid polluting working directory
# The 'wf' shell script remains the main entry point

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# Binary info
BINARY_NAME=wf-go
BINARY_UNIX=$(BINARY_NAME)_unix
BINARY_WINDOWS=$(BINARY_NAME).exe
BINARY_MAC=$(BINARY_NAME)_darwin

# Build directory
DIST_DIR=dist

# Default target
.PHONY: all
all: test build

# Build for current platform
.PHONY: build
build:
	@echo "Building $(BINARY_NAME) for current platform..."
	@mkdir -p $(DIST_DIR)
	$(GOBUILD) -o $(DIST_DIR)/$(BINARY_NAME) -v ./

# Build for all platforms
.PHONY: build-all
build-all: build-linux build-windows build-darwin

# Build for Linux
.PHONY: build-linux
build-linux:
	@echo "Building for Linux..."
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_UNIX) -v ./

# Build for Windows
.PHONY: build-windows
build-windows:
	@echo "Building for Windows..."
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_WINDOWS) -v ./

# Build for macOS
.PHONY: build-darwin
build-darwin:
	@echo "Building for macOS..."
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GOBUILD) -o $(DIST_DIR)/$(BINARY_MAC) -v ./

# Build optimized release binaries
.PHONY: build-release
build-release:
	@echo "Building optimized release binaries..."
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -ldflags="-w -s" -o $(DIST_DIR)/$(BINARY_UNIX) -v ./
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) -ldflags="-w -s" -o $(DIST_DIR)/$(BINARY_WINDOWS) -v ./
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GOBUILD) -ldflags="-w -s" -o $(DIST_DIR)/$(BINARY_MAC) -v ./
	@echo "Release binaries built with optimizations (-ldflags='-w -s')"

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	$(GOTEST) -v ./...

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "Running tests with coverage..."
	@mkdir -p $(DIST_DIR)
	$(GOTEST) -coverprofile=$(DIST_DIR)/coverage.out ./...
	$(GOCMD) tool cover -html=$(DIST_DIR)/coverage.out -o $(DIST_DIR)/coverage.html
	@echo "Coverage report: $(DIST_DIR)/coverage.html"

# Run tests with race detection
.PHONY: test-race
test-race:
	@echo "Running tests with race detection..."
	$(GOTEST) -race -short ./...

# Benchmark tests
.PHONY: bench
bench:
	@echo "Running benchmarks..."
	$(GOTEST) -bench=. -benchmem ./...

# Install dependencies
.PHONY: deps
deps:
	@echo "Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) verify

# Update dependencies
.PHONY: deps-update
deps-update:
	@echo "Updating dependencies..."
	$(GOMOD) tidy
	$(GOGET) -u ./...

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	$(GOCLEAN)
	rm -rf $(DIST_DIR)

# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	$(GOCMD) fmt ./...

# Lint code (requires golangci-lint)
.PHONY: lint
lint:
	@echo "Running linter..."
	@which golangci-lint > /dev/null || (echo "golangci-lint not found. Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; exit 1)
	golangci-lint run

# Vet code
.PHONY: vet
vet:
	@echo "Running go vet..."
	$(GOCMD) vet ./...

# Security check (requires gosec)
.PHONY: security
security:
	@echo "Running security checks..."
	@which gosec > /dev/null || (echo "gosec not found. Install with: go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest"; exit 1)
	gosec ./...

# Check for vulnerabilities (requires govulncheck)
.PHONY: vuln-check
vuln-check:
	@echo "Checking for vulnerabilities..."
	@which govulncheck > /dev/null || (echo "govulncheck not found. Install with: go install golang.org/x/vuln/cmd/govulncheck@latest"; exit 1)
	govulncheck ./...

# Development workflow - format, vet, test, build
.PHONY: dev
dev: fmt vet test build

# CI workflow - format check, vet, test with coverage, build all platforms
.PHONY: ci
ci: fmt-check vet test-coverage build-all

# Check if code is formatted (for CI)
.PHONY: fmt-check
fmt-check:
	@echo "Checking code formatting..."
	@test -z "$(shell $(GOCMD) fmt -l .)" || (echo "Code is not formatted. Run 'make fmt'"; exit 1)

# Install the binary to GOPATH/bin
.PHONY: install
install:
	@echo "Installing $(BINARY_NAME) to GOPATH/bin..."
	$(GOCMD) install ./

# Uninstall the binary from GOPATH/bin
.PHONY: uninstall
uninstall:
	@echo "Uninstalling $(BINARY_NAME) from GOPATH/bin..."
	rm -f $(shell $(GOCMD) env GOPATH)/bin/$(BINARY_NAME)

# Run the built binary (for testing)
.PHONY: run
run: build
	@echo "Running $(BINARY_NAME)..."
	./$(DIST_DIR)/$(BINARY_NAME)

# Run with arguments (make run-args ARGS="tool-overview")
.PHONY: run-args
run-args: build
	@echo "Running $(BINARY_NAME) with args: $(ARGS)"
	./$(DIST_DIR)/$(BINARY_NAME) $(ARGS)

# Show binary sizes
.PHONY: size
size:
	@echo "Binary sizes:"
	@ls -lh $(DIST_DIR)/* 2>/dev/null || echo "No binaries found in $(DIST_DIR)/"

# Show help
.PHONY: help
help:
	@echo "WF Tool - Go Build Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build         - Build for current platform"
	@echo "  build-all     - Build for all platforms (Linux, Windows, macOS)"
	@echo "  build-linux   - Build for Linux"
	@echo "  build-windows - Build for Windows"  
	@echo "  build-darwin  - Build for macOS"
	@echo "  build-release - Build optimized release binaries for all platforms"
	@echo ""
	@echo "  test          - Run tests"
	@echo "  test-coverage - Run tests with coverage report"
	@echo "  test-race     - Run tests with race detection"
	@echo "  bench         - Run benchmark tests"
	@echo ""
	@echo "  deps          - Download dependencies"
	@echo "  deps-update   - Update dependencies"
	@echo ""
	@echo "  fmt           - Format code"
	@echo "  fmt-check     - Check if code is formatted (for CI)"
	@echo "  vet           - Run go vet"
	@echo "  lint          - Run golangci-lint (requires installation)"
	@echo "  security      - Run gosec security checks (requires installation)"
	@echo "  vuln-check    - Check for vulnerabilities (requires govulncheck)"
	@echo ""
	@echo "  clean         - Clean build artifacts"
	@echo "  install       - Install binary to GOPATH/bin"
	@echo "  uninstall     - Remove binary from GOPATH/bin"
	@echo ""
	@echo "  run           - Build and run the binary"
	@echo "  run-args      - Build and run with arguments (ARGS='...')"
	@echo "  size          - Show binary sizes"
	@echo ""
	@echo "  dev           - Development workflow (fmt, vet, test, build)"
	@echo "  ci            - CI workflow (fmt-check, vet, test-coverage, build-all)"
	@echo "  all           - Default target (test, build)"
	@echo "  help          - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make build                    # Build for current platform"
	@echo "  make build-release           # Build optimized release binaries"
	@echo "  make test-coverage           # Run tests with coverage"
	@echo "  make run-args ARGS='init'    # Run with 'init' argument"
	@echo "  make dev                     # Full development workflow"