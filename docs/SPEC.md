# Ralph Bootstrap Toolkit Specification

## Overview

A portable toolkit for "Ralph-ifying" any codebase - enabling autonomous AI-assisted development loops.

**Core commands:**
1. **analyze_project** - Reconnaissance and documentation
2. **bootstrap_ralph** - Interactive configuration
3. **create_plan** - Interactive plan creation for Ralph execution
4. **implement_plan** - Plan execution (Ralph loop hint)
5. **research_codebase** - Deep codebase documentation
6. **explain** - Quick code explanation (lighter than research)
7. **review_plan** - Post-implementation review pass

**Skills:**
- **stack-detection** - Detect build tools, test frameworks, CI/CD
- **session-recovery** - Enable session continuity for long-running tasks

**Design principle:** **detect and adapt** - never assume a stack, always integrate with what exists.

---

## Command: analyze_project

### Purpose
Produce a structured analysis of an existing codebase that informs Ralph configuration.

### Detection Categories

#### 1. Tech Stack
- Primary language(s)
- Framework(s)
- Build system (make, npm scripts, gradle, cargo, etc.)
- Package manager
- Language version management (nvm, pyenv, asdf, mise, etc.)

#### 2. Container & Environment
- **Docker**
  - Dockerfile present (development vs production)
  - docker-compose.yml (services defined)
  - .dockerignore
- **Devcontainer**
  - .devcontainer/devcontainer.json
  - Features configured
  - Extensions specified
- **Testcontainers**
  - Usage in test code
  - Which services (postgres, redis, etc.)
- **Other**
  - Nix flakes/shells
  - Vagrant
  - Cloud-specific (AWS SAM, Azure Functions, etc.)

#### 3. Task/Issue Tracking
- MCP configuration check:
  - Jira MCP server
  - Linear MCP server
  - GitHub MCP server
  - Notion MCP server
  - Custom/internal MCP servers
- GitHub Issues (`.github/ISSUE_TEMPLATE/`)
- Azure DevOps references
- References in CONTRIBUTING.md, README, docs

#### 4. CI/CD
- GitHub Actions (`.github/workflows/`)
- GitLab CI (`.gitlab-ci.yml`)
- CircleCI, Jenkins, Azure Pipelines, etc.
- What checks run:
  - Tests (unit, integration, e2e)
  - Linting
  - Type checking
  - Build verification
  - Security scanning
- Required checks on PRs
- Branch protection patterns

#### 5. Code Quality & Standards
- Linter configuration (eslint, ruff, golangci-lint, etc.)
- Formatter configuration (prettier, black, gofmt, etc.)
- Pre-commit hooks (.husky/, .pre-commit-config.yaml)
- Type checking (tsconfig, mypy, etc.)
- Test configuration and patterns

#### 6. Project Structure
- Monorepo detection (workspaces, lerna, nx, turborepo)
- Service boundaries
- Shared libraries/packages
- Documentation location

#### 7. Git Workflow
- Branch naming conventions (from history)
- Commit message patterns (conventional commits?)
- PR/MR templates
- Protected branches

### Output Format

Produces `docs/project-analysis.md`:

```markdown
# Project Analysis: {project-name}

Generated: {timestamp}

## Summary
{one-paragraph overview}

## Tech Stack
- **Language:** {detected}
- **Framework:** {detected}
- **Build System:** {detected}
- **Package Manager:** {detected}

## Container Environment
### Docker
- Present: {yes/no}
- Purpose: {development/production/both/unknown}
- Services: {list from compose if present}

### Devcontainer
- Present: {yes/no}
- Features: {list}

### Testcontainers
- Used: {yes/no}
- Services: {list}

## Task Tracking
- **Detected System:** {jira-mcp/linear-mcp/github-issues/none}
- **MCP Servers:** {list of configured servers}
- **Notes:** {any relevant context}

## CI/CD
- **Platform:** {detected}
- **Checks:** {list}
- **Required for PR:** {list}

## Code Quality
- **Linter:** {detected}
- **Formatter:** {detected}
- **Type Checking:** {detected}
- **Pre-commit Hooks:** {yes/no, list}

## Project Structure
- **Type:** {monorepo/single-project}
- **Services/Packages:** {list}

## Git Workflow
- **Branch Pattern:** {detected or unknown}
- **Commit Style:** {conventional/freeform/unknown}
- **PR Template:** {yes/no}

## Open Questions
{things that couldn't be auto-detected, need interview}
```

