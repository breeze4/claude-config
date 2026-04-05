---
description: Post-implementation review pass — run in fresh context after /implement_plan completes
---

# Review Plan

Autonomous review and cleanup pass after implementation. Run in a fresh context for "fresh eyes" on the code.

## Getting Started

When invoked with a plan path, proceed directly to review.

If no plan path provided:
```
I'll review an implemented plan and make autonomous fixes.

Please provide the path to the plan file:
- Example: docs/plans/2026-01-16-feature.md
```

## Process

### 1. Read the Plan

- Understand what was implemented
- Note which files were changed
- Check that all phases are marked complete

### 2. Review Changed Files

For each file modified during implementation:

**Must Fix (autonomous):**
- Pattern violations (doesn't match codebase conventions)
- Unnecessary complexity
- Missing error handling for likely failure modes
- Debug code left behind (console.log, commented code, TODO-for-self)
- Dead code introduced
- Obvious bugs

**Should Fix (autonomous):**
- Naming inconsistencies
- Readability issues
- Test gaps (obvious cases not covered)

**Note Only (don't fix without asking):**
- Style preferences
- Changes that alter behavior
- Risky refactors
- Anything that might break working code

### 3. Make Fixes

- Make changes directly for Must Fix and Should Fix items
- Run verification after each change
- Stop if something breaks

### 4. Run Full Verification

- Use the **stack-detection** skill to determine correct commands
- Run all project checks (test, lint, typecheck, build)

### 5. Report

```
## Review Complete

**Files Reviewed:** N
**Fixes Made:** N
**Notes for Future:** N

### Fixes Applied
1. `file:line` - What was fixed

### Notes (No Action Taken)
1. `file` - Observation (reason for not fixing)

### Verification
All checks passed.
```

## Principles

- **Be autonomous**: don't ask permission for obvious fixes
- **Be conservative**: when in doubt, note it instead of fixing
- **Verify everything**: run tests after each change
- **Don't over-improve**: no refactoring working code, no feature additions, no style nitpicks the linter doesn't catch
