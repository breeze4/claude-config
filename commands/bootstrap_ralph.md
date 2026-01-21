---
description: Interactive configuration wizard for Ralph autonomous loops
---

# Bootstrap Ralph

Configure this project for Ralph autonomous loops based on analysis and interview.

## Instructions

### Step 1: Check Prerequisites

Look for `docs/project-analysis.md`. If missing:
- Ask user: "No project analysis found. Should I run /analyze_project first?"
- If yes, run the analysis before continuing
- If no, proceed with limited information (more interview questions needed)

### Step 2: Review Analysis

Read the project analysis and identify:
- What tools/systems are already in place
- What open questions need answering
- What configuration will be needed

### Step 3: Conduct Interview

Use AskUserQuestion to gather information. Adapt questions based on analysis.

**Always ask:**
1. **Installation level**: User-level (~/.claude/) or project-level (.claude/, CLAUDE.md)?
   - User-level: Works across all projects, doesn't modify project files
   - Project-level: Committed to repo, shared with team
2. Task scope (bugs, features, refactoring, docs, all)
3. Off-limits areas (directories, files, change types)
4. Autonomy level (ask always, ask for big changes, fully autonomous)

**Conditionally ask based on analysis:**

If no task tracker detected:
- Ask: Does your team use a task tracker? (Linear, Jira, GitHub Issues, Azure DevOps, etc.)
- If yes: Configure MCP connection if available
- If no: Proceed without task tracking integration

If Docker/containers detected:
- Where should Ralph run? (in container, on host, etc.)
- Should Ralph run containerized tests?

If devcontainer detected:
- Should Ralph operate inside the devcontainer?

If testcontainers detected:
- Should Ralph run integration tests?
- Docker socket access needed?

If CI detected:
- Should Ralph run CI checks locally before pushing?

If monorepo:
- Work on all services or specific ones?

For each MCP server detected:
- Should Ralph use this for [relevant purpose]?

**Enterprise/compliance:**
- PR requirements (approvals, required checks)
- Compliance constraints
- Team conventions (commit style, branch naming)

### Step 4: Generate Configuration

Based on interview responses and installation level choice:

**If user-level installation:**
- Create/update `~/.claude/settings.json` with project-agnostic permissions
- Optionally create `~/.claude/projects/{project-name}.md` with project-specific notes
- No files created in the project directory

**If project-level installation:**
- Create `.claude/settings.json` with project-specific permissions
- Create `CLAUDE.md` in project root with:
  - Project context from analysis
  - Scope and boundaries from interview
  - Tool configurations
  - Workflow instructions
  - Verification steps
- Create `.claude/commands/` if project-specific commands needed

**Either way:**
- Generate configuration from analysis findings
- Apply scope and boundary constraints from interview
- Configure MCP server connections if applicable

### Step 5: Confirm and Write

Before writing any files:
1. Show user what will be created/modified
2. Show diff for any existing files that will be changed
3. Ask for confirmation
4. Write files only after approval

### Important Notes

- Never overwrite without showing diff and getting approval
- If user has existing CLAUDE.md, merge rather than replace
- Generated config should reference existing tools, not add new ones
- Be explicit about what Ralph will and won't do based on configuration
