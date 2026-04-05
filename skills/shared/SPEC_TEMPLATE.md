# Spec Templates

All specs are saved to `docs/specs/YYYY-MM-DD-NN-slug.md` (check existing files to determine the next NN).

Use the **lightweight spec** for mechanical changes, single vertical slices, or extending existing patterns. Use the **full PRD** for multi-component features, unclear scope, or new user-facing features with design decisions.

Any spec may include the **optional sections** when the work involves architecture, dependency, or testing concerns.

All guidance in specs should be durable and NOT coupled to current file paths — name concepts and responsibilities, not files (those change).

---

## Lightweight Spec

<lightweight-spec-template>

## Problem

The problem the user is facing, concisely stated.

## Solution

The solution, concisely stated. Include what fields/values/parameters are being added.

## Data Flow

How data moves through the system — which layers are touched and in what order. Name the functions/endpoints/components but not file paths (those change).

## Behavior

Bullet list of observable behaviors: defaults, edge cases (NULLs), clone/copy behavior, what happens to existing data.

- What the module/feature should own (responsibilities)
- What it should hide (implementation details)
- What it should expose (the interface contract)
- How callers should migrate (if changing an existing interface)

## Judgment Calls

- [ ] **<Short description>**: <context and options>
  - Option A: <description> — <tradeoff>
  - Option B: <description> — <tradeoff>
  - Resolution: <blank until resolved>

Omit this section if no ambiguity exists.

</lightweight-spec-template>

---

## Full PRD

Includes everything in the lightweight spec, plus the sections below. The full PRD replaces the lightweight Problem/Solution with more detailed versions and adds interview-driven sections.

<full-prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

This list should be extremely extensive and cover all aspects of the feature.

## Data Flow

How data moves through the system — which layers are touched and in what order. Name the functions/endpoints/components but not file paths (those change).

## Behavior

Bullet list of observable behaviors: defaults, edge cases (NULLs), clone/copy behavior, what happens to existing data.

- What the module/feature should own (responsibilities)
- What it should hide (implementation details)
- What it should expose (the interface contract)
- How callers should migrate (if changing an existing interface)

## Modules

Modules identified during the interview. For each:

- **<Module name>**: <brief description>
  - Role: **defines** | **consumes** shared interface
  - Interface: <what it exposes or depends on>
  - Test: yes | no (per user decision)

Do NOT include specific file paths — they change. Name concepts and responsibilities.

## Resolved Decisions

Decisions made during the interview, with reasoning. Each entry should capture the tradeoff that was considered and why this option was chosen.

- **<Decision>**: <what was chosen> — <why, what was the alternative>

Categories: architectural decisions, schema changes, API contracts, technical clarifications, specific interactions.

## Judgment Calls

Decisions that could NOT be resolved during the interview — the user said "I don't know yet," "depends on the code," or the answer requires investigation. These carry forward as structured data for `/research` and `/spec-to-plans`.

- [ ] **<Short description>**: <context and options>
  - Option A: <description> — <tradeoff>
  - Option B: <description> — <tradeoff>
  - Resolution: <blank until resolved>

Omit this section if all decisions were resolved.

## Testing Decisions

- Which modules will be tested (reference Modules section above)
- Prior art for the tests (similar types of tests in the codebase)
- Frontend verification strategy: if the feature adds UI elements, note whether automated component tests, agent-browser screenshots, or manual smoke-testing is expected. Surface gaps explicitly — "N modules modify frontend with no test coverage beyond build"

## Out of Scope

What is explicitly NOT part of this work. Be specific — vague exclusions don't prevent scope creep.

</full-prd-template>

---

## Optional Sections

Include these in either template when relevant:

### Dependency Strategy

Which category applies and how dependencies are handled:

- **In-process**: Pure computation, no I/O — merge and test directly
- **Local-substitutable**: tested with [specific stand-in, e.g. PGLite, in-memory FS]
- **Ports & adapters**: port definition, production adapter, test adapter
- **Mock**: mock boundary for external services

### Testing Strategy

- **New boundary tests to write**: behaviors to verify at the interface
- **Old tests to delete**: shallow module tests that become redundant
- **Test environment needs**: local stand-ins or adapters required
