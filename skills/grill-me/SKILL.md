---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree, then produce a structured PRD. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

This skill will be invoked when the user wants to create a PRD.

## 0. Decide on spec weight

Before diving in, assess whether this needs a **full PRD** or a **lightweight spec**:

| Signal | Full PRD | Lightweight spec |
|---|---|---|
| Multiple components/layers with design choices | Yes | |
| Unclear scope, needs boundary-setting | Yes | |
| New user-facing feature with multiple interactions | Yes | |
| Mechanical change, clear scope, no design decisions | | Yes |
| Single vertical slice, "add X to every layer" | | Yes |
| Extending an existing pattern with no new architecture | | Yes |

**Full PRD**: follow all steps below, use the full PRD template.
**Lightweight spec**: skip the exhaustive interview (step 3 — ask only clarifying questions if something is ambiguous), skip user stories, and use the lightweight template at the bottom of this skill. The lightweight template covers Problem/Solution/Data Flow/Behavior — enough for spec-to-plans to work with.

Tell the user which mode you're recommending and why. They can override.

## Steps

1. Ask the user for a long, detailed description of the problem they want to solve and any potential ideas for solutions.

2. Explore the repo to verify their assertions and understand the current state of the codebase.

3. Interview the user relentlessly about every aspect of this plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. (Skip for lightweight specs — ask only if something is genuinely ambiguous.)

   Track each decision as you go. When the user resolves a tradeoff, note it as a resolved decision with the reasoning. When the user says "I don't know yet" or "depends on what we find in the code," note it as an unresolved judgment call — don't silently drop it.

4. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

For each module, identify whether it **defines** a shared interface (model, schema, API shape) or **consumes** one. This matters downstream — interface-defining modules need verification gates before consumers build on them. Surface these boundaries explicitly.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

5. Once you have a complete understanding of the problem and solution, use the template below to write the PRD. Save it to `docs/specs/YYYY-MM-DD-NN-slug.md` in the project directory (check existing files in `docs/specs/` to determine the next NN).

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

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

</prd-template>

<lightweight-spec-template>

## Problem

The problem the user is facing, concisely stated.

## Solution

The solution, concisely stated. Include what fields/values/parameters are being added.

## Data Flow

How data moves through the system — which layers are touched and in what order. Name the functions/endpoints/components but not file paths (those change).

## Behavior

Bullet list of observable behaviors: defaults, edge cases (NULLs), clone/copy behavior, what happens to existing data.

## Judgment Calls

- [ ] **<Short description>**: <context and options>
  - Option A: <description> — <tradeoff>
  - Option B: <description> — <tradeoff>
  - Resolution: <blank until resolved>

Omit this section if no ambiguity exists.

</lightweight-spec-template>
