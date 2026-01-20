# Universal Rules

---

## MANDATORY: Project Setup and Rules Loading

**At the START of every new project, Claude MUST perform these steps:**

### Step 1: Create `.claude` Folder

Create a `.claude` folder in the project root if it doesn't exist:

```bash
mkdir -p .claude
```

### Step 2: Copy Universal Rules

Copy ALL `.md` files from the universal-rules source folder to the project's `.claude` folder:

```bash
cp C:\Users\Quang\projects\claude-projects\universal-rules\*.md .claude/
```

**Files to copy:**
- `universal.md` - Core rules for all languages
- `typescript.md` - TypeScript-specific rules
- `python.md` - Python-specific rules
- `clean-architecture.md` - Clean Architecture principles
- Any additional `.md` rule files in the source folder

### Step 3: Read and Acknowledge

1. Read ALL `.md` files in the project's `.claude` folder
2. Acknowledge that rules have been loaded
3. Apply these rules consistently throughout the entire session

### Step 4: Create TODO.md for Progress Tracking

Create a `TODO.md` file in the `.claude` folder to track project progress:

```bash
touch .claude/TODO.md
```

This file tracks:
- Ideation and planning progress
- Code generation tasks
- Decisions made during discussions
- Implementation status

### Step 5: Add to .gitignore (MANDATORY)

The `.claude/` folder MUST be added to `.gitignore` to:
- Keep rules in sync with the source (always get latest updates)
- Avoid committing duplicate rule files to every project
- Allow the source folder to be the single source of truth

```bash
echo ".claude/" >> .gitignore
```

**Source Location:** `C:\Users\Quang\projects\claude-projects\universal-rules\`

**Setup Script:** Run `setup-rules.sh` from the source folder to automate Steps 1-5:

```bash
bash C:\Users\Quang\projects\claude-projects\universal-rules\setup-rules.sh /path/to/your/project
```

**Note:** If the `.claude` folder already exists with rule files, skip Steps 1-2 and proceed to Step 3.

---

## MANDATORY: TODO.md Progress Tracking

Claude MUST maintain the `.claude/TODO.md` file throughout the project lifecycle.

### When to UPDATE the TODO.md

1. **At Session Start**
   - Read `.claude/TODO.md` to understand current progress
   - Review what was completed and what remains

2. **After Discussions**
   - When user and Claude agree on actionable steps, immediately add them to TODO.md
   - Capture decisions, requirements, and planned approaches

3. **Before Writing Code**
   - Add specific implementation tasks to TODO.md
   - Break large tasks into smaller, actionable steps

4. **After Completing Work**
   - Mark completed items as done (`[x]`)
   - Add any new tasks discovered during implementation

5. **When Plans Change**
   - Update or remove tasks that are no longer relevant
   - Add new tasks based on revised requirements

### TODO.md Format

```markdown
# Project TODO

## Current Sprint / Focus
- [ ] Active task 1
- [ ] Active task 2

## Backlog
- [ ] Future task 1
- [ ] Future task 2

## Completed
- [x] ~~Completed task 1~~ (date or session)
- [x] ~~Completed task 2~~ (date or session)

