---
name: plans-to-prompt
description: Take implementation plans from docs/plans/ and generate an orchestration prompt that executes them via parallel/serial agents with build/test gates. Use when user wants to execute plans, run plans, orchestrate plan implementation, or turn plans into an executable prompt.
---

## 0. Leverage existing context

This skill is often run in the same session as `grill-me` and `spec-to-plans`. Before reading anything from disk, check what you already know:

- **Plans**: If you just created the plan files, you already have their full content, dependency relationships, and the reasoning behind the slice boundaries. Use that. Only re-read plan files to confirm final on-disk state if you're unsure edits landed correctly.
- **Codebase knowledge**: If you explored the codebase during planning, you already know which files each plan will touch. This is critical for conflict detection in step 4 — don't re-derive it from plan text alone when you have richer knowledge from actually reading the source.
- **Implicit dependencies**: Plans capture explicit "Blocked by" relationships, but the planning conversation often reveals softer dependencies — shared utility functions, migration ordering, config that must exist before consumers. Incorporate these even if they aren't in the plan files.
- **Stack/tooling**: If you already identified build/test/lint commands, skip re-detection.
- **Risk signals from the interview**: If grill-me surfaced areas of uncertainty, architectural risk, or "we're not sure about this yet" — those are strong HITL candidates even if the plan says AFK.

If running in a fresh context without prior planning conversation, fall back to reading everything from disk.

## 1. Gather plans and research

**Always glob `docs/plans/*.md` and scan every file.**

Also check `docs/research/` for research artifacts. If any exist, read them — they contain:
- **File Map**: enriches agent briefings with concrete file paths and line numbers
- **Judgment Calls**: unresolved items must appear at the top of the orchestration prompt
- **Patterns & Conventions**: feeds into agent briefing pattern-following sections
- **Dependencies & Compatibility**: informs gate design and blockers This is non-negotiable even if you just created the plans — there may be pre-existing plans from earlier sessions that are prerequisites or already completed.

For each plan file, do a fast triage read (title, "Blocked by", and checkbox status). Categorize into:

- **Done**: all task checkboxes checked → note as completed, exclude from orchestration
- **Partially done**: some checkboxes checked → include, but only unchecked tasks
- **Not started**: no checkboxes checked → include fully

For plans you already have in context from this session, the triage read just confirms on-disk state matches what you expect. For plans you don't recognize, do a full read.

After triage, cross-reference against your in-context knowledge from step 0. If you recall details that aren't in the plan files (e.g., a dependency discussed but not written down), note them — you'll use them in step 2.

## 2. Build dependency graph

From the "Blocked by" fields **plus any implicit dependencies you know from the planning conversation**, construct a DAG. Identify:

- **Roots**: plans with no blockers — can start immediately
- **Serial chains**: plans that must execute in sequence
- **Potential parallel groups**: sets of unblocked plans that share no file-level conflicts (but see step 4 — serial is the default)

Validate the graph is acyclic. If cycles exist, stop and report them.

If you have codebase knowledge from exploration, use it to enrich the graph: two plans might not declare a dependency on each other but both modify the same module — flag this as a soft dependency.

## 3. Detect the project stack

If you already know the build/test/lint commands from earlier in this conversation, use them directly. Otherwise:

- Look for README, `package.json`, `Makefile`, `Cargo.toml`, `build.gradle`, `pyproject.toml`, etc.
- Identify the build command (e.g., `npm run build`, `cargo build`) - check for dev or prod build  or targets options, prefer full dev build
- Identify the test command (e.g., `npm test`, `pytest`)
- Identify the lint command if present
- Check for a `CLAUDE.md` in the project root that may specify these

Record these as variables in the output prompt: `$BUILD_CMD`, `$TEST_CMD`, `$LINT_CMD`.

## 4. Plan execution order

**Default to serial execution.** Run plans one at a time in dependency order. This is the safe default and should be used unless parallelization has a clear, significant benefit with no risk of conflict.

Only parallelize when ALL of these are true:

- Plans have zero blocked-by relationship to each other
- Plans touch completely disjoint sets of files (no shared source files, no shared config, no shared generated files)
- Neither plan modifies build config, dependencies, or shared state
- The time savings are significant (e.g., two large independent features, not two small tasks)

When in doubt, serialize. A merge conflict or subtle interaction bug costs more than the time saved by parallelizing.

