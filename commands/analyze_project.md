---
description: Reconnaissance and documentation of project tooling, CI/CD, and conventions
---

# Analyze Project

Research this codebase and produce structured findings for Ralph configuration.

## Instructions

Thoroughly analyze the current project and document findings in `docs/project-analysis.md`.

### Detection Checklist

Work through each category systematically:

**1. Tech Stack**

Use the **stack-detection** skill (`skills/stack-detection/SKILL.md`) for comprehensive detection of:
- Package managers and project files
- Build systems and commands
- Test frameworks
- Code quality tools (linters, formatters, type checkers)
- Pre-commit hooks

The skill provides detection patterns for all major languages and frameworks.

**2. Container Environment**
- Look for: Dockerfile, docker-compose.yml, .devcontainer/,
- Search test files for testcontainers usage
- Check for nix flakes, Vagrant, etc.

**3. Task Tracking**
- Read .claude/settings.json for MCP server configurations (Linear, Jira, etc.)
- Look for .github/ISSUE_TEMPLATE/
- Search docs for references to Jira, Linear, Azure DevOps, etc.

**4. CI/CD**
- Check .github/workflows/, .gitlab-ci.yml, Jenkinsfile, etc.
- Identify what checks run and which are required

**5. Code Quality**

Covered by **stack-detection** skill. Ensure you capture:
- Linter and formatter configurations
- Pre-commit hook setup
- Type checking configuration

**6. Project Structure**
- Detect monorepo patterns (workspaces, packages/, services/)
- Map service boundaries

**7. Git Workflow**
- Analyze recent commit messages for patterns
- Check for PR templates
- Look for branch protection documentation

### Output

Create `docs/project-analysis.md` following the format in docs/SPEC.md.

List "Open Questions" for anything that couldn't be determined automatically - these will be asked during bootstrap.

### Important

- Only read and analyze, never modify project files
- Be thorough - missed detection leads to poor bootstrap configuration
- Note confidence level when uncertain about findings
