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

**Full PRD**: follow all steps below, use the full PRD template from [SPEC_TEMPLATE.md](../shared/SPEC_TEMPLATE.md).
**Lightweight spec**: skip the exhaustive interview (step 3 — ask only clarifying questions if something is ambiguous), skip user stories, and use the lightweight spec template from [SPEC_TEMPLATE.md](../shared/SPEC_TEMPLATE.md). The lightweight template covers Problem/Solution/Data Flow/Behavior/Judgment Calls — enough for spec-to-plans to work with.

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

5. Once you have a complete understanding of the problem and solution, write the spec using the appropriate template from [SPEC_TEMPLATE.md](../shared/SPEC_TEMPLATE.md). Save it to `docs/specs/YYYY-MM-DD-NN-slug.md` in the project directory (check existing files in `docs/specs/` to determine the next NN).

   For the full PRD, include the Dependency Strategy and/or Testing Strategy optional sections if the work involves architecture or testing concerns.