```
Step 1: 2026-04-04-01-data-model  ← no blockers
Step 2: 2026-04-04-03-config       ← no blockers, but shares config with step 1, so serial
Step 3: 2026-04-04-02-auth         ← blocked by step 1
Step 4: 2026-04-04-04-billing, 2026-04-04-05-reporting  ← blocked by step 3, truly disjoint, parallel OK
```

Flag HITL plans — these require user checkpoints.

## 5. Assign agent roles

For each plan, assign an agent configuration. **Foreground serial is the default.** Only use worktrees for genuinely parallel work. Parallel worktrees are the exception, not the rule. Justify each one explicitly in the output.

### Execution mode

| Plan characteristic | Mode | Rationale |
|---|---|---|
| Most plans (default) | `general-purpose`, foreground, serial | Safe, predictable |
| Cross-cutting refactor | `general-purpose`, foreground, serial | Touches many files |
| HITL plan | Foreground, pauses for user | Requires decisions |
| Truly independent (parallel approved) | `general-purpose`, `isolation: "worktree"` | Proven disjoint files |

### Agent granularity

The orchestration prompt must include a granularity policy so the executing session knows when to spawn agents vs. keep work inline. Include this section verbatim in the output prompt, customized to the project:

```
## Agent granularity rules

**Default grain: one agent per plan.** Each plan file maps to one implementation agent. Do not split a plan across multiple agents, and do not combine multiple plans into one agent.

Exceptions:
- **Pre-flight exploration** uses a lightweight `Explore` agent before an implementation agent when the target code is unfamiliar. Its output feeds the implementation agent's briefing.
- **Large plans (10+ tasks)**: if a plan has natural phase boundaries where intermediate verification makes sense, split at those boundaries. Each sub-agent gets a contiguous slice of tasks from the plan. Never split mid-task.
- **Never go smaller than a plan.** Individual tasks within a plan share context and often depend on each other implicitly. Splitting tasks across agents loses that context and creates coordination overhead that costs more than it saves.

When in doubt, keep work in fewer agents. An agent that does 8 tasks in sequence with full context will outperform 4 agents doing 2 tasks each with handoff overhead.
```

Adjust the specific numbers (10+ tasks threshold) based on plan complexity — simpler, mechanical tasks can have a higher threshold; complex tasks with lots of interdependency should stay in one agent even at higher task counts.

### Agent briefing

Each agent in the output prompt must include a structured briefing. The briefing becomes the agent's prompt — it's literally what the spawned agent sees. Make it count by addressing the ways agents actually fail:

1. They don't match existing code patterns and reinvent things
2. They drift into modifying files outside their scope
3. They don't know what the previous step changed
4. They hit ambiguity and guess instead of stopping
5. They do the next step's work because it "seemed natural"

Every briefing must include these fields:

```
**Agent briefing**: <plan name>
- **Context sources** (orchestrator reads these): <files the orchestrator should read and inline>
- **Read first**: <plan file only — the agent always reads its own plan>
- **Context**: <orchestrator pastes relevant code snippets here before launching>
- **Owns**: <files/directories this agent may create or modify>
- **Must not touch**: <files/directories outside scope>
- **Prior step context** (expected): <what the previous step should produce — treat as fallback>
- **Done when**: <concrete exit criteria — specific observable outcomes>
- **Handoff**: When done, write `docs/handoff/step-N.md` listing: exact field/function names added or changed, files modified, anything the next step should know. **Skip for single-step orchestrations** — handoffs exist for inter-agent context bridging and have no consumer in a single-agent plan.
```

The orchestrator's job is active context management. Before launching each step's agent, the orchestrator reads the files listed under "Context sources" and includes the relevant sections in the agent's "Context" field. This eliminates the 10-15 tool calls each agent wastes reading files at startup.

Then add whichever of these apply — not all will be needed for every plan:

- **MUST follow the pattern in** (hard): "You must create the same kind of artifact in the same location. This is not optional." Use when the plan specifies a particular approach — "add a migration in X", "create a file in Y", a specific directory structure.
- **Follow the pattern in** (soft): "Use this as a style reference for how to structure your code." Agent may adapt. Use when the plan just says "look at X for conventions."
- **Do not** — name the owning step: "Do not add macro_target — that is Step 5's responsibility." Scan each subsequent step's "Owns" list. If anything there touches a file the current step also touches, add an explicit exclusion.
- **If replacing hardcoded values**: "Check for associated comments that reference the old values and update or remove them."
- **If unclear, stop**: specific ambiguities where the agent should ask rather than guess

