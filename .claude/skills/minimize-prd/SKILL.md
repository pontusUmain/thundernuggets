# Minimize PRD Skill

Scales down a PRD or product spec to a focused MVP by removing everything that doesn't directly serve the defined goal.

## Input
- `pm/prd.md` (or any PRD/spec file specified by the user)

## Output
- The same file, overwritten with the minimized version (or `pm/prd-mvp.md` if the user wants to preserve the original)

## Process
1. Read the existing PRD or product spec
2. Identify the single primary goal — the one sentence that defines what success looks like
3. For each feature, section, or requirement, ask: "Does this directly enable the primary goal?" Remove it if not
4. Eliminate:
   - Nice-to-haves and "phase 2" items
   - Duplicate or redundant sections
   - Filler language and verbose explanations (keep content dense)
   - Features that serve edge cases, not the core user
   - Success metrics that aren't tied to the primary goal
5. Rewrite the output as a minimal, tight document with only:
   - One-line goal statement
   - Core user and their primary pain point
   - MVP feature list (only what's required to ship and validate)
   - Acceptance criteria per feature (short, testable)
   - One or two success metrics directly tied to the goal
6. Write the minimized PRD back to the output file

## Principles
- If a feature requires justification to keep, cut it
- Prefer a shorter list of well-defined features over a long list of vague ones
- The output should be readable in under 5 minutes
- Ruthlessly cut scope — the goal is to find the smallest thing that can validate the product hypothesis
