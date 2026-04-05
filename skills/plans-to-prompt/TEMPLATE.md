# Orchestration Prompt: <spec name>

## Unresolved Judgment Calls

> **DO NOT proceed past this section until all items are resolved.**

- [ ] <judgment call from research artifact or plans>
  - Option A: ...
  - Option B: ...

*(Omit this section if all judgment calls are resolved.)*

## Project context

- Working directory: <path>
- Research: `docs/research/<artifact>.md` (if available)
- Build: `$BUILD_CMD`
- Test: `$TEST_CMD`
- Lint: `$LINT_CMD`
- Spec: `docs/specs/<spec-file>.md`
- Handoff directory: `docs/handoff/` (create if needed)

## Orchestrator responsibilities

You are actively managing context between agents. Before launching each step:

1. Read the files listed under "Context sources" and include relevant sections in the agent's "Context" field.
2. If a previous step completed, read `docs/handoff/step-{N-1}-<step name>.md` and use it to fill in what changed.

## Execution plan

### Step 1 — <description>

**Plan**: `docs/plans/<plan-file>.md`

**Agent briefing**:
- **Context sources** (orchestrator reads these): <files>
- **Read first**: <plan file>
- **Context**: <orchestrator pastes relevant code here before launch>
- **Owns**: <files/dirs this agent may create or modify>
- **Must not touch**: <everything outside scope>
- **MUST follow the pattern in**: <file> — <what to copy>
- **Do not**: <scope exclusions naming the owning step>
- **Handoff**: Write `docs/handoff/step-1-<step name>.md` with <what to record>.

**Gate**: `$BUILD_CMD && $TEST_CMD`

### Step 2 — <description>

**Plan**: `docs/plans/<plan-file>.md`

**Agent briefing**:
- **Context sources** (orchestrator reads these): `docs/handoff/step-1-<step name>.md`, <other files>
- **Read first**: <plan file>
- **Context**: <orchestrator pastes handoff findings + relevant code here>
- **Owns**: <files>
- **Must not touch**: <files>
- **Follow the pattern in**: <file> — <style reference>
- **Prior step context**: Step 1 added <what>. Trust `docs/handoff/step-1-<step name>.md` over this description.
- **Handoff**: Write `docs/handoff/step-2-<step name>.md` with <what to record>.

**Gate**: `$BUILD_CMD && $TEST_CMD`

*(Continue for each step...)*

## Interface gates

- [ ] After step N: verify <Model> has fields `x`, `y`, `z` — later steps depend on these

## HITL checkpoints

- [ ] Step N, plan-NN: <what needs human review and why>

## Completion criteria

- All plan acceptance criteria met
- `$BUILD_CMD && $TEST_CMD && $LINT_CMD` passes
- All HITL checkpoints approved
- If frontend was modified: <note about smoke-test coverage>
