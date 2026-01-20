#!/bin/bash

# Setup Universal Rules for a Project
# Usage: ./setup-rules.sh /path/to/your/project [project-name]
# If project-name is not provided, the directory name will be used

set -e

# GitHub account
GITHUB_USER="kvooak"

# Get the directory where this script is located (universal-rules folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target project directory (passed as argument or current directory)
TARGET_DIR="${1:-.}"

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    echo "Error: Directory '$1' does not exist."
    exit 1
}

# Project name (passed as second argument or derived from directory)
PROJECT_NAME="${2:-$(basename "$TARGET_DIR")}"

CLAUDE_DIR="$TARGET_DIR/.claude"
GITIGNORE="$TARGET_DIR/.gitignore"
TODO_FILE="$CLAUDE_DIR/TODO.md"
PROJECT_FILE="$CLAUDE_DIR/PROJECT.md"

echo "=========================================="
echo "  Universal Rules Setup"
echo "=========================================="
echo ""
echo "Source:  $SCRIPT_DIR"
echo "Target:  $TARGET_DIR"
echo "Project: $PROJECT_NAME"
echo "GitHub:  $GITHUB_USER/$PROJECT_NAME"
echo ""

# Step 1: Create .claude folder
if [ -d "$CLAUDE_DIR" ]; then
    echo "[1/7] .claude folder already exists"
else
    mkdir -p "$CLAUDE_DIR"
    echo "[1/7] Created .claude folder"
fi

# Step 2: Copy all .md files (except TODO.md and PROJECT.md templates)
MD_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.md" ! -name "TODO-template.md" ! -name "PROJECT-template.md" | wc -l)
for file in "$SCRIPT_DIR"/*.md; do
    filename=$(basename "$file")
    if [ "$filename" != "TODO-template.md" ] && [ "$filename" != "PROJECT-template.md" ]; then
        cp "$file" "$CLAUDE_DIR/"
    fi
done
echo "[2/7] Copied $MD_COUNT rule files to .claude/"

# List copied files
echo ""
echo "     Copied files:"
for file in "$CLAUDE_DIR"/*.md; do
    if [ -f "$file" ]; then
        fname=$(basename "$file")
        if [ "$fname" != "TODO.md" ] && [ "$fname" != "PROJECT.md" ]; then
            echo "       - $fname"
        fi
    fi
done
echo ""

# Step 3: Create TODO.md from template
if [ -f "$TODO_FILE" ]; then
    echo "[3/7] TODO.md already exists (preserving existing)"
else
    cat > "$TODO_FILE" << TODOEOF
# Project TODO: $PROJECT_NAME

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

    echo "[3/7] Created TODO.md for progress tracking"
fi

# Step 4: Create PROJECT.md from template
if [ -f "$PROJECT_FILE" ]; then
    echo "[4/7] PROJECT.md already exists (preserving existing)"
else
    cat > "$PROJECT_FILE" << PROJECTEOF
# Project: $PROJECT_NAME

## Overview

> Describe what this project does and its purpose.

## Tech Stack

- **Language**:
- **Framework**:
- **Database**:
- **ORM/ODM**:
- **Styling**:
- **Testing**:

## Architecture

> Brief description of architectural pattern used.

### Directory Structure

\`\`\`
/src
  # Add project structure here
\`\`\`

## Key Components

<!--
### ComponentName
- **Purpose**: What it does
- **Location**: /path/to/component
- **Dependencies**: What it depends on
-->

## Data Models

<!--
### ModelName
\`\`\`
field1: type - description
field2: type - description
\`\`\`
-->

## API Endpoints

<!--
### \`METHOD /endpoint\`
- **Purpose**: What it does
- **Request**: { field: type }
- **Response**: { field: type }
-->

## Environment Variables

\`\`\`
# Add environment variables here
\`\`\`

## Conventions

-

## Key Dependencies

-

---

*Last updated: Project initialization*
PROJECTEOF

    echo "[4/7] Created PROJECT.md for project documentation"
fi

# Step 5: Add to .gitignore
if [ -f "$GITIGNORE" ]; then
    if grep -qxF ".claude/" "$GITIGNORE" 2>/dev/null || grep -qxF ".claude" "$GITIGNORE" 2>/dev/null; then
        echo "[5/7] .claude/ already in .gitignore"
    else
        echo ".claude/" >> "$GITIGNORE"
        echo "[5/7] Added .claude/ to .gitignore"
    fi
else
    echo ".claude/" > "$GITIGNORE"
    echo "[5/7] Created .gitignore with .claude/"
fi

# Step 6: Initialize Git repository
cd "$TARGET_DIR"
if [ -d ".git" ]; then
    echo "[6/7] Git repository already initialized"
else
    git init
    echo "[6/7] Initialized Git repository"
fi

# Step 7: Create GitHub repository and push
echo "[7/7] Setting up GitHub repository..."

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo ""
    echo "WARNING: GitHub CLI not authenticated."
    echo "Run 'gh auth login' and then manually create the repo:"
    echo "  gh repo create $PROJECT_NAME --public --source=. --remote=origin"
    echo "  git add -A && git commit -m 'Initial commit' && git push -u origin master"
else
    # Check if remote already exists
    if git remote get-url origin &>/dev/null; then
        echo "       Remote 'origin' already exists"
    else
        # Create GitHub repo
        gh repo create "$PROJECT_NAME" --public --source=. --remote=origin --description "Project: $PROJECT_NAME" 2>/dev/null || {
            echo "       Repository may already exist, adding remote..."
            git remote add origin "https://github.com/$GITHUB_USER/$PROJECT_NAME.git" 2>/dev/null || true
        }
    fi

    # Initial commit and push
    git add -A
    if git diff --cached --quiet; then
        echo "       No changes to commit"
    else
        git commit -m "Initial commit: Set up $PROJECT_NAME project"
        git push -u origin master 2>/dev/null || git push -u origin main 2>/dev/null || {
            echo "       Push failed - you may need to push manually"
        }
        echo "       Pushed to GitHub"
    fi
fi

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Repository: https://github.com/$GITHUB_USER/$PROJECT_NAME"
echo ""
echo "Files created:"
echo "  - .claude/ folder with rule files"
echo "  - .claude/TODO.md for progress tracking"
echo "  - .claude/PROJECT.md for project documentation"
echo "  - .gitignore (with .claude/ excluded)"
echo ""
echo "Claude will now:"
echo "  1. Read rules from .claude/ at session start"
echo "  2. Track progress in .claude/TODO.md"
echo "  3. Document project in .claude/PROJECT.md"
echo "  4. Commit and push after every code change"
