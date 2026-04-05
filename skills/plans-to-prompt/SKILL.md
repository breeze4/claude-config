---
name: plans-to-prompt
description: Take implementation plans from docs/plans/ and generate an orchestration prompt that executes them via parallel/serial agents with build/test gates. Use when user wants to execute plans, run plans, orchestrate plan implementation, or turn plans into an executable prompt.
---

## 1. Gather plans

Glob `docs/plans/*.md` and read every file. Also check `docs/research/` for research artifacts — these contain file maps, unresolved judgment calls, and patterns that enrich agent briefings.

For each plan, triage by checkbox status:

- **Done** (all checked) → exclude from orchestration
- **Partially done** (some checked) → include only unchecked tasks
- **Not started** → include fully

If you already have plan content in context from this session (e.g., from spec-to-plans), just confirm on-disk state matches. Don't re-derive what you already know.

## 2. Build dependency graph

From "Blocked by" fields, construct a DAG. Identify roots (no blockers), serial chains, and potential parallel groups. Validate acyclic — if cycles exist, stop and report.

Also flag soft dependencies: two plans that don't declare a dependency but modify the same files.

## 3. Detect project stack

Find the build, test, and lint commands from `package.json`, `Makefile`, `Cargo.toml`, `pyproject.toml`, `CLAUDE.md`, etc. Record as `$BUILD_CMD`, `$TEST_CMD`, `$LINT_CMD`. Skip if you already know these from earlier in the conversation.

## 4. Plan execution order

**Default to serial.** Only parallelize when ALL of these hold:

- No blocked-by relationship between the plans
- Completely disjoint file sets (no shared source, config, or generated files)
- Neither plan modifies build config, dependencies, or shared state
- The time savings are significant (two large features, not two small tasks)

When in doubt, serialize. Flag HITL plans — these need user checkpoints.

## 5. Write agent briefings

Each plan maps to one agent. Don't split a plan across agents or combine plans. Exception: plans with 10+ tasks can split at natural phase boundaries.

Each briefing uses this structure:

```
**Agent briefing**: <plan name>
- **Context sources** (orchestrator reads these): <files to read and inline before launch>
- **Read first**: <plan file>
- **Context**: <orchestrator pastes relevant code here>
- **Owns**: <files/dirs this agent may create or modify>
- **Must not touch**: <everything outside scope>
- **Prior step context**: <what the previous step should have produced>
- **Done when**: <concrete exit criteria>
- **Handoff**: Write `docs/handoff/step-N.md` listing changes made. Skip for single-step orchestrations.
```

Then add whichever of these apply:

- **MUST follow the pattern in** (hard): when the plan specifies a particular file to copy structure from. This is the highest-value line — without it agents reinvent from scratch.
- **Do not — name the owning step**: "Do not add X — that is Step N's responsibility." Check each later step's Owns list for overlapping files.
- **If unclear, stop**: name specific ambiguities where the agent should ask rather than guess.

Always include: "Stay within your plan's scope. If you see an improvement that belongs to a later step, leave it."

The orchestrator's job is **active context management**. Before launching each agent, it reads "Context sources", reads handoff files from prior steps, and inlines the relevant bits. This eliminates startup file-reading overhead.

## 6. Place gates

- **After each step**: run `$BUILD_CMD && $TEST_CMD`
- **Exception**: batch consecutive steps that are incomplete until all finish (e.g., multi-file rename)
- **After worktree merges**: always build+test
- **Lint**: at stage boundaries, not after every step
- **HITL**: pause before and after HITL plans

Each gate specifies what to run, what "pass" looks like, and what to do on failure (stop and report — not auto-fix).

If early steps define shared interfaces that later steps consume, add a lightweight **interface gate** after the defining step: verify the expected fields/types exist before proceeding.

## 7. Generate the prompt

Write to `docs/prompts/YYYY-MM-DD-NN-slug.md`. Check existing files for next NN.

Use the template in `skills/plans-to-prompt/TEMPLATE.md`. Keep the prompt under 3000 words — link to plans rather than duplicating content.

## 8. Review with user

Present: number of steps, serial vs parallel decisions, gate placement, HITL checkpoints. Ask if the order, parallelization, and gates look right. Iterate until approved.

## Key constraints

- The output is a **document**, not live execution. The user pastes it into a fresh session.
- Do not include implementation code — reference plan files by path. **Exception**: for mechanical/repetitive changes, include concrete patterns. Agents follow examples; they fail on "update all call sites."
- Each agent's briefing should be self-contained once the orchestrator fills in "Context".
- Assume the executing session has the Agent tool with worktree isolation.
- Handoff files go in `docs/handoff/`.
