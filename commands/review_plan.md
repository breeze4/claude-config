---
description: Post-implementation review pass - run in fresh context after /implement_plan completes
---

# Review Plan

Autonomous review and cleanup pass after implementation completes. Run this in a fresh Ralph loop iteration (new context) to get "fresh eyes" on the code.

## Purpose

Implementation context is "too close" to code it just wrote. A fresh context:
- Catches inconsistencies the implementer missed
- Identifies unnecessary complexity added during problem-solving
- Removes debug code and implementation artifacts
- Ensures the final code matches project patterns

## Getting Started

When invoked with a plan path, proceed directly to the review process.

If no plan path provided:
```
I'll review an implemented plan and make autonomous fixes for issues like pattern violations, debug code, and unnecessary complexity.

Please provide the path to the plan file:
- Example: docs/plans/2026-01-16-feature.md
```

## When to Use

After `/implement_plan` marks a plan as `ready_for_review` or `completed`:

```
/review_plan docs/plans/2026-01-16-feature.md
```

## Process

### 1. Read the Plan and Execution Log

- Understand what was implemented
- Note which files were changed
- Check the execution log for any issues encountered

### 2. Review Changed Files

For each file modified during implementation:

**Must Fix (autonomous):**
- Pattern violations (doesn't match codebase conventions)
- Unnecessary complexity (over-engineered solutions)
- Missing error handling (for likely failure modes)
- Debug code left behind (`console.log`, commented code, TODO for self)
- Dead code introduced
- Obvious bugs

**Should Fix (autonomous):**
- Naming inconsistencies
- Readability issues (confusing variable names, long functions)
- Missing type annotations (if project uses them)
- Test gaps (obvious cases not covered)

**Note Only (don't fix without asking):**
- Style preferences that don't match reviewer's taste
- "Improvements" that change behavior
- Risky refactors
- Anything that might break working code

### 3. Make Fixes

For Must Fix and Should Fix items:
- Make the changes directly
- Run verification after each change
- Log what you changed and why

### 4. Run Full Verification

- Use the **stack-detection** skill (`skills/stack-detection/SKILL.md`) to determine the correct verification commands
- Run all project checks (test, lint, typecheck, build)
- Ensure nothing broke

### 5. Update Plan Status

Change execution log status to `completed`:

```markdown
### Session: YYYY-MM-DD HH:MM (Review)
**Status**: completed
**Phase**: review

#### Actions Taken
- [HH:MM] Started review pass
- [HH:MM] Fixed: Removed debug console.log in src/api/handler.ts
- [HH:MM] Fixed: Renamed confusing variable `x` to `userCount` in src/utils/stats.ts
- [HH:MM] Fixed: Added missing error handling for network timeout
- [HH:MM] Note: Consider extracting validation logic (not fixing - would change behavior)
- [HH:MM] All verification passed
- [HH:MM] Review complete

#### Notes
Implementation looks good. Minor cleanup done. One suggestion noted for future consideration.
```

### 6. Report Summary

```
## Review Complete

**Files Reviewed:** 5
**Fixes Made:** 3
**Notes for Future:** 1

### Fixes Applied
1. `src/api/handler.ts:45` - Removed debug console.log
2. `src/utils/stats.ts:23` - Renamed `x` to `userCount`
3. `src/api/handler.ts:67-72` - Added timeout error handling

### Notes (No Action Taken)
1. `src/utils/validation.ts` - Validation logic could be extracted to shared module
   (Not fixing: would change public API, needs discussion)

### Verification
All checks passed.
```

## Key Principles

**Be Autonomous:** Don't ask permission for obvious fixes. The whole point is fresh eyes making judgment calls.

**Be Conservative:** When in doubt, note it instead of fixing it. Working code > perfect code.

**Verify Everything:** Run tests after each change. Stop if something breaks.

**Document Changes:** Log everything you do so the human can review your review.

## What NOT to Do

- Don't refactor working code just because you'd write it differently
- Don't add features or enhancements
- Don't change public APIs without flagging
- Don't "improve" test coverage beyond obvious gaps
- Don't fix style issues the linter doesn't catch (unless egregious)

## Integration with Ralph Loop

```
┌─────────────────────────────────────────┐
│ /implement_plan                         │
│    └─ Executes phases                   │
│    └─ Marks status: ready_for_review    │
├─────────────────────────────────────────┤
│ [New Ralph loop iteration]              │
├─────────────────────────────────────────┤
│ /review_plan                            │
│    └─ Fresh context review              │
│    └─ Autonomous fixes                  │
│    └─ Marks status: completed           │
└─────────────────────────────────────────┘
```
