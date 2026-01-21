---
description: Deep explanation of specific code - lighter than full research
---

# Explain Code

Provide focused explanation of specific code: what it does, why, and how it connects to the system.

## Getting Started

When invoked with a target (file path or concept), proceed directly to explanation.

If no target provided:
```
I'll explain how specific code works, tracing connections and providing file:line references.

What would you like me to explain?
- A file path: src/services/auth.ts
- A concept: "the login flow"
- A pattern: "how errors are handled in the API layer"
```

## Usage Examples

```
/explain src/services/auth.ts
/explain the login flow
/explain how errors are handled in the API layer
```

## Process

### 1. Identify Target

If given a file path:
- Read the file FULLY
- Identify the main components (functions, classes, exports)

If given a concept:
- Use codebase-locator to find relevant files
- Read the most relevant files FULLY

### 2. Trace Connections

For each significant component:
- **Callers**: Who calls this? (grep for function/class name)
- **Callees**: What does this call? (read the implementation)
- **Data flow**: What goes in, what comes out?

### 3. Explain

Structure your explanation:

```
## [Component Name]

**Location:** `path/to/file.ts:line`

**Purpose:** [One sentence - what problem does this solve?]

**How it works:**
[Concise explanation of the implementation]

**Key connections:**
- Called by: `other/file.ts:functionName` - [why]
- Calls: `dependency.ts:helperFn` - [why]
- Uses: [data structures, external services, etc.]

**Important details:**
- [Edge cases handled]
- [Assumptions made]
- [Non-obvious behavior]
```

### 4. Provide Context

Connect to the broader system:
- Where does this fit in the architecture?
- What patterns does it follow?
- What would break if this changed?

## Guidelines

**DO:**
- Read code before explaining
- Include file:line references
- Trace actual call paths
- Explain the "why" not just the "what"
- Note non-obvious behavior

**DON'T:**
- Suggest improvements (unless asked)
- Critique the implementation
- Speculate about intent - read the code
- Write lengthy output for simple code

## Output Format

Keep it concise. For a simple function, a few sentences suffice:

```
`validateEmail` in `src/utils/validation.ts:45` checks email format using a regex pattern.
It's called by the signup form (`src/components/SignupForm.tsx:78`) and the user settings
page (`src/pages/Settings.tsx:156`). Returns boolean, throws no errors.
```

For complex systems, use the structured format above but stay focused on what was asked.

## When to Use /research_codebase Instead

Use `/explain` for:
- Specific file or function
- Single concept or flow
- Quick understanding

Use `/research_codebase` for:
- Broad architectural questions
- Multi-component investigation
- Documentation that should be saved
