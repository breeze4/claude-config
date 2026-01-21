---
description: Create a PRD (Product Requirements Document) for Ralph autonomous loops
model: opus
---

# Create PRD for Ralph Loop

You are tasked with creating a PRD document that will be consumed by autonomous Ralph loops. The PRD should break down a project into atomic, implementable features with clear acceptance criteria.

## Output Format

The PRD uses this schema for each feature:

```markdown
### [Feature Name]
- **Category**: infrastructure | functional | ui
- **Description**: What to build (1-2 sentences)
- **Steps**:
  - [ ] Specific acceptance criterion 1
  - [ ] Specific acceptance criterion 2
  - [ ] ...
- **Status**: [ ]
```

**Category priority order**: infrastructure → functional → ui (Ralph works top-to-bottom)

## Initial Response

When this command is invoked:

1. **If a spec/requirements file was provided**:
   - Read it FULLY immediately
   - Begin analysis and feature breakdown

2. **If no parameters provided**, respond with:
```
I'll help you create a PRD for Ralph autonomous loops.

Please provide:
1. A spec document, requirements, or description of what to build
2. The project's tech stack (language, framework, etc.)
3. Any existing code patterns to follow

I'll analyze this and create a prioritized feature list with acceptance criteria.

Tip: You can invoke with a spec file: `/create_prd docs/SPEC.md`
```

## Process Steps

### Step 1: Understand the Project

1. **Read all provided files FULLY**
2. **Research the codebase** if it exists:
   - Use **codebase-locator** to find existing structure
   - Use **codebase-pattern-finder** to identify conventions
   - Understand what already exists vs what needs building

3. **Identify the tech stack and commands**:
   - Build command (e.g., `pnpm build`, `cargo build`)
   - Test command (e.g., `pnpm test`, `go test ./...`)
   - Typecheck command if applicable
   - Lint command if applicable

### Step 2: Break Down into Features

1. **Identify all features** from the spec/requirements
2. **Categorize each feature**:
   - `infrastructure`: Setup, connections, configuration, core utilities
   - `functional`: Business logic, data processing, APIs, backend
   - `ui`: User interface, components, styling, frontend

3. **Order by dependency**:
   - Infrastructure first (other things depend on it)
   - Functional next (backend before frontend)
   - UI last (consumes the functional layer)

4. **Make features atomic**:
   - Each feature should be completable in one session
   - Should leave the app in a working state
   - Should be independently testable

### Step 3: Write Acceptance Criteria (Steps)

For each feature, write specific, verifiable steps:

**Good steps**:
- [ ] Create `backend/src/redis.ts` with connection setup
- [ ] Export `connect()` and `disconnect()` functions
- [ ] Verify connection with PING command
- [ ] Handle connection errors gracefully

**Bad steps**:
- [ ] Set up Redis (too vague)
- [ ] Make it work (not verifiable)
- [ ] Test everything (not specific)

### Step 4: Create AGENTS.md

After creating the PRD, also create an `AGENTS.md` file with operational commands:

```markdown
# AGENTS.md

## Build & Run

[How to build and run the project]

## Validation

Run these after implementing to verify:

- **Build**: `[build command]`
- **Typecheck**: `[typecheck command]`
- **Tests**: `[test command]`
- **Lint**: `[lint command]`

## Project Structure

[Brief description of key directories]

## Patterns

[Any codebase conventions Ralph should follow]
```

**AGENTS.md rules**:
- Keep it brief (~60 lines max)
- Operational only - no status updates or progress
- This file is loaded EVERY Ralph iteration, so bloat hurts performance

### Step 5: Write the Files

1. **Write PRD** to `docs/plans/prd.md` (or user-specified location)
2. **Write AGENTS.md** to project root

Use this PRD template:

````markdown
# [Project Name] - Implementation Plan

## How This Document Works

Each feature has:
- **Category**: infrastructure | functional | ui
- **Description**: What to build
- **Steps**: Acceptance criteria (checkbox format)
- **Status**: `[ ]` = not done, `[x]` = complete

Priority: infrastructure → functional → ui, top-to-bottom within category.
When ALL features have `Status: [x]`, the PRD is COMPLETE.

---

## Infrastructure

### [Feature Name]
- **Category**: infrastructure
- **Description**: [What to build]
- **Steps**:
  - [ ] [Specific criterion]
  - [ ] [Specific criterion]
- **Status**: [ ]

---

## Functional

### [Feature Name]
- **Category**: functional
- **Description**: [What to build]
- **Steps**:
  - [ ] [Specific criterion]
- **Status**: [ ]

---

## UI

### [Feature Name]
- **Category**: ui
- **Description**: [What to build]
- **Steps**:
  - [ ] [Specific criterion]
- **Status**: [ ]
````

### Step 6: Review with User

Present the draft:
```
I've created:
- `docs/plans/prd.md` - [N] features across [categories]
- `AGENTS.md` - Operational commands for Ralph

Please review:
- Are features properly scoped (atomic, one-session)?
- Are acceptance criteria specific enough?
- Is the priority order correct?
- Missing features or edge cases?
```

Iterate based on feedback.

## Important Guidelines

1. **Atomic Features**:
   - Each feature = one Ralph session
   - App should work after each feature
   - No feature should depend on an incomplete feature below it

2. **Specific Steps**:
   - File paths when creating files
   - Function names when implementing
   - Specific behavior to verify
   - No vague language

3. **Realistic Scope**:
   - Don't over-engineer
   - Match the spec, don't expand it
   - If spec is vague, ask for clarification

4. **AGENTS.md is Sacred**:
   - Keep it operational and brief
   - It's loaded every iteration
   - Bloat = wasted context = worse performance

## Example PRD Structure

For a "Real-time Chat App" spec:

```markdown
## Infrastructure

### WebSocket Server Setup
- **Category**: infrastructure
- **Description**: Initialize WebSocket server with connection handling
- **Steps**:
  - [ ] Create `src/ws/server.ts` with ws package
  - [ ] Handle connection/disconnection events
  - [ ] Implement heartbeat/ping-pong
  - [ ] Export `startServer()` function
- **Status**: [ ]

## Functional

### Message Broadcasting
- **Category**: functional
- **Description**: Broadcast messages to all connected clients
- **Steps**:
  - [ ] Create `src/ws/broadcast.ts`
  - [ ] Implement `broadcastMessage(msg, excludeClient?)`
  - [ ] Handle client filtering
  - [ ] Add message validation
- **Status**: [ ]

## UI

### Chat Message Component
- **Category**: ui
- **Description**: Display individual chat messages
- **Steps**:
  - [ ] Create `src/components/ChatMessage.tsx`
  - [ ] Show sender, timestamp, content
  - [ ] Style sent vs received differently
  - [ ] Handle long messages (truncate/expand)
- **Status**: [ ]
```
