---
description: Create detailed implementation plans through interactive research and iteration
model: opus
---

# Create Implementation Plan

Create a detailed, phased implementation plan through interactive research and iteration.

## Initial Response

When invoked:

1. **If parameters were provided** (file path, description, ticket URL):
   - Read any provided files FULLY
   - Begin research immediately

2. **If no parameters**, respond with:
```
I'll help you create an implementation plan. Please provide:
1. A description of what to build (or a spec/requirements file)
2. Any constraints or context

Tip: `/create_plan docs/SPEC.md` or `/create_plan "add search to the dashboard"`
```

## Process

### Step 1: Context Gathering

1. **Read all mentioned files FULLY** — never partially
2. **Spawn parallel research agents** to understand the codebase:
   - **codebase-locator**: find related files
   - **codebase-analyzer**: understand current implementation
   - **codebase-pattern-finder**: find conventions to follow
3. **Read all files identified by research**
4. **Present findings and focused questions** — only ask what code investigation couldn't answer

### Step 2: Research & Discovery

After initial clarifications:

1. If the user corrects a misunderstanding, verify the correction in code before proceeding
2. Spawn parallel agents for deeper investigation as needed
3. Present design options with pros/cons
4. Resolve all open questions before planning

### Step 3: Plan Structure

Get buy-in on the phased approach before writing details:

```
Proposed phases:
1. [Phase name] - [what it accomplishes]
2. [Phase name] - [what it accomplishes]

Does this phasing make sense?
```

**Ordering principle**: infrastructure before functional before UI. Dependencies flow downward — no phase should depend on an incomplete phase below it.

### Step 4: Write the Plan

Write to `docs/plans/YYYY-MM-DD-description.md` using this format:

````markdown
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
  - File: `path/to/file` (if known)
  - Detail: what to change
- [ ] Next task
  - File: `path/to/file`
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
````

### Step 5: Review with User

```
Plan written to docs/plans/YYYY-MM-DD-description.md

Please review:
- Are phases properly scoped (atomic, each leaves app working)?
- Are tasks specific enough to execute without ambiguity?
- Missing edge cases or considerations?
```

Iterate until the user is satisfied.

## Plan Format Rules

1. **Phases are atomic**: after completing any phase, the app works
2. **Tasks are ordered**: within a phase, complete top-to-bottom
3. **Checkboxes are state**: checked = done, unchecked = todo. No separate execution log needed.
4. **Category tags guide ordering**: infrastructure → functional → ui
5. **No code in plans**: pseudocode for key algorithms only, per project conventions
6. **No open questions in final plan**: resolve everything during the interactive process
7. **Verification is per-phase**: automated checks that prove the phase works

## Guidelines

- **Be skeptical**: question vague requirements, verify assumptions in code
- **Be interactive**: get buy-in at each step, don't write the whole plan in one shot
- **Be thorough**: read files completely, research actual patterns, include file:line refs
- **Be practical**: incremental testable changes, consider migration and rollback
- **No estimates**: never predict hours or days
