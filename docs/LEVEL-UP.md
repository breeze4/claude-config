# Level Up Your Repo and Workflow

This doc describes enhancement patterns you can add to your Ralph-ified repo. These are ideas, not prescriptions - pick what fits your workflow and customize.

---

## Verification-First Task Design

**The idea:** Each task in a plan defines HOW to verify it's correct BEFORE defining the implementation. Forces test-driven thinking at planning time.

**Basic task structure:**
```markdown
- [ ] **Task 1**: Add user validation
  - File: `src/handlers/user.ts`
  - Change: Add email format validation
```

**Verification-first structure:**
```markdown
- [ ] **Task 1**: Add user validation
  - **Verify**: `npm test -- --grep "email validation"` passes; invalid emails rejected with 400
  - File: `src/handlers/user.ts`
  - Change: Add email format validation
```

**Why it helps:**
- Catches vague tasks early ("verify" forces you to be specific)
- Makes implementation success criteria concrete
- Natural TDD flow even when not writing tests first

**To implement:** Modify your `/create_plan` template to include Verify field for each task.

---

## Per-Task Verification During Execution

**The idea:** Run each task's verification immediately after implementing it, not just at phase end.

**Standard flow:**
```
implement task 1 → implement task 2 → implement task 3 → run tests
```

**Per-task flow:**
```
implement task 1 → verify task 1 → implement task 2 → verify task 2 → ...
```

**Why it helps:**
- Catch problems immediately, not after 5 more changes
- Easier to debug (you know exactly what broke)
- Prevents "it was working until I did something" confusion

**To implement:** Modify `/implement_plan` to run each task's Verify step before proceeding. Log verification results in execution log.

---

## Review/Refactor Pass (Separate Context) ✅ IMPLEMENTED

**Command:** `commands/review_plan.md`

After implementation completes, run a review and refactor pass in a fresh Ralph loop iteration (new context).

**Why separate context matters:**
- Implementation context is "too close" to code it just wrote
- Fresh eyes catch inconsistencies and unnecessary complexity
- Prevents implementation from creeping into refactoring mid-task

**The flow:**
```
/implement_plan → marks status: ready_for_review → new Ralph loop → /review_plan → marks status: completed
```

**Review categories (autonomous):**
- **Must fix:** Pattern violations, unnecessary complexity, missing error handling, debug code
- **Should fix:** Naming inconsistencies, readability issues, test gaps
- **Note only:** Style preferences, risky "improvements"

**Key principle:** Review is autonomous. It makes decisions and fixes issues without asking permission for each change. Only escalates if something is fundamentally broken.

---

## Deep Code Explanation ✅ IMPLEMENTED

**Command:** `commands/explain.md`

Lighter than full `/research_codebase`, focused on specific code:
1. Read the target file/function/module
2. Trace dependencies and callers
3. Explain what it does, why, and how it connects to the system
4. Include architectural context

**Use /explain for:** Specific file, single concept, quick understanding.
**Use /research_codebase for:** Broad questions, multi-component investigation, saved documentation.

---

## Additional Commands to Consider

### /debug - Structured Debugging

Systematic debugging workflow:
1. Reproduce the issue
2. Isolate the cause (binary search through code/commits)
3. Form hypothesis
4. Verify hypothesis
5. Implement fix
6. Verify fix doesn't break other things

**Value:** Especially useful when Ralph encounters test failures mid-implementation. Provides systematic approach instead of random fixes.

### /migrate - Version/Framework Migration

For upgrades and migrations:
1. Detect current versions (use stack-detection skill)
2. Research upgrade path and breaking changes
3. Create phased migration plan with rollback checkpoints
4. Execute with verification at each phase

**Value:** Framework upgrades are risky. Phased approach with rollback points makes them safer for autonomous execution.

### /generate-tests - Test Generation

Analyze code and generate tests following project conventions:
1. Find existing test patterns with codebase-pattern-finder
2. Identify untested code paths
3. Generate tests matching project style
4. Verify tests actually test meaningful behavior

**Value:** Increasing test coverage before refactoring. Also useful when implementing features that need tests but the plan didn't specify them.

### /refactor - Safe Refactoring

