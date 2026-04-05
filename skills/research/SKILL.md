---
name: research
description: Research a codebase topic or map a spec to concrete files, producing a structured research artifact. Use when the user wants to understand how something works, map a spec to code, investigate a concept, or produce a research doc. Works standalone or as input to spec-to-plans.
---

## 0. Determine research mode

| Signal | Mode |
|---|---|
| User provides a spec file or references one | **Spec-driven** — map every requirement to concrete files |
| User asks a question, names a concept, or points at code | **Exploratory** — document what exists |

Both modes produce the same artifact format. Spec-driven mode populates the File Map and Judgment Calls sections more aggressively. Exploratory mode may leave them sparse or empty.

Tell the user which mode you're using. They can override.

## 1. Read input first

- If a spec file is provided, read it FULLY before doing anything else
- If specific files are mentioned, read them FULLY
- If a concept is named, hold it — sub-agents will locate it

You need complete context before decomposing the research.

## 2. Decompose into research areas

Break the input into parallel-safe research questions. Think about:

- Which modules/layers/concepts need investigation?
- What are the boundaries between areas? (avoid duplicate work across agents)
- What would an implementer need to know that isn't obvious from reading one file?

For spec-driven research, derive areas from the spec's requirements — each major requirement or module boundary is a research area.

## 3. Spawn parallel sub-agents

Use the Agent tool to research areas concurrently. Use the right agent type for the job:

| Need | Agent type |
|---|---|
| Find WHERE files and components live | `codebase-locator` |
| Understand HOW specific code works | `codebase-analyzer` |
| Find existing patterns to follow | `codebase-pattern-finder` |
| Broader exploration of unfamiliar areas | `Explore` |
| External docs, library compatibility | `web-search-researcher` |

Rules for sub-agent prompts:

- Tell each agent exactly what you're looking for, not how to search
- Each agent gets a focused, non-overlapping slice of the research
- All agents are documentarians — describe what exists, don't critique or suggest improvements
- For spec-driven research, tell agents which spec requirements they're investigating

## 4. Synthesize findings

Wait for ALL sub-agents to complete before proceeding.

- Cross-reference findings across agents — where do they connect?
- For spec-driven research: map each spec requirement to the concrete files/functions that implement or need to implement it
- Identify gaps: things the spec requires that don't exist yet
- Identify conflicts: things in the code that contradict the spec, or third-party constraints that make a requirement difficult
- Surface judgment calls: decisions that can't be made by reading code alone

## 5. Write the research artifact

Output to `docs/research/YYYY-MM-DD-NN-slug.md`. Check existing files to determine the next NN. Create the `docs/research/` directory if needed.

Use this format:

```markdown
# Research: <Topic or Spec Name>

**Date**: YYYY-MM-DD
**Source**: <spec file path, or "exploratory">
**Status**: complete | partial (if areas remain uninvestigated)

## Summary

2-3 paragraphs answering the research question or summarizing how the spec maps to the codebase. Lead with the answer, not the process.

## File Map

Files organized by module/area. For each file, document what's there and what would need to change (if spec-driven).

### <Module/Area Name>

| File | Current State | Spec Requirement | Change Needed |
|---|---|---|---|
| `path/to/file.ts:45-80` | `functionName` handles X | Requirement N | Modify to support Y |
| `path/to/other.ts` | Does not exist | Requirement M | Create new |

For exploratory research, omit the Spec Requirement and Change Needed columns — just document File and Current State.

### <Next Module/Area>

...

## Dependencies & Compatibility

Third-party libraries, framework versions, or external services relevant to this research.

| Dependency | Current Version | Constraint | Notes |
|---|---|---|---|
| `library-name` | 2.3.1 | Spec requires feature added in 3.0 | Upgrade needed |

Omit this section if no dependency findings.

## Judgment Calls

Decisions that require human input — incompatibilities, ambiguities, or tradeoffs where the code doesn't dictate an answer.

- [ ] **<Short description>**: <Context and options>
  - Option A: <description> — <tradeoff>
  - Option B: <description> — <tradeoff>
  - Resolution: <blank until resolved>

Each judgment call is a checkbox. Downstream skills (spec-to-plans, plans-to-prompt) check for unresolved items and surface them.

Omit this section if no judgment calls.

## Patterns & Conventions

Existing patterns an implementer should follow. These feed directly into spec-to-plans "Pattern exemplar" fields.

- **<Pattern name>**: `path/to/exemplar.ts` — <what to match and why>

Omit this section for exploratory research unless patterns are central to the question.

## Open Questions

Things that couldn't be determined from the code and aren't judgment calls (they're investigable, just not yet investigated).

- <Question> — <what would answer it>

Omit if none.
```

## 6. Present to user

Summarize key findings concisely. Highlight:

- For spec-driven: how many files mapped, any judgment calls that need resolution, any gaps
- For exploratory: the answer to their question, with file references

Ask if they want to go deeper on any area or if judgment calls need resolution now.

## Key constraints

- **Document what IS, not what SHOULD BE.** The File Map describes current state. The "Change Needed" column is derived from the spec, not from your opinion.
- **Fail loudly.** If a critical code path can't be located, say so explicitly — don't paper over it.
- **Line numbers matter.** Include them where possible. An implementer should be able to jump directly to the relevant code.
- **No code in the artifact.** Reference files and line numbers. Don't paste implementation snippets unless they're short and essential to understanding a pattern.
- **Judgment calls are structured data.** Use the checkbox format. Downstream skills parse these.
