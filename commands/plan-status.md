---
name: plan-status
description: Check status of implementation plans — open items, progress, closeable plans
argument-hint: "[plan-name-filter | close | purge]"
---

# Plan Status

Show status of implementation plans across both locations.

## Instructions

### 1. Scan both plan locations

- **Project plans**: `docs/plans/*.md` (skip `done/` subdirectory)

### 2. Handle arguments

- **No argument**: show all plans from both locations
- **`$ARGUMENTS` is a string**: filter to plans whose filename contains that string (case-insensitive, matches against slug portion). If no match, list available filenames.
- **`$ARGUMENTS` is "close"**: archive all fully-complete project plans (see step 6)

### 3. Parse each plan

Count checklist items: `- [ ]` (open) and `- [x]` (done). If the file has an `## Execution Log` section, extract the latest `**Status**:` value.

### 4. Report format

Group by location. For each plan show one line:

```
filename.md  [=====>    ] 5/10 (50%)  [status: in_progress]
  - Open item 1 text
  - Open item 2 text
```

- Progress bar is 20 chars wide
- Only show the `[status: ...]` tag if an execution log status exists
- Only list open items if there are 8 or fewer. Otherwise just show the count.
- For internal plans (auto-generated names), also show the first `# heading` from the file as context since the filenames are meaningless.

### 5. Identify closeable/purgeable plans

At the end, under a **Closeable** heading, list:
- Fully-complete project plans: suggest `say "close" to git mv these to docs/plans/done/`
- Fully-complete internal plans: suggest `say "purge" to delete these`

### 6. Close action

When `$ARGUMENTS` is "close": `mkdir -p docs/plans/done && git mv docs/plans/<file> docs/plans/done/<file>` for each fully-complete project plan. Confirm what was moved.

### 8. Summary line

```
Project: N active, M open items | Internal: N active, M open items
```
