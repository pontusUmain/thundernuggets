---
name: qa-gate
description: "Run quality assurance checks against implemented code. Operates in two modes: task-level QA (after each task) and feature-level QA (after all tasks in a feature are complete). Use this skill when the user says 'test this', 'QA this', 'check if this works', 'run the tests', 'validate this task', 'is this done', 'feature QA', 'e2e test', or when invoked automatically by the build agent."
---

# QA Gate

Validates implemented code at two levels: per-task (does this unit of work meet its spec) and per-feature (does the complete feature work end-to-end). Nothing ships without passing both gates.

## Two Modes

### Mode 1: Task QA
Runs after each individual task. Validates the task in isolation.
Invoked by: `/build` agent automatically, or `/qa TASK-XXX`

### Mode 2: Feature QA
Runs after ALL tasks in a feature are complete. Validates the entire feature end-to-end.
Invoked by: `/build` agent when last task passes, or `/qa feature [feature-name]`

---

## Mode 1: Task QA

### Check 1: Compilation
```bash
xcodebuild build \
  -scheme [scheme] \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet 2>&1
```

**Pass criteria:** Exit code 0, no errors.
**On failure:** Hard stop. Return compiler errors immediately.

Fall back to `swift build` if xcodebuild unavailable. If neither available, skip and note it.

### Check 2: Unit Tests
```bash
xcodebuild test \
  -scheme [scheme] \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:[TestTarget] \
  -quiet 2>&1
```

**Pass criteria:** All tests pass. Zero failures.
**On failure:** Collect failing test names, expected vs actual, assertion location.

### Check 3: Acceptance Criteria Verification

Read the task's acceptance criteria from the tasks file. For each criterion:

1. **If automatable** — write/run a test that verifies it, or confirm an existing test covers it
2. **If manual** — inspect the code and confirm implementation matches

Produce a checklist:
```markdown
- [x] AC1: [description] — PASS (verified by test_x)
- [x] AC2: [description] — PASS (code inspection: file:line)
- [ ] AC3: [description] — FAIL: [specific reason]
```

### Check 4: Code Quality

```bash
# SwiftLint if available
swiftlint lint --path [changed files] --reporter json 2>&1
```

If SwiftLint unavailable, check manually:
- No force unwraps in production code
- No print() statements (use proper logging)
- No TODO/FIXME without task ID
- No commented-out code blocks

**Pass criteria:** No errors. Warnings noted but don't block.

### Check 5: Architecture Compliance

Verify implementation follows the technical design:
- No layer violations (View accessing Repository directly, ViewModel importing SwiftUI)
- Naming matches design spec and tech design
- Dependency direction is correct (UI → Domain → Data)
- Protocol-based abstractions used, not concrete types

### Check 6: Test Coverage

For new code:
- ViewModels: unit tests for all public methods
- Repositories: tests with mocked data sources
- Utilities/Extensions: unit tests
- Views: snapshot tests for key states (if set up)

**Pass criteria:** New production code has corresponding tests.

### Task QA Output

```markdown
# Task QA Report: TASK-[XXX] — [Title]

## Result: PASS ✅ | FAIL ❌

| Check | Status | Details |
|-------|--------|---------|
| Compilation | ✅/❌ | [details] |
| Unit Tests | ✅/❌ | [X/Y passed] |
| Acceptance Criteria | ✅/❌ | [X/Y met] |
| Code Quality | ✅/❌ | [X errors, Y warnings] |
| Architecture | ✅/❌ | [details] |
| Test Coverage | ✅/❌ | [details] |

## Failures
[For each failure: what failed, evidence, fix suggestion]

## Warnings
[Non-blocking issues]
```

---

## Mode 2: Feature QA

Triggered when all tasks in a feature are complete. This validates what task QA cannot: that everything works together.

### Read the Feature Spec

Load `docs/features/[feature-name].md` and extract:
- Feature-level acceptance criteria (the end-to-end scenarios)
- All user stories and their acceptance criteria
- Integration points with existing code

### Check 1: Full Compilation

Clean build of the entire project:
```bash
xcodebuild clean build \
  -scheme [scheme] \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet 2>&1
```

Not just the new code — everything. Catches integration issues.

