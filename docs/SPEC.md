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
Create detailed implementation plans through interactive research that Ralph can execute.

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

4. **Detailed Plan Writing**
   - Write to `docs/plans/YYYY-MM-DD-description.md`
   - Include atomic tasks within each phase
   - Include execution log section for session continuity
   - Each phase must leave system functional

### Plan Template

```markdown
# [Feature/Task Name] Implementation Plan

## Overview
[Brief description]

## Current State Analysis
[What exists, constraints discovered]

## Desired End State
[Specification of end state and verification]

## What We're NOT Doing
[Explicit scope boundaries]

---

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Tasks
- [ ] **Task 1**: [Specific atomic change]
  - File: `path/to/file.ext`
  - Change: [What to do]
- [ ] **Task 2**: [Next atomic change]
  - File: `path/to/another.ext`
  - Change: [What to do]

### Verification
- [ ] `make test` passes
- [ ] `make lint` passes
- [ ] Manual: [specific check if needed]

---

## Phase 2: [Descriptive Name]
[Similar structure with Tasks and Verification...]

---

## Execution Log

Append entries here during implementation to track progress and enable session recovery.

### Session: YYYY-MM-DD HH:MM
**Status**: in_progress | paused | completed
**Phase**: N
**Last Completed Task**: Task description or "none"

#### Actions Taken
- [HH:MM] Started Phase N
- [HH:MM] Completed Task 1: [brief description of what was done]
- [HH:MM] ISSUE: [description of problem encountered]
- [HH:MM] Paused for manual verification

#### Notes
[Any context needed for resumption]
```

### Key Principles
- No open questions in final plan
- Tasks are atomic (smallest change that keeps system working)
- Execution log enables session recovery
- Plans designed for Ralph loop execution

---

## Command: implement_plan

### Purpose
Execute approved plans phase by phase. This is the "hint" given to Ralph at loop start.

### Process

1. **Read plan** and check execution log for session state
2. **Resume** from last recorded position (or start fresh)
3. **Start session** - append new session entry to execution log
4. **Execute tasks** one at a time, updating checkboxes and log
5. **Run verification** after completing phase tasks
6. **Update execution log** with actions taken
7. **Pause for manual verification** if required
8. **Proceed** after human confirmation

### Session Recovery

On startup, read the execution log to determine state:

```
Reading plan: docs/plans/2026-01-16-feature.md

Execution Log Status:
- Last Session: 2026-01-16 14:30
- Status: paused
- Phase: 2
- Last Completed: Task 3 (Add validation to form handler)

Resuming from Phase 2, Task 4...
```

If no execution log exists, start fresh and create the first session entry.

### Execution Log Maintenance

After each task completion:
1. Check off the task in the plan (`- [x]`)
2. Append to execution log: `- [HH:MM] Completed Task N: [description]`

On issues:
- Log: `- [HH:MM] ISSUE: [description]`
- Update status to `paused` or `blocked`

On session end:
- Update status to `paused` or `completed`
- Add notes for resumption context

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

### Handling Mismatches

If plan doesn't match reality:

```
Issue in Phase [N], Task [M]:
Expected: [what plan says]
Found: [actual situation]
Why this matters: [explanation]

Logging issue to execution log.
How should I proceed?
```

### Behavior
- Reads execution log on startup for session recovery
- Updates both checkboxes AND execution log as it progresses
- Pauses for human input at manual verification
- Uses sub-tasks sparingly (debugging, exploration)

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

## Ralph Loop Workflow

Complete workflow for autonomous development:

```
┌─────────────────────────────────────────┐
│ 1. /analyze_project                     │
│    └─ Produces project-analysis.md      │
├─────────────────────────────────────────┤
│ 2. /bootstrap_ralph                     │
│    └─ Interactive configuration         │
│    └─ Generates CLAUDE.md, settings.json│
├─────────────────────────────────────────┤
│ 3. /create_plan <task>                  │
│    └─ Research → Interview → Plan       │
│    └─ Produces phased plan              │
├─────────────────────────────────────────┤
│ 4. Ralph Loop                           │
│    └─ /implement_plan <plan>            │
│       ├─ Execute phase                  │
│       ├─ Run automated verification     │
│       ├─ Pause for manual verification  │
│       ├─ Human confirms                 │
│       └─ Continue to next phase         │
├─────────────────────────────────────────┤
│ 5. Task Complete                        │
│    └─ Update task tracking              │
│    └─ Ready for next task               │
└─────────────────────────────────────────┘
```

---

## Command: browse

### Purpose
Interactive browser automation for web navigation, testing, and data extraction using the `agent-browser` CLI.

### Process

1. **Parse Request** - Identify the browsing task from user input
2. **Execute** - Use agent-browser skill to translate task into CLI commands
3. **Snapshot-Interact Loop** - Navigate, snapshot for refs, interact using refs
4. **Report** - Return results, screenshots, or extracted data

### Usage

```
/browse Navigate to Hacker News and summarize the top 3 stories
/browse Test the login flow on localhost:3000
/browse Fill out the contact form on example.com
```

### Workflow Pattern

The command follows the snapshot-interact pattern:
1. `agent-browser open <url>` - Navigate
2. `agent-browser snapshot -i` - Get interactive elements with refs
3. Use refs (@e1, @e2, etc.) for interactions
4. Re-snapshot after navigation or DOM changes

---

## Skill: agent-browser

### Purpose
CLI-based browser automation using ref-based element selection.

### Core Pattern

```
open → snapshot -i → interact with @refs → re-snapshot as needed
```

### Key Commands

| Category | Command | Purpose |
|----------|---------|---------|
| Navigate | `open`, `back`, `forward`, `reload`, `close` | Page navigation |
| Snapshot | `snapshot -i` | Get elements with refs |
| Interact | `click`, `fill`, `type`, `press`, `select` | Element actions |
| Read | `get text`, `get value`, `get title` | Extract data |
| Wait | `wait @e1`, `wait --text "X"` | Synchronization |
| Screenshot | `screenshot path.png` | Capture state |

### Files

- `skills/agent-browser/SKILL.md` - Full command reference and workflow patterns

---

## Agent: browser-agent

### Purpose
Delegated browser automation tasks requiring isolated context.

### When to Use
- Multi-step browsing workflows
- Parallel browser sessions
- QA testing requiring isolation
- Data extraction from multiple pages

### Tools
- Bash (for agent-browser CLI commands)
- Read, Write (for saving results)

---

## Future Extensions

- `/sync_ralph` - Update configuration when project changes
- `/ralph_status` - Show current configuration and health
- Multi-repo support - Coordinated Ralph across related repos
- Custom agent definitions for enterprise-specific tools
