# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Build/Format/Lint Commands (REQUIRED):**
- `make format` - Format shell script with shfmt
- `make lint` - Lint shell script with shellcheck  
- `make check` - Run both format check and lint (ALWAYS run this after making changes to the shell script)
- `make install-hooks` - Install git pre-commit hook that runs formatting and checks

**Database Operations:**
- `export WF_DB_PATH="/path/to/your/database.db"` - Set database path (required)
- `./wf init ~/my-wf.db` - Create new database at specified path
- `./wf tool overview` - Show complete usage guide for LLM agents

## Code Architecture

**Core Components:**
1. **Single Shell Script (`wf`)**: Complete CLI tool managing SQLite database with workflow tracking
2. **Database Schema**: Relational design with 5 core entities and junction tables for many-to-many relationships
3. **Entity System**: Tasks, Threads (conversations), Artifacts (files/docs), Prompts (reusable AI prompts), and Tags

**Key Architectural Patterns:**
- **Command Routing**: Space-separated commands normalized to dash format (`add thread` → `add-thread`)
- **Tag System**: Auto-created labels for filtering across all entity types with comma-separated input
- **Linking System**: Many-to-many relationships between entities (artifacts↔threads, prompts↔tasks, etc.)
- **Content Management**: File content stored as escaped text in SQLite with summarization support

**Database Design:**
- Core tables: `tasks`, `amp_threads`, `artifacts`, `prompts`, `tags`  
- Junction tables: `task_tags`, `thread_tags`, `artifact_tags`, `prompt_tags`, plus cross-linking tables
- Foreign key constraints with CASCADE deletes for data integrity

**CLI Design Philosophy:**
- Minimal dependencies (bash, sqlite3, shfmt, shellcheck)
- Consistent argument parsing across all commands
- Standardized filtering with `--all`, `--count N`, and tag filters
- Piping support for AI integration (`./wf dump artifact 1 | claude "prompt"`)

**LLM Integration Focus:**
- Built specifically for AI coding workflows and session continuity
- Prompt library management with versioning via updates
- Context preservation across coding sessions through artifacts and threads
- Direct piping to AI tools for seamless workflows

## Key Shell Script Conventions

- Uses `sqlite3` for all database operations with careful SQL escaping
- Environment variable `WF_DB_PATH` (defaults to `/wf.db`) for database location
- Consistent error handling with descriptive messages and proper exit codes
- Command parsing converts space-separated commands to internal dash format
- Tag processing splits comma-separated values and trims whitespace

## Important Notes

- Always run `make check` when you make changes to the shell script
- The tool is designed for LLM agentic coding workflows - maintaining context across sessions
- Database must be initialized before use with `./wf init <path>`
- All content is stored as text with proper SQL escaping for single quotes