### Check 2: Full Test Suite

Run ALL tests, not just the new ones:
```bash
xcodebuild test \
  -scheme [scheme] \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet 2>&1
```

**Pass criteria:** Zero failures across the entire test suite. This catches regressions.

### Check 3: Feature-Level Acceptance Criteria

These are the end-to-end scenarios from the feature spec. For each one:

1. **Trace the complete flow** through the code — from user action to final state
2. **Verify integration points** — does the new code correctly call existing code and vice versa?
3. **Write an integration test** if one doesn't exist and the flow is automatable
4. **Check data flow** — does data persist correctly through the full create/read/update/delete cycle?
5. **Verify UI state transitions** — does the UI correctly reflect all state changes?

Produce a checklist:
```markdown
### Feature-Level Acceptance Criteria
- [x] E2E1: "User can complete full invite flow" — PASS
      Traced: SessionDetailView → InviteViewModel.send() → InviteRepository.create() → CloudKit → Push notification queued
      Integration test: test_full_invite_flow_e2e
- [ ] E2E2: "Push notification arrives within 60s" — FAIL
      Issue: NotificationService.schedule() is called but missing entitlement for push
      Fix: Add push notification entitlement to target capabilities
- [x] REG1: "Existing session CRUD still works" — PASS
      All existing session tests pass (14/14)
```

### Check 4: Regression Check

Specifically verify that existing functionality is not broken:
- Run all pre-existing tests
- Check that existing screens still render correctly
- Verify existing data models load without migration errors
- Confirm navigation to/from existing screens still works

### Check 5: Performance Spot Check

If the feature spec includes performance criteria:
- Measure the specific metrics mentioned (load time, response time, memory)
- Compare against targets in the spec
- Flag any degradation in existing performance

### Feature QA Output

```markdown
# Feature QA Report: [Feature Name]

## Result: PASS ✅ | FAIL ❌

## Summary
| Check | Status |
|-------|--------|
| Full Compilation | ✅/❌ |
| Full Test Suite | ✅/❌ (X/Y passed, Z regressions) |
| Feature Acceptance Criteria | ✅/❌ (X/Y met) |
| Regression Check | ✅/❌ |
| Performance | ✅/❌/⏭️ skipped |

## Feature Acceptance Criteria Detail
[Checklist with evidence for each criterion]

## Regressions Found
[Any existing tests that now fail, with analysis of why]

## Failures
[For each failure: what failed, evidence, fix suggestion]

## Sign-Off
[If PASS: "Feature [name] is complete and verified. All X tasks passed task QA, feature-level QA passed with Y/Y acceptance criteria met, zero regressions."]
[If FAIL: structured failure report with fix suggestions]
```

Save report to `docs/qa/[feature-name]-qa-report.md`.

---

## Failure Handling (Both Modes)

### Hard Failures (block immediately)
- Compilation errors
- Crashes in test suite
- Missing files referenced by the task/feature

### Soft Failures (collect all, then report)
- Test failures
- Acceptance criteria not met
- Missing test coverage
- Code quality violations
- Architecture violations
- Regressions

### Non-Blocking (report but don't fail)
- Warnings from compiler or linter
- TODOs with task IDs
- Minor style inconsistencies

## Max Retries

**Task QA:** 3 attempts, then escalate to user.
**Feature QA:** 2 attempts, then escalate to user. Feature QA failures are typically harder to fix automatically since they involve integration issues.

## Principles

1. **Be specific about failures.** "Test failed" is useless. "test_invite_send expected notification to be queued but NotificationService.pending was empty — InviteViewModel.send() doesn't call NotificationService.schedule()" is actionable.

2. **Feature QA catches what task QA can't.** Task QA verifies units. Feature QA verifies integration. A feature where every task passes QA can still fail feature QA if the pieces don't fit together.

3. **Regressions are the highest priority failure.** A new feature that breaks existing functionality is worse than a new feature that doesn't fully work yet. Always check regressions first.

4. **The feature acceptance criteria are the contract.** They were agreed on in the feature spec. If they all pass, the feature is done. If the user wants more, that's a new feature spec.

5. **Compile first, always.** Nothing else matters if it doesn't compile.
