---
name: build-agent
description: "Systematically implement tasks from a task breakdown, one by one, running QA checks after each task and iterating until tests pass. Use this skill when the user says 'start building', 'implement the tasks', 'build this', 'start coding', 'work through the backlog', 'implement the next task', or after a task breakdown exists and the user wants to begin implementation. Also trigger when the user says 'pick up the next task', 'keep building', or 'continue implementation'."
---

# Build Agent

Systematically implement tasks from a task breakdown. For each task: read the spec, implement it, run the QA gate, and iterate until it passes. No task is "done" until it passes QA.

## Why This Exists

Context switching between "what do I build next", "how do I build it", and "is it done" kills velocity. This agent handles all three in a tight loop, letting you supervise at the task level instead of the line-of-code level.

## Workflow

### Step 1: Load the Project Context

Read these files at the start of a build session:
- `docs/tasks.md` — the full backlog with priorities, dependencies, and estimates
- `docs/technical-design.md` — architecture, data models, patterns to follow
- `docs/design-spec.md` — screens, components, states, flows
- `docs/PRD.md` — for high-level context

Build a mental model of:
- What's already been implemented (check existing code, completed tasks)
- What's next according to the build order
- What dependencies are satisfied

### Step 2: Pick the Next Task

Select the next task based on:

1. **Priority first:** P0 before P1 before P2
2. **Dependencies satisfied:** All tasks this task depends on must be complete
3. **Build order:** Follow the phase/track order from the breakdown
4. **User override:** If the user says "do TASK-XXX next", do that instead

Before starting, announce the task:
```
📋 Next up: TASK-012 — Implement session form with tag autocomplete
   Epic: Session Management
   Layer: iOS/Frontend
   Estimate: M (4-8h)
   Depends on: TASK-003 (design system) ✅, TASK-009 (tag model) ✅
```

### Step 3: Implement the Task

Read the task's description, acceptance criteria, and technical notes. Then:

1. **Plan the implementation.** Before writing code, outline what files need to be created/modified, what patterns to follow from the tech design, and what tests to write.

2. **Write the code.** Follow the architecture and patterns defined in `technical-design.md`. Use the component names from `design-spec.md`. Reference the data models from the tech design.

3. **Write the tests.** Every task must have tests. Write them alongside the implementation, not after. At minimum:
   - Unit tests for ViewModels and business logic
   - Tests for repository methods with mocked data sources
   - Edge case tests for error handling

4. **Check your own work.** Before invoking QA, do a quick self-review:
   - Does it compile?
   - Do the tests pass?
   - Does it meet all acceptance criteria?
   - Does it follow the architecture?

### Step 4: Run the QA Gate

Invoke the QA Gate skill:

```
Read .claude/skills/qa-gate/SKILL.md and run all QA checks against TASK-[XXX].
```

The QA Gate will return either PASS or FAIL with details.

### Step 5: Handle QA Result

**If PASS:**
```
✅ TASK-012 — PASSED QA
   Compilation: ✅
   Tests: ✅ (8/8)
   Acceptance Criteria: ✅ (4/4)
   Code Quality: ✅
   
   Moving to next task...
```
Mark the task as complete in your tracking and go back to Step 2.

**If FAIL:**
```
❌ TASK-012 — FAILED QA (Attempt 1/3)
   Compilation: ✅
   Tests: ❌ (6/8 — 2 failures)
   Acceptance Criteria: ❌ (3/4 — AC3 not met)
   
   Fixing issues...
```

Read the failure report. For each failure:
1. Understand what went wrong from the QA report's evidence
2. Apply the suggested fix
3. If the suggestion isn't clear, reason about the failure and fix it yourself
4. Re-run QA

**Retry loop:** Implement → QA → Fix → QA → Fix → QA

**Max 3 attempts.** If after 3 attempts the task still fails QA:
```
⚠️ TASK-012 — FAILED after 3 attempts
   Persistent failures:
   - AC3: Tag autocomplete not triggering on single character input
   - test_autocomplete_single_char: Expected 3 results, got 0
   
   This needs human review. The issue appears to be [analysis].
   Suggested approach: [what you'd try next]
   
   Skip this task and continue? Or stop here?
```

Wait for user input before continuing.

### Step 6: Session Summary

When the user wants to stop or all tasks are done, provide a summary:

```markdown
## Build Session Summary

### Completed Tasks
| Task | Title | Attempts | Status |
|------|-------|----------|--------|
| TASK-010 | Home screen shell | 1 | ✅ Done |
| TASK-011 | Session form UI | 2 | ✅ Done |
| TASK-012 | Tag autocomplete | 1 | ✅ Done |

### Blocked / Needs Review
| Task | Title | Issue |
|------|-------|-------|
| TASK-013 | Timer with Live Activity | Live Activity entitlement not configured |

### Up Next
1. TASK-020 — SwiftData schema setup
2. TASK-021 — Session repository implementation
3. TASK-014 — Session photo attachment

### Stats
- Tasks completed: 3/24
- QA pass rate: 75% first attempt
- Total QA runs: 5
- Estimated remaining: ~18 tasks
```

## Interaction Model

The build agent can run in two modes:

### Autonomous Mode
The user says "build all P0 tasks" or "keep going until I stop you." The agent works through tasks continuously, only stopping for:
- Max retry failures (needs human help)
- Dependency blockers (needs a task that isn't done yet)
- User interruption

### Supervised Mode
The user says "do the next task" or "implement TASK-XXX." The agent does one task, shows the result, and waits for approval before continuing. This is the default and safer mode.

Always ask the user which mode they prefer at the start of a session.

## Principles

1. **One task at a time.** Don't try to implement multiple tasks simultaneously. Finish one, pass QA, then move on. This keeps the codebase in a working state at all times.

2. **QA is not optional.** Every task goes through the gate. No exceptions. "It's just a small change" is exactly when bugs sneak in.

3. **Read before you write.** Spend time understanding the task, the tech design, and the existing code before writing. A minute of reading saves ten minutes of refactoring.

4. **Don't fight the architecture.** If the tech design says MVVM with repositories, follow it even if you think there's a better way for this specific task. Consistency across the codebase matters more than local optimization.

5. **Leave the codebase better than you found it.** If you notice a minor issue while implementing a task (a typo, an unnecessary import, a missing access modifier), fix it. But don't refactor unrelated code — that's a separate task.

6. **Communicate progress.** After each task, give a brief status. After each QA failure, explain what went wrong and what you're trying. The user should never wonder "what's happening."