Always include this scope rule in every agent briefing: "Stay within your plan's scope. If you see an obvious improvement that belongs to a later step, leave it."

**Pattern-following** — hard pattern (plan says "create a migration file in X"):

```
**Agent briefing**: 03-billing-endpoint
- **Context sources** (orchestrator reads these): `src/routes/users.ts`, `src/services/billing.ts`
- **Read first**: `docs/plans/03-billing-endpoint.md`
- **Context**: <orchestrator pastes route handler pattern from users.ts and BillingService interface here>
- **Owns**: `src/routes/billing.ts`, `tests/routes/billing.test.ts`
- **Must not touch**: anything outside `src/routes/billing*` and `tests/routes/billing*`
- **MUST follow the pattern in**: `src/routes/users.ts` — same middleware chain, same error handling shape, same response envelope. Do not invent a new pattern.
- **Prior step context** (expected): Step 2 added BillingService at `src/services/billing.ts` with `getUsage(orgId): UsageRecord[]`.
- **Handoff**: Write `docs/handoff/step-3.md` with route paths, handler signatures, and test count.
```

Without the pattern line, the agent writes code from scratch. With it, it copies the structure and adapts. This is the single highest-value line you can add.

**Constraint-heavy** — when the plan is simple but scope creep is the risk:

```
**Agent briefing**: 05-add-created-at-column
- **Context sources** (orchestrator reads these): `src/models/order.ts`
- **Read first**: `docs/plans/05-add-created-at-column.md`
- **Context**: <orchestrator pastes Order interface definition here>
- **Owns**: `migrations/007_orders_created_at.sql`, `src/models/order.ts` (type update only)
- **Must not touch**: any route, any test, any other model. Schema + type only.
- **Do not**: add default values in application code (the migration handles the default), modify the Order constructor, or add validation. Do not add query methods — that is Step 6's responsibility.
- **Handoff**: Write `docs/handoff/step-5.md` with the new field name, type, and migration number.
```

**Context-bridge** — when step N depends heavily on step N-1's actual output:

```
**Agent briefing**: 04-auth-integration
- **Context sources** (orchestrator reads these): `src/middleware/requireAuth.ts`, `docs/handoff/step-3.md`
- **Read first**: `docs/plans/04-auth-integration.md`
- **Context**: <orchestrator reads handoff file + requireAuth.ts and pastes actual interface here>
- **Owns**: `src/routes/billing.ts` (adding middleware), `src/routes/admin.ts` (adding middleware)
- **Must not touch**: `src/middleware/`, `src/models/`, `migrations/`
- **Prior step context** (expected): Step 3 added `requireAuth(role?: string)` — but read `docs/handoff/step-3.md` for what was actually produced. Trust the handoff over this description.
- **Handoff**: Write `docs/handoff/step-4.md` with which routes got middleware and the auth check shape.
```

The handoff file is the source of truth for what the previous step actually produced. "Prior step context" is a fallback prediction.

### Pre-flight exploration

For plans that touch unfamiliar or complex areas of the codebase, add an exploration phase before the implementation agent:

```
**Pre-flight**: spawn `Explore` agent to map <directory> before implementing. Report file structure and key interfaces. Feed findings into the implementation agent's briefing.
```

