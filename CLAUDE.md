# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`wf` is a CLI tool for LLM agentic coding workflows that helps store context, retrieve it, and keep AIs on track. It's a hybrid Go/shell implementation with a SQLite database backend for tracking tasks, threads, artifacts, and prompts across coding sessions.

## Architecture

**Entry Points:**
- `wf` - Bash script that implements the full feature set (current production version)  
- `dist/wf-go` - Go binary (bootstrap implementation, limited features)

**Core Components:**
- `main.go` - Go CLI entry point with basic command routing
- `internal/commands/` - Command handlers (Go implementation incomplete)
- `internal/database/` - SQLite database layer with connection management
- `internal/config/` - Configuration management (DB path from WF_DB_PATH env var)
- `internal/database/models/` - Data models for Task, Thread, Artifact, Prompt entities

**Database Schema:**
The system uses SQLite with tables for tasks, threads, artifacts, prompts, tags, and junction tables for many-to-many relationships. Each entity can be tagged and linked to other entities.

## Build & Development Commands

**Primary Development Workflow:**
```bash
make dev          # Format, vet, test, and build
make build        # Build for current platform 
make test         # Run tests
make fmt          # Format code
make vet          # Run go vet
```

**Testing:**
```bash
make test                    # Standard tests
make test-coverage          # Tests with HTML coverage report  
make test-race              # Race condition detection
make bench                  # Benchmark tests
```

**Release & Multi-platform:**
```bash
make build-all              # Build for Linux, Windows, macOS
make build-release          # Optimized release binaries
```

**Code Quality:**
```bash
make lint                   # golangci-lint (requires installation)
make security              # gosec security checks
make vuln-check            # Go vulnerability scanner
```

**Development Tools:**
```bash
make run                    # Build and run binary
make run-args ARGS="init"   # Run with arguments
make install               # Install to GOPATH/bin
```

## Database Setup

The tool requires a SQLite database. Set the database path:
```bash
export WF_DB_PATH=/path/to/your/plans.db
```

Initialize a new database:
```bash
./wf init ~/my-project.db
```

## Key Commands for AI Development

**Get tool overview:**
```bash
./wf tool-overview
```

**Store artifacts (design docs, plans, code snippets):**
```bash  
./wf add-artifact "design.md" architecture,planning
./wf add-artifact "solution.md" implementation,fix
```

**Retrieve content for AI analysis:**
```bash
./wf dump-artifact 9
./wf list-artifacts planning
```

**Track conversations and work:**
```bash
./wf add "Fix the bug" urgent,backend
./wf add-thread "conv123" "Discussed the fix" false bug
./wf list-tasks urgent
```

## Code Patterns

**Command Structure:** All commands follow the pattern in the bash script with functions like `add_task()`, `show_task()`, etc. The Go implementation mirrors this structure but is incomplete.

**Database Access:** Uses raw SQL queries with SQLite. The Go code uses the modernc.org/sqlite driver (pure Go, no CGO).

**Error Handling:** Shell script uses exit codes and stderr. Go code should follow standard Go error handling patterns.

## Current State

- **Production:** The bash script (`./wf`) is the complete, working implementation
- **Development:** Go implementation in early bootstrap phase with only basic structure
- **Migration:** This appears to be a rewrite from bash to Go while maintaining compatibility

## Development Notes

- The project is currently on `feat/rewrite/bootstrap` branch, suggesting active rewrite work
- Go module uses `go 1.24.5` with SQLite and UUID dependencies  
- The bash implementation serves as the reference for Go feature development
- Database schema is fully defined in the bash script's init function (wf:88-195)