### Behavior
- Idempotent - safe to re-run
- Non-destructive - only reads, never modifies
- Creates `docs/` directory if needed

---

## Command: bootstrap_ralph

### Purpose
Interactive configuration that adapts to project findings.

### Prerequisites
- Reads `docs/project-analysis.md`
- If missing, prompts to run `/analyze_project` first (or runs inline)

### Interview Flow

Interview adapts based on analysis. Questions are conditional.

#### Core Questions (Always)
1. **Installation Level**: "Where should Ralph configuration live?"
   - User-level (~/.claude/): Works across all projects, no project files modified
   - Project-level (.claude/, CLAUDE.md): Committed to repo, shared with team

2. **Scope**: "What kinds of tasks should Ralph handle?"
   - Bug fixes
   - New features
   - Refactoring
   - Documentation
   - All of the above

3. **Boundaries**: "Are there areas Ralph should NOT touch?"
   - Specific directories
   - Specific file patterns
   - Certain types of changes

4. **Autonomy Level**: "How autonomous should Ralph be?"
   - Ask before any change
   - Ask for significant changes only
   - Fully autonomous within scope

#### Conditional Questions

**If no task tracker detected:**
- "No issue tracker found. Options:"
  - Connect to existing system via MCP (Linear, Jira, GitHub Issues, etc.)
  - Skip task tracking

**If Docker detected:**
- "Docker found. Should Ralph:"
  - Run inside container
  - Run on host, use containers for testing
  - Ignore containers

**If devcontainer detected:**
- "Devcontainer found. Should Ralph run inside it?"

**If testcontainers detected:**
- "Testcontainers in use. Should Ralph run integration tests?"
  - If yes: "Does Ralph need Docker socket access?"

**If CI detected:**
- "CI runs these checks: {list}. Should Ralph run them locally before pushing?"

**If monorepo detected:**
- "Multiple services detected: {list}. Should Ralph:"
  - Work on all services
  - Focus on specific services (which?)
  - Ask each time

**If MCP servers detected:**
- For each: "I see {server} configured. Should Ralph use it for {purpose}?"

#### Enterprise/Compliance Questions
- "Are there PR requirements?" (approvals, checks, etc.)
- "Any compliance constraints?" (audit logs, no secrets in code, etc.)
- "Team conventions to follow?" (commit style, branch naming, etc.)

### Output Generation

Based on interview, generates configuration at chosen installation level:

#### If User-Level Installation
- Updates `~/.claude/settings.json` with project-agnostic permissions
- Optionally creates `~/.claude/projects/{project-name}.md` for project notes
- No files created in project directory

#### If Project-Level Installation
- Creates `.claude/settings.json` with project-specific permissions
- Creates `CLAUDE.md` in project root with:
  - Project-specific context from analysis
  - Constraints from interview
  - Tool configurations
  - Workflow instructions
- Creates `.claude/commands/` if project-specific commands needed

### Behavior
- Interactive - requires user input
- Idempotent - can re-run to update configuration
- Non-destructive - warns before overwriting existing files
- Offers diff view before writing changes

---

## Command: create_plan

### Purpose
Create detailed implementation plans through interactive research. Plans work for both direct `/implement_plan` execution and Ralph autonomous loops.

### Process

1. **Context Gathering**
   - Read all mentioned files FULLY (no limit/offset)
   - Spawn parallel research agents to understand codebase
   - Present findings and ask clarifying questions

2. **Research & Discovery**
   - Use agents to find patterns, implementations, related code
   - Verify understanding through code investigation
   - Present design options with pros/cons

