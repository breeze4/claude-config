---
name: interview
description: Interview user in-depth to create a detailed spec. Use when starting a new feature, project, or complex task that needs requirements gathering before implementation.
argument-hint: [instructions]
allowed-tools: AskUserQuestion, Write
---

# Interview

Interview the user in-depth to create a detailed specification document.

## Process

Follow the user instructions provided in `<instructions>` tags (if any) and interview the user about their requirements.

### What to Ask About

- Technical implementation details
- UI and UX considerations
- Edge cases and error handling
- Tradeoffs and constraints
- Dependencies and integrations
- Performance requirements
- Security considerations
- Data models and schemas
- User workflows and journeys
- Acceptance criteria

### How to Ask

- Use AskUserQuestion tool for each question
- Be very in-depth - do not ask obvious questions
- Follow up on answers to dig deeper
- Cover multiple angles of each topic
- Continue interviewing until requirements are complete

### Interview Strategy

1. Start with high-level goals and context
2. Drill into specific features one by one
3. Explore edge cases and failure modes
4. Clarify ambiguities and assumptions
5. Confirm understanding before moving on

### When Complete

Write the spec to `docs/SPEC.md` (or the path specified in instructions).

The spec should include:
- Project/feature overview
- Detailed requirements
- Technical approach
- Data models (if applicable)
- UI/UX specifications (if applicable)
- Edge cases and error handling
- Open questions (if any remain)

<instructions>$ARGUMENTS</instructions>
