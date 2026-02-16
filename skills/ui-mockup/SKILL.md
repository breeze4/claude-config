---
name: ui-mockup
description: Build or update a UI mockup from a project spec. Use when asked to create a mockup, update a mockup, or regenerate UI from a spec.
user_invocable: true
---

# UI Mockup Builder

Build a complete, functional UI mockup from a project specification.

## Workflow

### 1. Find the spec

Look for `docs/SPEC.md` in the project root. If not found, ask the user where the spec is. Read it thoroughly — it is the single source of truth for what to build.

### 2. Determine mode

Check the user's request and existing files:

**Update mode** (default if mockup exists):
- Look for an existing `mockup/` directory in the project root
- Read the existing mockup code to understand current state
- Diff the spec against what's already built — identify new, changed, or removed features
- Apply changes incrementally to the existing mockup

**New version mode** (if user says "new mockup", "fresh", "from scratch", or "new version"):
- Find the highest existing version: `mockup/` (v1), `ui-mockup-v2/`, `ui-mockup-v3/`, etc.
- Copy the previous version to the next version directory (e.g., `ui-mockup-v2/`)
- Apply all spec changes to the new version
- Leave the previous version untouched

**First mockup** (no existing mockup directory):
- Scaffold a new React + Vite project in `mockup/`
- Build everything from scratch based on the spec

### 3. Build

Tech stack: React + TypeScript, shadcn/ui, Tailwind CSS, Recharts (if needed).

Design principles:
- Clean, minimal, dark-friendly color palette
- Muted, professional colors — finance app aesthetic
- `$X,XXX.XX` format for all monetary values
- Alternating row backgrounds on tables
- Tooltips on all chart hover states
- Responsive: sidebar collapses on mobile, tables become cards on small screens
- No auth UI — local single-user app

Layout pattern:
- Fixed left sidebar with icon+label nav for each tab in the spec
- Active tab highlighted, sidebar collapses to icons on narrow screens
- Top bar: current tab name, global date range picker, account filter dropdown

Implementation:
- Every feature, view, and interaction in the spec gets a UI representation
- Interactive chart filtering: clicking chart segments filters data on the same page
- Inline editing (dropdowns, number inputs) should be functional
- Mock data should look realistic — real vendor names, realistic amounts, proper date ranges
- Enough mock data volume to test pagination and chart rendering

### 4. Verify

After building, run the dev server and confirm it compiles without errors. Report what was built/changed.
