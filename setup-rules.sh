#!/bin/bash

# Setup Universal Rules for a Project
# Usage: ./setup-rules.sh /path/to/your/project

set -e

# Get the directory where this script is located (universal-rules folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target project directory (passed as argument or current directory)
TARGET_DIR="${1:-.}"

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    echo "Error: Directory '$1' does not exist."
    exit 1
}

CLAUDE_DIR="$TARGET_DIR/.claude"
GITIGNORE="$TARGET_DIR/.gitignore"
TODO_FILE="$CLAUDE_DIR/TODO.md"

echo "=========================================="
echo "  Universal Rules Setup"
echo "=========================================="
echo ""
echo "Source:  $SCRIPT_DIR"
echo "Target:  $TARGET_DIR"
echo ""

# Step 1: Create .claude folder
if [ -d "$CLAUDE_DIR" ]; then
    echo "[1/5] .claude folder already exists"
else
    mkdir -p "$CLAUDE_DIR"
    echo "[1/5] Created .claude folder"
fi

# Step 2: Copy all .md files (except TODO.md template)
MD_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.md" ! -name "TODO-template.md" | wc -l)
for file in "$SCRIPT_DIR"/*.md; do
    filename=$(basename "$file")
    if [ "$filename" != "TODO-template.md" ]; then
        cp "$file" "$CLAUDE_DIR/"
    fi
done
echo "[2/5] Copied $MD_COUNT rule files to .claude/"

# List copied files
echo ""
echo "     Copied files:"
for file in "$CLAUDE_DIR"/*.md; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "TODO.md" ]; then
        echo "       - $(basename "$file")"
    fi
done
echo ""

# Step 3: Create TODO.md from template
if [ -f "$TODO_FILE" ]; then
    echo "[3/5] TODO.md already exists (preserving existing)"
else
    # Get project name from directory
    PROJECT_NAME=$(basename "$TARGET_DIR")

    cat > "$TODO_FILE" << 'TODOEOF'
# Project TODO

> This file tracks project progress, decisions, and tasks.
> Claude will read and update this file throughout the project lifecycle.

## Current Sprint / Focus

- [ ] Define project requirements
- [ ] Set up project structure

## Backlog

<!-- Add future tasks here -->

## In Progress

<!-- Tasks currently being worked on -->

## Completed

<!--
Mark completed items as:
- [x] ~~Task description~~ (date or session)
-->

## Decisions Log

<!--
Document important decisions:
- **Decision**: Description of what was decided and why
-->

---

*Last updated: Project initialization*
TODOEOF

    echo "[3/5] Created TODO.md for progress tracking"
fi

# Step 4: Add to .gitignore
if [ -f "$GITIGNORE" ]; then
    if grep -qxF ".claude/" "$GITIGNORE" 2>/dev/null || grep -qxF ".claude" "$GITIGNORE" 2>/dev/null; then
        echo "[4/5] .claude/ already in .gitignore"
    else
        echo ".claude/" >> "$GITIGNORE"
        echo "[4/5] Added .claude/ to .gitignore"
    fi
else
    echo ".claude/" > "$GITIGNORE"
    echo "[4/5] Created .gitignore with .claude/"
fi

# Step 5: Complete
echo "[5/5] Setup complete!"
echo ""
echo "=========================================="
echo "  Rules are ready in: $CLAUDE_DIR"
echo "=========================================="
echo ""
echo "Files created:"
echo "  - Rule files (.md) for coding standards"
echo "  - TODO.md for progress tracking"
echo ""
echo "Claude will now:"
echo "  1. Read these rules at the start of each session"
echo "  2. Track progress in TODO.md"
echo "  3. Update TODO.md as work progresses"