## Decisions Log
- **Decision 1**: Description of what was decided and why
- **Decision 2**: Description of what was decided and why
```

### Task Breakdown Rules

1. **Break Big Tasks Into Smaller Steps**
   - Each task should be completable in a single focused effort
   - If a task has multiple parts, split it into sub-tasks
   - Use indentation for sub-tasks:
     ```markdown
     - [ ] Implement user authentication
       - [ ] Create login form component
       - [ ] Add form validation
       - [ ] Implement API call to auth endpoint
       - [ ] Handle success/error responses
       - [ ] Store auth token
     ```

2. **Task Naming**
   - Use action verbs: "Create", "Add", "Fix", "Update", "Remove", "Refactor"
   - Be specific: "Add email validation to signup form" not "Fix form"
   - Include context when needed: "Update User model to include `lastLogin` field"

3. **Priority Indicators** (optional)
   - `[!]` High priority
   - `[?]` Needs clarification
   - `[~]` In progress

---

These rules apply to ALL code generation, regardless of language or framework.

## Anti-Hallucination Rules (CRITICAL)

These rules are mandatory to prevent AI agents from generating incorrect, assumed, or fabricated code.

### When to STOP and ASK

**ALWAYS stop and ask the user before proceeding when:**

1. **Unclear Requirements**
   - The task description is vague or ambiguous
   - Multiple interpretations of the requirement exist
   - Business logic or rules are not explicitly defined
   - Edge cases are not specified

2. **Unknown Target**
   - The target file, function, or component is not specified
   - Multiple files could be the correct target
   - The location for new code is not clear

3. **Missing Context**
   - Required dependencies or libraries are not known
   - The existing codebase structure is unfamiliar
   - Integration points are not defined
   - Database schema or API contracts are not provided

4. **Architectural Decisions**
   - The choice between patterns/approaches is not obvious
   - The decision has significant long-term impact
   - Multiple valid solutions exist with different trade-offs

5. **Assumptions About Data**
   - Data types, formats, or structures are not specified
   - Validation rules are not defined
   - Required vs optional fields are unclear

### What to Do Before Writing Code

1. **Read First, Write Second**
   - ALWAYS read existing code before modifying it
   - Understand the current implementation before suggesting changes
   - Check for existing patterns, utilities, or conventions in the codebase

2. **Verify, Don't Assume**
   - If a file path is mentioned, verify it exists
   - If a function is referenced, confirm its signature and behavior
   - If an API is involved, check the actual contract
   - NEVER guess import paths, function names, or variable names

3. **State Your Understanding**
   - Before implementing, briefly state what you understand the task to be
   - List any assumptions you are making
   - Give the user a chance to correct misunderstandings

4. **Ask Specific Questions**
   - Don't ask vague questions like "What do you want?"
   - Ask targeted questions: "Should this function return null or throw an error when the user is not found?"
   - Provide options when possible: "Do you want (A) in-memory caching or (B) Redis caching?"

### Prohibited Behaviors

- **NEVER invent file paths** that you haven't verified exist
- **NEVER assume API endpoints** or their request/response formats
- **NEVER fabricate function signatures** or class methods
- **NEVER guess configuration values** or environment variables
- **NEVER create placeholder code** with comments like "implement this later"
- **NEVER assume database schema** or table structures
- **NEVER invent package names** or import paths
- **NEVER write code that "should work"** - only write code you are confident works

### When Uncertain, Prefer

1. **Asking over assuming** - A question takes seconds; fixing wrong code takes longer
2. **Reading over guessing** - Check the actual code, don't rely on memory
3. **Less over more** - Write minimal code that definitely works vs comprehensive code that might not
4. **Explicit over implicit** - Be clear about what you're doing and why

### Response Format When Unclear

When requirements are unclear, respond with:

```
I need clarification before proceeding:

**What I understand:**
- [Your interpretation of the task]

**What's unclear:**
- [Specific question 1]
- [Specific question 2]

**Options (if applicable):**
- Option A: [description]
- Option B: [description]

Which approach would you prefer?
```

## MCP Configuration

- **ALWAYS use Context7 for MCP (Model Context Protocol) implementations**
- Context7 provides the standard interface for all MCP operations

## General Principles

### Code Quality

- Write self-documenting code with clear naming conventions
- Keep functions/methods small and focused (single responsibility)
- Avoid magic numbers and strings; use named constants
- DRY (Don't Repeat Yourself) - extract common logic into reusable functions
- YAGNI (You Aren't Gonna Need It) - don't add functionality until it's necessary
- KISS (Keep It Simple, Stupid) - prefer simple solutions over clever ones

### Naming Conventions

- Use descriptive, meaningful names that reveal intent
- Functions/methods should be verbs or verb phrases: `getUserById`, `calculateTotal`
- Variables should be nouns: `userList`, `totalAmount`
- Booleans should be prefixed with `is`, `has`, `can`, `should`: `isActive`, `hasPermission`
- Avoid abbreviations unless universally understood (`id`, `url`, `api`)
- Constants should be SCREAMING_SNAKE_CASE

### File Organization

- One primary export per file (with related helpers allowed)
- Group related files in directories
- Keep directory nesting shallow (max 3-4 levels)
- Use index files for clean imports (barrel exports)

### Error Handling

- Never silently swallow errors
- Provide meaningful error messages
- Use custom error types/classes for domain-specific errors
- Fail fast - validate inputs early

### Comments and Documentation

- Code should be self-explanatory; comments explain "why", not "what"
- Document public APIs and complex business logic
- Keep comments up to date with code changes
- Use TODO/FIXME with context: `// TODO(username): reason and ticket number`

### Security

- Never hardcode secrets, API keys, or credentials
- Validate and sanitize all user inputs
- Use parameterized queries for database operations
- Follow the principle of least privilege

### Testing

- Write tests for critical business logic
- Follow the AAA pattern: Arrange, Act, Assert
- Test edge cases and error conditions
- Keep tests independent and deterministic

### Version Control

- Write meaningful commit messages
- Keep commits atomic and focused
- Use feature branches for new development
