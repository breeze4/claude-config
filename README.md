# Personal Claude Code Config

My personal Claude Code configuration. Work in progress, rough around the edges.

## Structure

- `CLAUDE.md` - Global instructions
- `agents/` - Custom agent definitions
- `commands/` - Slash commands
- `docs/` - Specs and plans
- `hooks/` - Event hooks
- `plugins/` - Plugins
- `skills/` - Skills (see below)
- `templates/` - Templates for new projects

## Skills

The core pipeline for turning ideas into implemented code:

- **`/grill-me`** — Interviews you about a feature until reaching shared understanding, then produces a structured spec (full PRD or lightweight). The entry point for most new work.
- **`/research`** — Maps a spec to concrete files in the codebase, surfacing patterns, conventions, and unresolved judgment calls. Also works standalone to investigate how something works. Produces a research artifact that makes downstream planning significantly better.
- **`/spec-to-plans`** — Breaks a spec into vertical-slice implementation plans (tracer bullets), each with ownership boundaries, pattern exemplars, and acceptance criteria.
- **`/plans-to-prompt`** — Generates an orchestration prompt that executes plans via parallel/serial agents with build and test gates.
- **`/improve-codebase-architecture`** — Explores a codebase for architectural friction, designs multiple competing interfaces via parallel agents, and outputs a spec for the chosen refactor.

Supporting skills:

- **`/agent-browser`** — Browser automation for web testing, form filling, and screenshot capture via snapshots and element refs.
- **`/excalidraw`** — Generates editable Excalidraw diagram files as JSON.
