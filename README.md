# wf

Simple CLI for LLM agentic coding workflows. Store context, retrieve it, keep AIs on track.

## Setup

```bash
# Make sure you have the wf command in your PATH
export WF_DB_PATH=/path/to/your/plans.db
```

## LLM Workflow

Tell your AI to check what's available:
```bash
wf tool overview
```

Tell it to grab specific artifacts to follow:
```bash
wf dump artifact 9
```

The AI can store its own artifacts internally:
```bash
# AI saves design docs, plans, solutions
wf add artifact "design.md" architecture,planning
wf add artifact "solution.md" implementation,fix
```

## Basic Usage

```bash
# Track work
wf add "Fix the bug" urgent,backend

# Log AI conversations  
wf add thread "conv123" "Discussed the fix" false bug

# Find stuff later
wf list tasks urgent
wf dump artifact 1 | claude "analyze this"
```

Perfect for maintaining context across AI coding sessions.