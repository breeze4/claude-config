---
name: session-recovery
description: Enable session continuity for long-running tasks through execution logs. Use when implementing multi-phase work that may be interrupted.
allowed-tools: Read, Edit, Write
---

# Session Recovery Skill

Maintain execution logs that enable resuming work after interruption, context loss, or session boundaries.

## When to Use

- Multi-phase implementations (`/implement_plan`)
- Long-running tasks that might be interrupted
- Any workflow where "pick up where I left off" matters
- Work that spans multiple Ralph loop iterations

## Execution Log Format

Add this section to any plan or task document:

```markdown
## Execution Log

Append entries here during implementation to track progress and enable session recovery.

### Session: YYYY-MM-DD HH:MM
**Status**: not_started | in_progress | paused | blocked | completed
**Phase**: N
**Last Completed Task**: Task description or "none"

#### Actions Taken
- [HH:MM] Started Phase N
- [HH:MM] Completed Task 1: [brief description]
- [HH:MM] ISSUE: [description of problem]
- [HH:MM] Paused for manual verification

#### Notes
[Context needed for resumption - what was I thinking, what's next, any gotchas]
```

## Session States

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `not_started` | Fresh plan, no work done | Begin Phase 1 |
| `in_progress` | Actively working | Continue current task |
| `paused` | Stopped cleanly (verification, EOD) | Resume from last task |
| `blocked` | Cannot proceed without input | Address blocker first |
| `completed` | All phases done | No action needed |

## Recovery Process

### On Session Start

1. **Read the execution log** to determine state
2. **Report status** to user:
   ```
   Execution Log Status:
   - Last Session: 2026-01-16 14:30
   - Status: paused
   - Phase: 2
   - Last Completed: Task 3 (Add validation to form handler)

   Resuming from Phase 2, Task 4...
   ```
3. **Start new session entry** with current timestamp
4. **Resume** from the recorded position

### If No Log Exists

```
No previous execution log found. Starting fresh.
```

Create initial session entry with `not_started` status.

## Logging During Work

### After Each Task

1. Check off task in plan: `- [x] **Task N**: ...`
2. Append to log: `- [HH:MM] Completed Task N: [brief description]`

### On Issues

```markdown
- [HH:MM] ISSUE: Test failing - UserService mock not updated
- [HH:MM] Investigating issue...
- [HH:MM] Resolved: Updated mock in tests/mocks/user.ts
```

Update status to `blocked` if you can't resolve it.

### On Pause

```markdown
- [HH:MM] Paused for manual verification

#### Notes
Phase 2 automated checks passed. Waiting for user to test form submission flow.
Next: After confirmation, proceed to Phase 3 Task 1.
```

### On Completion

```markdown
- [HH:MM] Phase N complete, all verification passed
- [HH:MM] Implementation complete

#### Notes
All phases done. Ready for final review.
```

Update status to `completed`.

## Example Full Log

```markdown
## Execution Log

### Session: 2026-01-16 10:00
**Status**: completed
**Phase**: 1
**Last Completed Task**: Task 3 (Add type definitions)

#### Actions Taken
- [10:00] Started Phase 1
- [10:15] Completed Task 1: Created schema file
- [10:25] Completed Task 2: Added validation logic
- [10:35] Completed Task 3: Added type definitions
- [10:40] Phase 1 verification passed
- [10:45] Paused for manual verification

#### Notes
Phase 1 complete. User needs to verify form renders correctly.

---

### Session: 2026-01-16 14:00
**Status**: paused
**Phase**: 2
**Last Completed Task**: Task 2 (Update API handler)

#### Actions Taken
- [14:00] Resumed after manual verification approval
- [14:05] Started Phase 2
- [14:20] Completed Task 1: Added endpoint route
- [14:35] Completed Task 2: Updated API handler
- [14:40] ISSUE: Integration test timeout
- [14:50] Resolved: Increased test timeout, added retry logic
- [14:55] Paused - end of session

#### Notes
Phase 2 in progress. Next: Task 3 (Add error handling).
Integration tests are slow - may need to look at test containers.
```

## Integration with Commands

### /implement_plan

Already uses this pattern. The execution log is part of the plan template.

### Other Long-Running Commands

Any command that might be interrupted can adopt this pattern:

1. Add `## Execution Log` section to output document
2. Log actions as you work
3. Check for existing log on startup
4. Resume from recorded state

## Best Practices

- **Log immediately** after completing each task (don't batch)
- **Be specific** in task descriptions (future you needs context)
- **Note blockers** clearly with what's needed to unblock
- **Add notes** at pause points - what were you thinking?
- **Keep status accurate** - update it when state changes
