---
name: spec-to-plans
description: Break a spec into independently-grabbable implementation plans using vertical slices (tracer bullets), saved as markdown files in docs/plans/. Use when user wants to break a spec into plans, create implementation plans from a spec, or plan a spec locally.
---

### 1. Locate the spec

Ask the user for the spec source. This can be:
- A local file path — read directly
- Already in context from conversation

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the spec into **tracer bullet** plans. Each plan is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

**Single-slice specs still get the full plan template.** If the spec is small enough that it's one vertical slice, that's fine — but do not shortcut to a bare checkbox list. The structured fields (Owns, Must not touch, Pattern exemplar) are consumed by plans-to-prompt and are non-negotiable even for a single plan.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the spec this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Create the plan files

For each approved slice, create a markdown file in `docs/plans/` using the naming convention `<number>-<short-name>.md` (e.g., `01-auth-flow.md`, `02-data-model.md`).

Number plans in dependency order (blockers first). Use the plan template below.

<plan-template>
# <Plan Title>

## Parent spec

<Link to spec issue or file path>

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Reference specific sections of the parent spec rather than duplicating content.

## Type

HITL / AFK

## Blocked by

- Blocked by `<number>-<name>.md` (if any)

Or "None - can start immediately" if no blockers.

## User stories addressed

Reference by number from the parent spec:

- User story 3
- User story 7

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Owns

Files/directories this plan creates or modifies. Be specific — this becomes the agent's scope boundary.

When a plan modifies specific functions within a shared file (e.g., one endpoint in a router that has many), list the file AND the specific functions/sections. This prevents the agent from drifting into adjacent code and ensures plans-to-prompt can set precise scope. Also list ALL call sites — grep for the functions being modified to find every caller, not just the obvious one.

- `<file path>` — `<function or section name>`

## Must not touch

Files/directories explicitly outside this plan's scope. Include files that a later plan will modify, even if touching them seems natural.

- `<file or directory path>` — owned by plan `<NN-name>.md`

## Defines interfaces

If this plan creates or modifies shared interfaces (models, schemas, API shapes, service return types) that other plans consume, list them here. This tells plans-to-prompt where to insert interface verification gates.

- `<interface name>` in `<file path>` — consumed by plans `<NN>`, `<NN>`

Or "None" if this plan only consumes existing interfaces.

## Pattern exemplar

Identify an existing file the implementer should use as a template. Ask: "does this plan create something that's a sibling of an existing thing?" If yes, find the best sibling:

- New route/endpoint → existing route in the same directory
- New model/entity → existing model in the same ORM pattern
- New test file → existing test for a similar module (matches runner, assertion style, setup/teardown)
- New migration → most recent migration (matches format)
- New middleware/plugin/hook → existing one in the same chain

Pick one that's well-structured and representative, not the simplest or most complex. If no exemplar exists, write "None — first of its kind, refer to spec for interface requirements."

Mark as **hard** (must create same kind of artifact in same location) or **soft** (style reference, agent may adapt):

- **MUST follow the pattern in**: `<file path>` — <what to match> *(use when the plan says "add a migration in X", "create a file in Y")*
- **Follow the pattern in**: `<file path>` — <what to match> *(use when the plan says "look at X for conventions")*

## Tasks

- [ ] Task 1 (atomic, incremental, leaves app functional)
- [ ] Task 2
- [ ] Task 3

## Implementation notes (optional)

For mechanical/repetitive changes where the pattern is clear, include concrete notes showing exactly what to change. This is especially valuable when replacing hardcoded values — name every call site, show the before/after shape, and flag any associated comments that reference the old values. Agents reliably follow concrete examples and reliably fail on vague instructions like "update all call sites."

</plan-template>

Ensure the `docs/plans/` directory exists before writing files. Create it if needed.