Refactoring with automatic verification:
1. Identify refactoring target
2. Ensure test coverage exists (or add it first)
3. Make atomic refactoring changes
4. Verify after each change
5. Stop immediately if tests fail

**Value:** Makes refactoring safer for autonomous execution. The "stop on red" behavior prevents cascading breakage.

---

## Extractable Patterns

Patterns embedded in core commands that could be extracted as reusable skills.

### Stack Detection Pattern ✅ IMPLEMENTED

**Skill:** `skills/stack-detection/SKILL.md`

Systematic detection of build tools, test frameworks, CI/CD systems, code quality tools, and container environments. Any command can invoke this to know how to build/test/lint.

### Session Recovery Pattern ✅ IMPLEMENTED

**Skill:** `skills/session-recovery/SKILL.md`

Execution log pattern that enables resuming from exact point after context loss. Any long-running command can adopt this pattern.

### Parallel Research Pattern

From `/create_plan` and `/research_codebase` - the pattern of:
1. Decompose question into independent sub-questions
2. Spawn research agents concurrently
3. Wait for all to complete
4. Synthesize findings

**Status:** Not extracted. The orchestration strategy varies enough by use case that a generic skill may not help. Consider extracting if you find yourself duplicating this logic.

---

## How to Customize

1. **Pick patterns that match your pain points** - Don't add everything
2. **Start with one enhancement** - Get it working before adding more
3. **Modify templates to fit your conventions** - These are starting points
4. **Add project-specific verification** - Your tests, your linters, your checks

The goal is a workflow that fits YOUR repo, not a generic "best practices" system.

---

## Agentic Pattern Opportunities

Potential enhancements to the agent architecture identified during pattern review.

### Additional Specialized Agents

**Test Analysis Agent**
An agent specialized in understanding test architecture:
- Map test files to source files
- Analyze test coverage gaps
- Identify untested code paths
- Distinguish unit vs integration vs e2e patterns

Useful when `/create_plan` involves test work or when assessing test health.

**Git History Research Agent**
Understanding WHY code exists, not just WHAT it does:
- Git blame analysis
- Related commit discovery
- Change frequency patterns (hot spots)
- Author expertise mapping

Helps provide context for changes and identify code ownership.

**Security-Focused Agent**
Specializes in security pattern discovery:
- Auth/authz flow documentation
- Input validation approaches
- Security boundary identification
- Sensitive data flow mapping

Useful during planning for security-sensitive features.

**Dependency/Integration Agent**
Focuses on external code and services:
- External API integration patterns
- Third-party library usage patterns
- Service dependency mapping
- Configuration/secrets patterns

All current agents focus on first-party code.

**Diff/Change Analysis Agent**
Specialized in analyzing changes:
- Diff pattern recognition
- Before/after comparison
- High-risk change flagging
- Regression potential assessment

Would enhance `/review_plan` capabilities.

### Infrastructure Skills

**Verification Runner Skill**
`stack-detection` finds commands but doesn't run them. A skill that:
- Executes verification commands
- Interprets test output (pass/fail/flaky)
- Categorizes failures
- Returns structured results

Currently `/implement_plan` does this inline.

**Rollback/Recovery Skill**
Guidance for when implementation goes wrong:
- Git reset strategies
- Undo last phase patterns
- Safe revert approaches
- State recovery procedures

### Architectural Patterns

**Agent-to-Agent Orchestration**
Currently parent commands orchestrate all agents. Pattern for:
- Locator finding files → spawning analyzer on interesting findings
- Agents requesting help from sibling agents
- Reducing parent command complexity

**Graceful Agent Failure Pattern**
What should agents do when they find nothing?
- Structured "no results" output format
- Explanation of what was attempted
- Alternative search suggestions
- Confidence indicators

**Research Caching/Memory**
Cross-session knowledge retention:
- "I already researched where auth lives yesterday"
- Pattern for checking existing knowledge
- Cache invalidation strategies

### Integration Opportunities

**Beads Integration**
Connect Ralph workflow to beads task tracking:
- `/create_plan` could create a bead
- `/implement_plan` could update bead status
- Beads dependencies could inform plan sequencing
- Session recovery could sync with bead state

### Custom Extension Guidance

Document how to:
- Add project-specific agents
- Decide when to create vs extend
- Test agents before production use
- Version and maintain custom extensions
