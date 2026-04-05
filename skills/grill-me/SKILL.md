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

4. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

For each module, identify whether it **defines** a shared interface (model, schema, API shape) or **consumes** one. This matters downstream — interface-defining modules need verification gates before consumers build on them. Surface these boundaries explicitly.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

5. Once you have a complete understanding of the problem and solution, use the template below to write the PRD. Save it to `docs/specs/<descriptive-name>.md` in the project directory.

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

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)
- Frontend verification strategy: if the feature adds UI elements, note whether automated component tests, agent-browser screenshots, or manual smoke-testing is expected. Surface gaps explicitly — "N modules modify frontend with no test coverage beyond build"

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

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

</lightweight-spec-template>
