---
description: Execute an implementation plan phase by phase with verification
---

# Implement Plan

Execute an approved implementation plan from `docs/plans/`.

## Getting Started

When given a plan path:
- Read the plan completely
- Read all files mentioned in the plan
- **Read files fully** — never use limit/offset, you need complete context
- Check for existing checkmarks (`- [x]`) to find where to resume
- Start implementing from the first unchecked item

If no plan path provided, ask for one.

## Execution

### For each phase:

1. **Implement tasks** one at a time, top to bottom
2. **Check off each task** in the plan file as you complete it
3. **After all tasks in a phase**, run the phase's verification steps
4. **Check off verification items** as they pass
5. **Fix any failures** before proceeding
6. **Pause for manual verification** if the phase has manual checks:
   ```
   Phase [N] Complete — Ready for Manual Verification

   Automated verification passed:
   - [List checks that passed]

   Please perform the manual verification steps:
   - [List manual items from plan]

   Let me know when manual testing is complete.
   ```
7. **Proceed to next phase** after confirmation (or immediately if no manual checks)

If instructed to execute multiple phases consecutively, skip the pause until the last phase.

### Resuming Work

If the plan has existing checkmarks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off

## When Things Don't Match

Plans describe expected state. Reality can diverge. When it does:

```
Issue in Phase [N], Task [M]:
Expected: [what plan says]
Found: [actual situation]
Why this matters: [explanation]

How should I proceed?
```

STOP and wait for guidance. Don't guess.

## Principles

- **Follow the plan's intent** while adapting to what you find
- **Each phase must leave the app working** — never commit broken state
- **Checkboxes are the source of truth** for progress
- **Use sub-agents sparingly** — mainly for debugging or exploring unfamiliar territory
- **Never check off manual verification items** until confirmed by the user
