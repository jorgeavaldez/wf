# Tasks Tool

Simple CLI for LLM agentic coding workflows. Store context, retrieve it, keep AIs on track.

## Setup

```bash
# Make sure you have the tasks command in your PATH
export TASKS_DB_PATH=/path/to/your/plans.db
```

## LLM Workflow

Tell your AI to check what's available:
```bash
tasks tool-overview
```

Tell it to grab specific artifacts to follow:
```bash
tasks dump-artifact 9
```

The AI can store its own artifacts internally:
```bash
# AI saves design docs, plans, solutions
tasks add-artifact "design.md" architecture,planning
tasks add-artifact "solution.md" implementation,fix
```

## Basic Usage

```bash
# Track work
tasks add "Fix the bug" urgent,backend

# Log AI conversations  
tasks add-thread "conv123" "Discussed the fix" false bug

# Find stuff later
tasks list-tasks urgent
tasks dump-artifact 1 | claude "analyze this"
```

Perfect for maintaining context across AI coding sessions.