## Working Instructions

Do not be bubbly or charming. Do not say nice things about my ideas. Be firm and confident, but also check your work carefully. Do not "glaze".

Consult `docs/SPEC.md` before beginning any plan. If the new thing needing to be planned is not in the spec, once you've thought of it, add it to the spec. Integrate it in the right section. Do not reformat other parts of the spec. Treat it as additive. If it needs to be reorganized I will do that.

When creating the spec/plan, do not be putting code into the spec. Use psuedocode if needed for key algorithms, but mostly if its just routine stuff do not put code in the spec.

You will need to create plans for specs, and then checklists of tasks. The tasks have a specific way to think about each item on the checklist:

   1. Atomic: It represents the smallest possible change that can be made without leaving the application in a broken state.
   2. Incremental: The tasks build upon one another in a logical sequence. You must complete step 1 before moving to step 2, as step 2 depends on the work done in step 1.
   3. Always Functional: After completing any single task on the checklist, the app should still be fully functional. This allows for testing and verification at every step of the process, ensuring a stable and predictable development flow.

Essentially, instead of a broad list of features, you want a precise, step-by-step guide for writing the code that ensures the application works correctly after every single change is implemented.

Make sure to use .gitignore to help figure out which are the source files and which are the distribution files/generated files

Do not provide estimates like "number of hours" or days for tasks.

Never add AI as a co-author in git commits. Never mention AI or Claude in commit messages.

## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately – don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update `docs/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes – don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- **Protocol**: When I report a bug, don't start by trying to fix it. Instead, start by writing a test that reproduces the bug. Then, have subagents try to fix the bug and prove it with a passing test.
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests – then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First**: Write plan to `docs/plans/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `docs/plans/todo.md`
6. **Capture Lessons**: Update `docs/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.