3. **Plan Structure**
   - Get buy-in on phased approach
   - Define clear boundaries (what we're NOT doing)
   - Order phases: infrastructure → functional → ui

4. **Detailed Plan Writing**
   - Write to `docs/plans/YYYY-MM-DD-description.md`
   - Include atomic tasks within each phase
   - Each phase must leave system functional

### Plan Template

```markdown
# [Name] Implementation Plan

## Overview
[What we're building and why — 2-3 sentences]

## Current State
[What exists now, key constraints discovered with file:line references]

## Out of Scope
[What we're NOT doing — prevents scope creep]

---

## Phase 1: [Descriptive Name]
**Category**: infrastructure | functional | ui

### Tasks
- [ ] Task description
  - File: `path/to/file.ext`
  - Detail: what to change
- [ ] Next task
  - File: `path/to/another.ext`
  - Detail: what to change

### Verification
- [ ] `[test command]` passes
- [ ] `[lint command]` passes
- [ ] Manual: [specific check if needed]

---

## Phase 2: [Descriptive Name]
**Category**: infrastructure | functional | ui

### Tasks
- [ ] ...

### Verification
- [ ] ...

---

## Testing Strategy
[Key behaviors to test, edge cases, what NOT to test]

## Notes
[Migration concerns, performance considerations, references]
```

### Key Principles
- No open questions in final plan
- Tasks are atomic (smallest change that keeps system working)
- Checkboxes are the state — no separate execution log needed
- Plans work for both direct execution and Ralph loops
- Category tags guide phase ordering: infrastructure → functional → ui

---

## Command: implement_plan

### Purpose
Execute approved plans phase by phase. Works for both direct interactive use and Ralph autonomous loops.

### Process

1. **Read plan** and check for existing checkmarks to find resume point
2. **Execute tasks** one at a time, checking off each as completed
3. **Run verification** after completing all tasks in a phase
4. **Pause for manual verification** if phase has manual checks
5. **Proceed** to next phase after confirmation

### Resuming Work

Checkboxes are the state. On startup:
- Find the first unchecked item
- Trust that checked items are done
- Verify previous work only if something seems off

### Human Checkpoints

After automated verification passes, pause with:

```
Phase [N] Complete - Ready for Manual Verification

Automated verification passed:
- [List checks that passed]

Please perform the manual verification steps:
- [List manual items from plan]

Let me know when manual testing is complete.
```

If instructed to execute multiple phases consecutively, skip the pause until the last phase.

### Handling Mismatches

If plan doesn't match reality:

```
Issue in Phase [N], Task [M]:
Expected: [what plan says]
Found: [actual situation]
Why this matters: [explanation]

How should I proceed?
```

STOP and wait for guidance. Don't guess.

### Behavior
- Checkboxes are the single source of truth for progress
- Each phase must leave the app working
- Pauses for human input at manual verification
- Never checks off manual verification items until confirmed by user
- Uses sub-agents sparingly (debugging, exploration)

---

## Command: research_codebase

### Purpose
Document how code works through parallel sub-agent research.

### Key Principle
**Document what IS, not what SHOULD BE.** All agents are documentarians, not critics.

### Process

1. **Read mentioned files** FULLY in main context
2. **Decompose** research question into parallel tasks
3. **Spawn agents** for concurrent research:
   - codebase-locator: find where code lives
   - codebase-analyzer: understand how code works
   - codebase-pattern-finder: find usage examples
4. **Wait for all agents** to complete
5. **Synthesize** findings into documentation
6. **Output** to `docs/research/YYYY-MM-DD-topic.md`

### Output Format

```markdown
# Research: [Topic]

**Date**: [timestamp]
**Repository**: [name]

## Research Question
[Original query]

## Summary
[High-level findings]

## Detailed Findings

### [Component 1]
- Description with file:line refs
- How it connects to other components

## Code References
- `path/file.py:123` - Description

## Architecture Documentation
[Patterns and conventions found]

## Open Questions
[Areas needing further investigation]
```

---

## Command: explain

### Purpose
Quick, focused code explanation - lighter weight than full `/research_codebase`.

### Process
1. If given file path: read it fully, identify components
2. If given concept: use codebase-locator to find relevant files
3. Trace callers and callees
4. Explain what, why, and how it connects to the system

### Output
Inline explanation with file:line references. No document created unless requested.

### When to Use
- Specific file or function
- Single concept or flow
- Quick understanding needed

Use `/research_codebase` instead for broad architectural questions or documentation that should be saved.

---

## Command: review_plan

### Purpose
Post-implementation review pass run in fresh context after `/implement_plan` completes.

### Process
1. Read plan and execution log
2. Review all files modified during implementation
3. Make autonomous fixes for obvious issues
4. Run full verification
5. Update plan status to `completed`

### Fix Categories

**Must Fix (autonomous):**
- Pattern violations
- Unnecessary complexity
- Missing error handling
- Debug code left behind
- Dead code

**Should Fix (autonomous):**
- Naming inconsistencies
- Readability issues
- Test gaps

**Note Only (don't fix):**
- Style preferences
- Behavior-changing "improvements"
- Risky refactors

### Integration with Ralph Loop
```
/implement_plan → status: ready_for_review → [new context] → /review_plan → status: completed
```

---

## Skills

Skills are reusable capabilities that commands can invoke.

### stack-detection

**Location:** `skills/stack-detection/SKILL.md`

Detects project tooling:
- Language and framework
- Package manager
- Build system (Makefile, npm scripts, etc.)
- Test framework and command
- Linter and formatter
- CI/CD platform

**Output:** Structured report with commands for build, test, lint, etc.

**Used by:** Any command that needs to run verification.

### session-recovery

**Location:** `skills/session-recovery/SKILL.md`

Enables resuming work after interruption through execution logs.

**Pattern:**
- Check session state on startup
- Log actions as you work
- Update status on pause/completion
- Provide context for resumption

**Used by:** `/implement_plan`, any long-running command.

### deep-research

**Location:** `skills/deep-research/SKILL.md`

Submits deep research queries to Google Gemini's Deep Research feature via headed browser automation (agent-browser).

**Flow:**
1. Accept research topic from user arguments
2. Ask targeted clarifying questions (only if ambiguity exists)
3. Compose a detailed, well-structured research prompt
4. Show prompt to user for approval
5. Use agent-browser in headed mode to navigate to Gemini, select Deep Research, enter prompt, and approve the generated research plan
6. Report submission success (does not wait for results)

**Dependencies:** agent-browser skill, Google account with Gemini access

**Invocation:** `/deep-research <topic>`

---

## Agents

Sub-agents are specialized workers for parallel research.

### codebase-locator
- **Purpose**: Find WHERE code lives
- **Tools**: Grep, Glob, LS
- **Output**: Categorized file lists by purpose

### codebase-analyzer
- **Purpose**: Understand HOW code works
- **Tools**: Read, Grep, Glob, LS
- **Output**: Implementation analysis with file:line refs

### codebase-pattern-finder
- **Purpose**: Find similar implementations
- **Tools**: Grep, Glob, Read, LS
- **Output**: Code examples that can be modeled

### web-search-researcher
- **Purpose**: Find external documentation
- **Tools**: WebSearch, WebFetch, Read, Grep, Glob, LS
- **Output**: Synthesized findings with source links

### Key Principles for Agents
- Document, don't critique
- Describe what IS, not what SHOULD BE
- Include file:line references
- No recommendations or improvements

---

## Extension Types

Claude Code supports three extension types. Understanding when to use each is critical.

### Agents (Subagents)

**Purpose**: Specialized workers that Claude auto-delegates to based on task description.

**Location**: `.claude/agents/name.md` (project) or `~/.claude/agents/name.md` (global)

**Frontmatter**:
```yaml
---
name: agent-name
description: When to delegate (Claude reads this to decide)
tools: Read, Grep, Glob, LS
model: sonnet
---
```

**When to use**: Complex tasks requiring isolated context, parallel research, specialized tool access.

### Commands (Slash Commands)

**Purpose**: Manual `/name` invocation for specific workflows.

**Location**: `.claude/commands/name.md` (project) or `~/.claude/commands/name.md` (global)

**Frontmatter**:
```yaml
---
description: Shows in /help menu
allowed-tools: Bash(git:*), Read
model: opus
---
```

**When to use**: User-triggered workflows, templates, repeatable prompts.

### Skills

**Purpose**: Specialized capabilities Claude auto-discovers and applies.

**Location**: `.claude/skills/name/SKILL.md` (project) or `~/.claude/skills/name/SKILL.md` (global)

**Frontmatter**:
```yaml
---
name: skill-name
description: When to use (Claude reads for auto-discovery)
allowed-tools: Read, Grep
user-invocable: true
---
```

**When to use**: Domain knowledge, guidance, capabilities that enhance Claude's behavior.

### Decision Tree

```
Is this a user-triggered workflow?
├─ Yes → Command (/name invocation)
└─ No → Should Claude auto-delegate or auto-apply?
         ├─ Delegate isolated task → Agent
         └─ Apply knowledge/capability → Skill
```

### Model Selection Policy

Commands and agents can specify which model to use via the `model` frontmatter field.

**Use `model: opus` for:**
- Heavy research and synthesis (`/create_plan`, `/research_codebase`)
- Complex multi-step reasoning
- Tasks requiring deep context integration

**Use default (no model specified) for:**
- Execution-focused commands (`/implement_plan`, `/review_plan`)
- Simple lookup commands (`/explain`)
- Interactive wizards (`/bootstrap_ralph`, `/analyze_project`)

**Agents always use `model: sonnet`:**
- Agents do focused, bounded work
- Sonnet is sufficient for search/analysis tasks
- Keeps parallel agent costs reasonable

| Extension Type | Default Model | When to Override |
|---------------|---------------|------------------|
| Commands | (inherits) | Use opus for research-heavy commands |
| Agents | sonnet | Rarely - agents should stay focused |
| Skills | (inherits) | Skills don't typically specify models |

### Command Input Patterns

Commands should handle invocation consistently based on whether they need parameters.

**Commands that run immediately** (no required parameters):
- `/analyze_project` - Analyzes current project
- `/bootstrap_ralph` - Checks for analysis, then interviews

These can start working immediately when invoked.

**Commands that need parameters**:
- `/create_plan <task>` - Needs task description or file reference
- `/implement_plan <plan>` - Needs path to plan file
- `/review_plan <plan>` - Needs path to plan file
- `/explain <target>` - Needs file path or concept
- `/research_codebase <question>` - Needs research question

When invoked without parameters, these should:
1. Respond with a brief description of what they do
2. Ask for the required input
3. Wait for user response before proceeding

Example pattern:
```
I'll help you [do X]. Please provide:
- [Required input 1]
- [Optional context]

[Wait for user input]
```

### This Toolkit's Usage

| Extension | Files | Purpose |
|-----------|-------|---------|
| Commands | `commands/*.md` | User workflows: /analyze_project, /create_plan, /explain, /review_plan, etc. |
| Agents | `agents/*.md` | Research workers: codebase-locator, codebase-analyzer, etc. |
| Skills | `skills/*/SKILL.md` | Reusable capabilities: stack-detection, session-recovery |

---

## Templates

### CLAUDE.md.template

Key sections:
- Project overview (from analysis)
- Ralph scope and boundaries (from interview)
- Tool configurations (detected + confirmed)
- Workflow instructions (from interview)
- Verification steps (from CI analysis)

### settings.json.template

Permission baseline customized by bootstrap.

---

## Workflow

### One-time project setup:

```
┌─────────────────────────────────────────┐
│ 1. /analyze_project                     │
│    └─ Produces docs/project-analysis.md │
├─────────────────────────────────────────┤
│ 2. /bootstrap_ralph                     │
│    └─ Interactive configuration         │
│    └─ Generates CLAUDE.md, settings.json│
└─────────────────────────────────────────┘
```

### Per-task workflow:

```
┌─────────────────────────────────────────┐
│ 3. /create_plan <task>                  │
│    └─ Research → Interview → Plan       │
│    └─ Produces docs/plans/plan.md       │
├─────────────────────────────────────────┤
│ 4. /implement_plan <plan>               │
│    ├─ Execute phase tasks               │
│    ├─ Run verification                  │
│    ├─ Pause for manual checks           │
│    └─ Continue to next phase            │
│                                         │
│    Run directly OR via Ralph loop       │
├─────────────────────────────────────────┤
│ 5. /review_plan <plan>                  │
│    └─ Fresh-context review pass         │
│    └─ Autonomous fixes + verification   │
└─────────────────────────────────────────┘
```

---

## Future Extensions

- `/sync_ralph` - Update configuration when project changes
- `/ralph_status` - Show current configuration and health
- Multi-repo support - Coordinated Ralph across related repos
- Custom agent definitions for enterprise-specific tools