Use when:
- The plan touches modules the planning session didn't explore
- The plan modifies code written by a previous step (the agent needs to see the actual output, not just the plan's description of it)

Write the result of the pre-flight exploration to the plan itself so this gets updated.

### Lookahead research (serial chains only)

In a serial chain, the orchestrator sits idle waiting for agent N to finish before thinking about agent N+1. Many of N+1's context source files are ones that N doesn't modify — they're stable and can be pre-read.

For each serial step after the first:
1. Check which of the step's context source files are in the **previous** step's "Must not touch" list — these are stable.
2. If stable files exist, the orchestrator should launch a background `Explore` agent for those files while the previous step executes. The Explore agent reads them and produces a structured context brief.
3. When step N completes, the orchestrator only needs to read files that N actually modified (check the handoff file) + merge with the lookahead brief, then launch N+1 immediately.

Add a `**Lookahead** (while step N runs)` section to each serial step (except step 1) in the output template. It lists which files to pre-read and what to extract (function signatures, insertion points, patterns).

If ALL of a step's context sources are modified by the prior step, skip the lookahead — there's nothing stable to pre-read.

## 6. Place build/test gates

Insert verification checkpoints using these rules:

- **After each stage completes**: run `$BUILD_CMD` and `$TEST_CMD`
- **Exception — batch similar changes**: if consecutive plans in a serial chain make changes that are known to be incomplete until all are done (e.g., renaming across files, multi-file migration), group them and gate after the group
- **After worktree merges**: always build+test after merging worktree branches back
- **Lint**: run `$LINT_CMD` at stage boundaries, not after every plan
- **HITL checkpoints**: pause for user review before and after HITL plans

Each gate specifies:
- What to run
- What "pass" looks like
- What to do on failure (stop and report, not auto-fix)

### Interface checkpoints

When early steps define shared interfaces (models, schemas, API shapes) and later steps consume them, a mistake in step 2 propagates silently through steps 3-6. Add **interface gates** to catch this:

- After the last step that *defines* a shared interface and before the first step that *aggregates* across those interfaces, insert a lightweight verification gate.
- This isn't a full build+test. It's a schema shape check: "Verify that `IngredientRead` has `protein_per_oz`, `RecipeDetailRead` has `protein_g`" — the specific fields that aggregation steps depend on.
- Mark these as `**Interface gate**` in the output, distinct from `**Gate**`. The orchestrator runs them as a quick Explore agent or inline check.
- Use the plan's "Defines interfaces" field (from spec-to-plans) to identify which steps need interface gates after them.

### Frontend verification

Backend gets automated test coverage from test suites. Frontend often gets only a build check — which catches syntax and import errors but not rendering, interaction, or data display bugs.

- If plans add visible UI elements (columns, modals, components), the gate should include either: (a) a component test expectation in the acceptance criteria, or (b) a manual smoke-test note in the orchestration prompt's completion criteria.
- Add to the completion criteria: "If running AFK, consider adding a final verification step that launches the dev server and uses agent-browser to screenshot each modified page."
- Surface the gap in the review: "Note: N steps modify frontend with no UI test coverage beyond build. Consider adding a smoke-test checkpoint."

## 7. Generate the prompt document

Write the orchestration prompt to `docs/prompts/YYYY-MM-DD-NN-slug.md` (e.g., `docs/prompts/2026-04-04-01-billing-feature.md`). Check existing files to determine the next NN.

Use this structure:

```markdown
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

You are not just spawning agents — you are actively managing context between them. Before launching each step's agent:

1. Read the files listed under "Context sources" and include relevant sections in the agent's "Context" field.
2. If a previous step completed, read `docs/handoff/step-{N-1}.md` and use it (not "Prior step context") to fill in what changed.
3. If a "Lookahead" section exists for this step, its background research should already be complete — merge those findings into the context.

This eliminates the 10-15 tool calls each agent wastes reading files at startup.

## Agent granularity rules

**Default grain: one agent per plan.** Each plan file maps to one implementation agent. Do not split a plan across multiple agents, and do not combine multiple plans into one agent.

Exceptions:
- **Pre-flight exploration** uses a lightweight `Explore` agent before an implementation agent when the target code is unfamiliar.
- **Large plans (10+ tasks)**: split at natural phase boundaries. Each sub-agent gets a contiguous slice. Never split mid-task.
- **Never go smaller than a plan.** Tasks within a plan share context — splitting them across agents loses that context.

When in doubt, keep work in fewer agents.

## Execution plan

### Step 1 — <description>

**Plan**: `docs/plans/01-data-model.md`

**Agent briefing**:
- **Context sources** (orchestrator reads these): `docs/specs/<spec>.md`, `src/models/index.ts`, `src/models/order.ts`
- **Read first**: `docs/plans/01-data-model.md`
- **Context**: <orchestrator pastes model patterns from order.ts and relevant spec section here>
- **Owns**: `src/models/user.ts`, `migrations/003_users.sql`
- **Must not touch**: `src/routes/`, `src/middleware/`
- **MUST follow the pattern in**: `src/models/order.ts` — same ORM style, same export shape
- **Do not**: add route handlers or middleware — that is Step 2 and Step 3's responsibility.
- **Handoff**: Write `docs/handoff/step-1.md` with model field names, migration number, and export shape.

**Gate**: `$BUILD_CMD && $TEST_CMD`

### Step 2 — <description>

**Plan**: `docs/plans/02-auth-middleware.md`

**Lookahead** (while step 1 runs): spawn background `Explore` agent to read `src/middleware/index.ts` and `src/middleware/cors.ts` — these are in step 1's "Must not touch" list, so they're stable. Extract middleware signature pattern and error response shape.

**Agent briefing**:
- **Context sources** (orchestrator reads these): `docs/handoff/step-1.md`, `src/models/user.ts` (modified by step 1), lookahead findings
- **Read first**: `docs/plans/02-auth-middleware.md`
- **Context**: <orchestrator pastes User model interface from handoff + middleware patterns from lookahead>
- **Owns**: `src/middleware/auth.ts`, `tests/middleware/auth.test.ts`
- **Must not touch**: `src/models/`, `src/routes/`, `migrations/`
- **Follow the pattern in**: `src/middleware/cors.ts` — same middleware signature, same error response shape
- **Prior step context** (expected): Step 1 added User model with `findByToken()`. Trust `docs/handoff/step-1.md` over this description.
- **Handoff**: Write `docs/handoff/step-2.md` with export names, middleware signature, and what `req.user` looks like.

**Gate**: `$BUILD_CMD && $TEST_CMD`

### Step 3 — <description>

**Plan**: `docs/plans/03-billing-endpoint.md`

**Pre-flight**: spawn `Explore` agent on `src/services/billing/` — report file structure and key interfaces before implementation.

**Lookahead** (while step 2 runs): the pre-flight above doubles as lookahead — `src/services/billing/` is in step 2's "Must not touch" list.

**Agent briefing**:
- **Context sources** (orchestrator reads these): `docs/handoff/step-2.md`, `src/routes/users.ts`, pre-flight findings
- **Read first**: `docs/plans/03-billing-endpoint.md`
- **Context**: <orchestrator pastes route pattern from users.ts, auth middleware interface from handoff, billing service interface from pre-flight>
- **Owns**: `src/routes/billing.ts`, `tests/routes/billing.test.ts`
- **Must not touch**: anything outside `src/routes/billing*` and `tests/routes/billing*`
- **MUST follow the pattern in**: `src/routes/users.ts`
- **Prior step context** (expected): Step 2 added auth middleware. Trust `docs/handoff/step-2.md` for the actual export name and signature.
- **Do not**: create a new BillingService — `src/services/billing.ts` already exists. Do not add admin routes — that is Step 4's responsibility.
- **Handoff**: Write `docs/handoff/step-3.md` with route paths, handler signatures, and test count.

**Gate**: `$BUILD_CMD && $TEST_CMD && $LINT_CMD`

## Interface gates

- [ ] After step N: verify <Model> has fields `x`, `y`, `z` — aggregation steps depend on these

## HITL checkpoints

- [ ] Step N, plan-NN: <what needs human review and why>

## Completion criteria

- All plan acceptance criteria met
- `$BUILD_CMD && $TEST_CMD && $LINT_CMD` passes
- All HITL checkpoints approved
- If frontend was modified: <N steps modify frontend — consider agent-browser smoke-test screenshot of modified pages>
```

## 8. Review with user

Present the orchestration prompt summary:

- Number of stages
- Which plans are parallel vs serial
- Where the gates are
- Which plans are HITL

Ask:
- Does the parallelization look right?
- Are the gates in sensible places?
- Any plans that should be reordered?

Iterate until approved, then write the final file.

## Key constraints

- The output is a **document**, not live execution. The user will paste it into a fresh session.
- The document expects the orchestrator to do active context management — reading files, running lookahead agents, inlining context into briefings — not just spawning agents verbatim.
- Do not include code for complex logic — reference plan files by path. The orchestrator reads and inlines at execution time. **Exception**: for mechanical/repetitive changes (replacing hardcoded values, adding columns to every layer), include concrete implementation notes showing exact patterns. Agents reliably follow concrete examples; they fail on "update all call sites." If the plan has an "Implementation notes" section, incorporate it into the agent briefing.
- Each agent's instructions should be self-contained once the orchestrator fills in the "Context" field.
- Assume the executing session has access to the Agent tool with worktree isolation.
- Keep the prompt under 3000 words. Link to plans rather than duplicating their content.
- Handoff files go in `docs/handoff/` — the orchestrator creates this directory if needed.
