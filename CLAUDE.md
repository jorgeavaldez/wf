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
- `./wf migrate search` - Enable full-text search on existing databases (one-time, schema v1 → v2)
- `./wf migrate timestamps` - Add timestamps to threads and tasks (one-time, schema v2 → v3)
- `./wf tool overview` - Show complete usage guide for LLM agents

**CRITICAL: Testing with Isolated Database:**
- ALWAYS use a separate test database when making changes or testing fixes
- NEVER test against the main production database (usually set in WF_DB_PATH)
- Example testing pattern:
  ```bash
  export WF_DB_PATH="./test-changes.db"
  ./wf init ./test-changes.db
  # Run your tests here
  ./wf add task "test with 'quotes" tag1,tag2
  # Verify functionality and clean up
  rm -f ./test-changes.db
  ```
- This prevents data corruption and allows safe testing of SQL injection fixes, schema changes, etc.

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
- Timestamp columns: `created_at`, `updated_at` on `tasks` and `amp_threads` (schema v3+)
- Junction tables: `task_tags`, `thread_tags`, `artifact_tags`, `prompt_tags`, plus cross-linking tables
- Foreign key constraints with CASCADE deletes for data integrity
- No UPDATE triggers for timestamps (conflicts with FTS triggers - known SQLite limitation)

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

## CRITICAL: SQL Injection Prevention

**ALWAYS sanitize user input when constructing SQL queries:**
- User input MUST be escaped before insertion into SQL queries
- Use `sed "s/'/''/g"` to escape single quotes in all user-provided strings
- This applies to: task descriptions, thread IDs, summaries, tag labels, entity IDs, and any other user input

**Examples of proper escaping:**
```bash
# WRONG - Direct insertion (vulnerable to SQL injection)
sqlite3 "$DB_PATH" "INSERT INTO tasks (note) VALUES ('$TASK_NOTE');"

# CORRECT - Escaped input (safe)
TASK_NOTE_ESCAPED=$(echo "$TASK_NOTE" | sed "s/'/''/g")
sqlite3 "$DB_PATH" "INSERT INTO tasks (note) VALUES ('$TASK_NOTE_ESCAPED');"
```

**Common vulnerable patterns to avoid:**
- `VALUES ('$user_input')` - Always escape first
- `WHERE field = '$user_input'` - Always escape first
- Any direct variable substitution in SQL strings

**Testing for SQL injection vulnerabilities:**
- Test with inputs containing single quotes: `"foo'bar"`
- Test with SQL injection payloads: `"'; DROP TABLE tasks; --"`
- Verify data integrity is preserved and no SQL errors occur

## Full-Text Search (FTS5)

**Search Commands:**
- `./wf search tasks "search terms" [--limit N]` - Search task descriptions
- `./wf search threads "search terms" [--limit N]` - Search thread IDs and summaries
- `./wf search artifacts "search terms" [--limit N]` - Search filenames, summaries, and content
- `./wf search prompts "search terms" [--limit N]` - Search names, descriptions, and content
- `./wf search tags "search terms" [--limit N]` - Search tag labels
- `./wf migrate search` - Enable search on existing databases (one-time setup)

**Search Features:**
- BM25 relevance ranking (with fallback for older SQLite versions)
- Snippet generation for artifacts and prompts showing match context
- Default limit of 10 results, customizable with `--limit N`
- Searches across all relevant text fields per entity type
- Automatic query sanitization for FTS5 compatibility

**Query Sanitization:**
- Special characters are automatically removed from search queries to prevent FTS5 syntax errors
- Removed characters: `' " ( ) [ ] { } ^ $ * + ? | \ ; -`
- Example: `"it's working (test)"` becomes `"it working test"`
- This prevents both FTS5 syntax errors and potential injection attacks
- Use the `sanitize_fts_query()` function when implementing new search functionality

**Database Schema:**
- FTS5 virtual tables: `fts_tasks`, `fts_threads`, `fts_artifacts`, `fts_prompts`, `fts_tags`
- Automatic triggers keep FTS tables synchronized with base tables
- Migration tracking via `wf_meta` table with schema versioning
- New databases (schema v3) include FTS and timestamps from initialization
- Existing databases require migrations to enable features:
  - `./wf migrate search` for full-text search (schema v1 → v2)
  - `./wf migrate timestamps` for timestamp tracking (schema v2 → v3)

## Timestamps and Sorting

**Timestamp Tracking (Schema v3+):**
- `created_at` and `updated_at` columns on `tasks` and `amp_threads` tables
- Both timestamps automatically set on creation (set explicitly in INSERT statements)
- `updated_at` is NOT automatically maintained on updates (due to FTS trigger conflicts)
- `updated_at` remains at creation time unless explicitly updated in application code
- Existing databases can add timestamps via `./wf migrate timestamps`

**Default Sorting Behavior:**
- Tasks: Sorted by `created_at DESC, id DESC` (newest first)
- Threads: Sorted by `created_at DESC, thread_id DESC` (newest first)
- Search results: Relevance score prioritized, then timestamp, then id/thread_id
- List commands show most recent items by default (limit 5, use `--all` or `--count N` to override)

**Display Behavior:**
- `./wf show thread <id>` displays Created and Updated timestamps
- `./wf dump task <id>` displays Created and Updated timestamps
- List commands sorted by creation time but don't display timestamps (for brevity)

## Important Notes

- Always run `make check` when you make changes to the shell script
- The tool is designed for LLM agentic coding workflows - maintaining context across sessions
- Database must be initialized before use with `./wf init <path>`
- All content is stored as text with proper SQL escaping for single quotes
- Search functionality requires SQLite with FTS5 support (available in most modern distributions)
- Timestamp functionality requires running `./wf migrate timestamps` on existing databases
