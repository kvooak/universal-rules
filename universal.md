# Universal Rules

---

## PROJECT INITIALIZATION

### Setup Steps
1. Run `bash C:\Users\Quang\projects\claude-projects\universal-rules\setup-rules.sh /path/to/project`
2. Read all `.md` files in `.claude/` folder
3. Review `.claude/TODO.md` and `.claude/PROJECT.md`

### Manual Setup (if needed)
```bash
mkdir -p .claude
cp C:\Users\Quang\projects\claude-projects\universal-rules\universal.md .claude/
# Copy language-specific rule: typescript.md OR python.md
echo ".claude/" >> .gitignore
git init
gh repo create <project-name> --public --source=. --remote=origin
git add -A && git commit -m "Initial commit: <description>" && git push -u origin main
```

---

## GIT COMMIT RULES

### Commit Locally After Every Change
```bash
git add -A
git commit -m "<type>: <description>"
```

**Commit Types:**
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code restructuring
- `docs:` Documentation only
- `style:` Formatting, whitespace
- `test:` Tests
- `chore:` Config, dependencies

### Push to GitHub
- **Push ONLY when >500 LOC changed**
- Accumulate commits locally
- Max commit message: **256 characters**

### Don't Commit
- `.env`, `.secrets`
- `node_modules/`, `__pycache__/`, `venv/`
- `.idea/`, `.vscode/`, `dist/`, `build/`
- Large files (PDFs, images, videos)
- `sources/` folders with large data

---

## TODO.md MAINTENANCE

### Update When
- Session starts: Read current progress
- Task discussed: Add to TODO
- Task started: Mark as in_progress
- Task done: Mark as completed `[x]`
- Requirements change: Update/remove tasks

### Format
```markdown
# Project TODO

## Current Sprint
- [ ] Task using action verbs (Create, Add, Fix, Update, Remove, Refactor)
- [ ] Specific task name (not generic "Fix bug")

## Backlog
- [ ] Future tasks

## Completed
- [x] ~~Task~~ (date or session)

## Decisions
- **Decision**: What was decided and why
```

---

## PROJECT.md MAINTENANCE

### Update Before Every Commit
- [ ] New components documented?
- [ ] Dependencies listed?
- [ ] Architecture accurate?
- [ ] API endpoints up-to-date?
- [ ] Version numbers current?

### Format
```markdown
# Project: <name>

## Overview
Brief description of what this project does.

## Tech Stack
- **Language**: TypeScript 5.x
- **Framework**: Next.js 14
- **Database**: PostgreSQL
- **Testing**: Vitest

## Architecture
Pattern used (e.g., Clean Architecture, MVC)

### Directory Structure
/src
  /components - UI components
  /services   - Business logic
  /utils      - Helpers

## Key Components
### ComponentName
- **Purpose**: What it does
- **Location**: /path/to/component
- **Dependencies**: What depends on it

## Data Models
### ModelName
field1: type - description
field2: type - description

## API Endpoints (if applicable)
### METHOD /endpoint
- **Purpose**: What it does
- **Request**: { field: type }
- **Response**: { field: type }

## Conventions
- Naming conventions
- Code style preferences
- Project-specific patterns

## Environment Variables
VAR_NAME=description

---
*Last updated: <date/session>*
```

---

## CODE GENERATION RULES

### Before Writing Code
1. **Read existing code** - Don't assume, verify
2. **State understanding** - Confirm task interpretation
3. **Ask when unclear** - Don't guess or hallucinate

### Stop and Ask When
- Requirements are vague or ambiguous
- Target file/location not specified
- Dependencies or context unknown
- Multiple valid approaches exist
- Data types, formats not specified

### NEVER
- Invent file paths without verifying they exist
- Assume API endpoints or contracts
- Fabricate function signatures
- Guess configuration values
- Create placeholder code with TODO comments
- Assume database schema
- Invent package names or import paths
- Write code you're not confident works

### Ask Format When Unclear
```
I need clarification:

**What I understand:**
- [Your interpretation]

**What's unclear:**
- [Specific question 1]
- [Specific question 2]

**Options:**
- Option A: [description]
- Option B: [description]

Which approach would you prefer?
```

---

## CODE QUALITY STANDARDS

**Write self-documenting code**
- Clear naming reveals intent
- Functions: verbs (`getUserById`, `calculateTotal`)
- Variables: nouns (`userList`, `totalAmount`)
- Booleans: `is*`, `has*`, `can*`, `should*` (`isActive`, `hasPermission`)
- Constants: SCREAMING_SNAKE_CASE
- Avoid abbreviations (except `id`, `url`, `api`)

**Keep it simple**
- DRY (Don't Repeat Yourself)
- YAGNI (You Aren't Gonna Need It)
- KISS (Keep It Simple)
- One primary export per file
- Max 3-4 directory nesting levels
- Small, focused functions (single responsibility)
- No magic numbers/strings

**Comments**
- Explain "why", not "what"
- Document public APIs and complex logic
- Keep comments up-to-date with code

**Error handling**
- Never silently swallow errors
- Meaningful error messages
- Custom error types for domain errors
- Fail fast - validate early

**Security**
- Never hardcode secrets, keys, credentials
- Validate and sanitize all user inputs
- Use parameterized queries
- Principle of least privilege

**Testing**
- Write tests for critical logic
- Arrange, Act, Assert pattern
- Test edge cases and errors
- Keep tests independent and deterministic

---

## MCP CONFIGURATION

- Use **Context7** for MCP (Model Context Protocol) implementations
