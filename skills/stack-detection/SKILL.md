---
name: stack-detection
description: Detect project tech stack, build tools, test frameworks, CI/CD, and code quality tools. Use when you need to know how to build, test, lint, or run a project.
allowed-tools: Read, Grep, Glob, LS
---

# Stack Detection Skill

Systematically detect and report project tooling so other commands know how to build, test, and verify code.

## When to Use

- Before running tests (need to know the test command)
- Before running builds (need to know the build command)
- Before linting/formatting (need to know the lint command)
- When `/analyze_project` runs
- When `/implement_plan` needs verification commands

## Detection Process

### 1. Package/Project Files

Check for these in order of priority:

| File | Stack | Package Manager |
|------|-------|-----------------|
| `package.json` | Node/JS/TS | npm/yarn/pnpm/bun |
| `Cargo.toml` | Rust | cargo |
| `go.mod` | Go | go |
| `pyproject.toml` | Python | pip/poetry/uv |
| `requirements.txt` | Python | pip |
| `Gemfile` | Ruby | bundler |
| `build.gradle` / `pom.xml` | Java/Kotlin | gradle/maven |
| `composer.json` | PHP | composer |
| `mix.exs` | Elixir | mix |

### 2. Build System

Check for:
- `Makefile` → `make` commands (read targets)
- `justfile` → `just` commands
- `package.json` scripts → `npm run <script>`
- `Taskfile.yml` → `task` commands
- Framework CLIs (next, vite, cargo, etc.)

**Priority:** Makefile > justfile > package.json scripts > framework defaults

### 3. Test Framework

| Stack | Common Frameworks | Detection |
|-------|-------------------|-----------|
| JS/TS | jest, vitest, mocha, playwright | package.json devDeps |
| Python | pytest, unittest | pyproject.toml, test files |
| Rust | built-in | `#[test]` in source |
| Go | built-in | `_test.go` files |
| Ruby | rspec, minitest | Gemfile, spec/ directory |

### 4. Code Quality Tools

**Linters:**
- `.eslintrc*` → eslint
- `ruff.toml` / `pyproject.toml [tool.ruff]` → ruff
- `.golangci.yml` → golangci-lint
- `clippy` (Rust, via cargo)

**Formatters:**
- `.prettierrc*` → prettier
- `pyproject.toml [tool.black]` → black
- `rustfmt.toml` → rustfmt
- `gofmt` (Go, built-in)

**Type Checking:**
- `tsconfig.json` → tsc
- `mypy.ini` / `pyproject.toml [tool.mypy]` → mypy
- `pyrightconfig.json` → pyright

### 5. Pre-commit Hooks

- `.husky/` → husky (JS)
- `.pre-commit-config.yaml` → pre-commit
- `.git/hooks/` → custom hooks

### 6. CI/CD

- `.github/workflows/` → GitHub Actions
- `.gitlab-ci.yml` → GitLab CI
- `Jenkinsfile` → Jenkins
- `.circleci/` → CircleCI
- `azure-pipelines.yml` → Azure DevOps

**Extract from CI:** What commands CI runs are often the canonical verification commands.

## Output Format

When invoked, return structured detection results:

```
## Stack Detection Results

**Language:** TypeScript
**Framework:** Next.js 14
**Package Manager:** pnpm

### Commands
| Action | Command |
|--------|---------|
| Install | `pnpm install` |
| Build | `pnpm build` or `make build` |
| Test | `pnpm test` or `make test` |
| Lint | `pnpm lint` or `make lint` |
| Type Check | `pnpm typecheck` |
| Format | `pnpm format` |
| All Checks | `make check` (runs lint + typecheck + test) |

### Code Quality
- **Linter:** ESLint (`.eslintrc.json`)
- **Formatter:** Prettier (`.prettierrc`)
- **Type Checker:** TypeScript (`tsconfig.json`)
- **Pre-commit:** Husky (`.husky/`)

### CI/CD
- **Platform:** GitHub Actions
- **Workflows:** `ci.yml` (test, lint, build)
- **Required Checks:** test, lint, typecheck
```

## Usage by Other Commands

Other commands can invoke this skill to get verification commands:

```
I need to run tests. Let me check the stack detection skill...

Stack detection found:
- Test command: `make test` (preferred) or `pnpm test`
- The project uses jest with TypeScript

Running: make test
```

## Important Notes

- Prefer Makefile/justfile targets over direct tool invocation (they often set up environment)
- Check CI config for the "canonical" commands the project actually uses
- Some projects have multiple valid commands - prefer the one CI uses
- Always verify detected commands exist before recommending them
