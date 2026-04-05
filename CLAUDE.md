# Working Instructions

## Approach
- Think before acting. Read existing files before writing code.
- Be concise in output but thorough in reasoning.
- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Test your code before declaring done.
- No sycophantic openers or closing fluff.
- Keep solutions simple and direct. No over-engineering.
- If unsure: say so. Never guess or invent file paths.
- User instructions always override this file.

## Efficiency
- Read before writing. Understand the problem before coding.
- No redundant file reads. Read each file once.
- One focused coding pass. Avoid write-delete-rewrite cycles.
- Test once, fix if needed, verify once. No unnecessary iterations.
- Budget: 50 tool calls maximum. Work efficiently.


Do not be bubbly or charming. Do not say nice things about my ideas. Be firm and confident, but also check your work carefully. Do not "glaze".

Consult `docs/specs/02-app-spec.md` before beginning any plan. If the new thing needing to be planned is not in the spec, once you've thought of it, add it to the spec. Integrate it in the right section. Do not reformat other parts of the spec. Treat it as additive. If it needs to be reorganized I will do that.

All pipeline artifacts (specs, research, plans, prompts) use a consistent naming convention:
`YYYY-MM-DD-NN-slug.md` where NN is a zero-padded sequence number within that directory.
Examples: `docs/specs/2026-04-04-01-per-section-meters.md`, `docs/plans/2026-04-04-03-auth-flow.md`.
Check existing files to determine the next NN.

When creating the spec/plan, do not be putting code into the spec. Use psuedocode if needed for key algorithms, but mostly if its just routine stuff do not put code in the spec.

Make sure to use .gitignore to help figure out which are the source files and which are the distribution files/generated files

Do not provide estimates like "number of hours" or days for tasks.

Never add AI as a co-author in git commits. Never mention AI or Claude in commit messages.

## Task Management

1. **Plan First**: Write plan to `docs/plans/YYYY-MM-DD-NN-slug.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to the plan file
6. **Capture Lessons**: Update `docs/lessons.md` after corrections

## Agent Browser

- Save all agent-browser screenshots to `screenshots/` in the project directory, not `/tmp/`.

## Android Development

See [ANDROID.md](./ANDROID.md) for WSL2 + Windows Android development setup (emulator, ADB, networking, port forwarding).
