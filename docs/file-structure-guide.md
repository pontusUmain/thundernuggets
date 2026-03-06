# Claude Code Project Structure Guide

This document describes the recommended file structure for AI-assisted development with Claude Code.

## Overview

This structure separates concerns by role and workflow phase, making it easier for teams to collaborate without merge conflicts.

## Complete Structure

```
project-root/
├── CLAUDE.md                        # Project brain: tech stack, conventions, pipeline rules
├── .claude/
│   ├── settings.json                # Hooks + permissions (shared via git)
│   ├── agents/
│   │   ├── build.md                 # Implements tasks
│   │   ├── qa.md                    # Validates against acceptance criteria
│   │   └── feature.md               # Research agent
│   ├── commands/
│   │   ├── pick-task.md             # Claim next TASK-XXX
│   │   ├── pr-review.md             # Standard PR review
│   │   └── run-pipeline.md          # Run full pipeline phase
│   └── skills/
│       ├── prd-generator/SKILL.md
│       ├── design-spec/SKILL.md
│       ├── tech-design/SKILL.md
│       ├── task-breakdown/SKILL.md
│       ├── build-agent/SKILL.md
│       └── qa-gate/SKILL.md
│
├── design/
│   ├── CLAUDE.md                    # Design-specific rules
│   ├── design-spec.md               # Owned by designer
│   └── *.pen                        # Wireframes
│
├── pm/
│   ├── CLAUDE.md                    # PM-specific rules
│   ├── prd.md                       # Owned by PM
│   └── summary.md
│
├── docs/
│   ├── tech-design.md               # Owned by tech lead
│   ├── architecture.md
│   └── qa/
│       └── TASK-XXX-report.md
│
├── mobile/                          # iOS/Android project
│   ├── CLAUDE.md                    # Platform-specific build commands
│   └── ...
│
├── tasks.md                         # Work queue: TASK-XXX with status + owner
│
├── CODEOWNERS                       # pm/ → PM, design/ → designer, mobile/ → devs
│
└── .github/
    └── workflows/
        ├── qa-gate.yml              # CI: no task complete without green pipeline
        └── pr-review.yml            # Auto-review with Claude
```

## Key Principles

### 1. Role-Based Directories

Each role has its own directory with its own `CLAUDE.md`:

- **`pm/`** — Product Manager owns PRD and project summary
- **`design/`** — Designer owns design spec and wireframes
- **`docs/`** — Tech Lead owns technical design and architecture
- **`mobile/` or `web/`** — Developers own implementation

This prevents merge conflicts when multiple people work in parallel.

### 2. CLAUDE.md Files

Each directory can have its own `CLAUDE.md` with context specific to that role:

- **Root `CLAUDE.md`** — Project-wide rules, tech stack, conventions
- **`design/CLAUDE.md`** — Design-specific rules and guidelines
- **`pm/CLAUDE.md`** — PM-specific templates and processes
- **`mobile/CLAUDE.md`** — Platform-specific build commands and patterns

### 3. Pipeline Artifacts

Pipeline outputs have designated locations:

| Artifact | Location | Owner |
|----------|----------|-------|
| Project Summary | `pm/summary.md` | PM |
| PRD | `pm/prd.md` | PM |
| Design Spec | `design/design-spec.md` | Designer |
| Wireframes | `design/*.pen` | Designer |
| Tech Design | `docs/tech-design.md` | Tech Lead |
| Tasks | `tasks.md` (root) | Shared |
| QA Reports | `docs/qa/TASK-XXX-report.md` | Build Agent |

### 4. Shared Task Queue

`tasks.md` lives in the root and follows this format:

```markdown
## TASK-001: Setup authentication flow

**Status:** in_progress
**Owner:** @alice
**Priority:** high

### Acceptance Criteria
- [ ] User can sign up with email/password
- [ ] User can log in
- [ ] Session persists on reload

---

## TASK-002: Design onboarding screens

**Status:** pending
**Owner:** unassigned
**Priority:** medium

### Acceptance Criteria
- [ ] 3 onboarding screens designed
- [ ] Exported to Figma
```

### 5. Commands and Skills

**`.claude/commands/`** — Custom slash commands for your workflow

**`.claude/skills/`** — Reusable AI workflows (PRD generation, design spec, etc.)

**`.claude/agents/`** — Specialized agents that use skills

## Getting Started

1. **Copy this structure** into your project
2. **Create root `CLAUDE.md`** with your tech stack and conventions
3. **Add role-specific `CLAUDE.md`** files as needed
4. **Set up `CODEOWNERS`** to enforce ownership
5. **Configure `.claude/settings.json`** with your preferences

## CODEOWNERS Example

```
# Product
/pm/ @product-manager

# Design
/design/ @designer

# Engineering
/mobile/ @mobile-team
/web/ @web-team
/docs/ @tech-lead

# Shared
/tasks.md @everyone
```

## Recommended Workflow

1. PM writes summary → `pm/summary.md`
2. PM generates PRD → `pm/prd.md`
3. Designer creates design spec → `design/design-spec.md`
4. Designer creates wireframes → `design/*.pen`
5. Tech Lead writes tech design → `docs/tech-design.md`
6. Break down into tasks → `tasks.md`
7. Devs claim tasks and implement
8. QA validates → `docs/qa/TASK-XXX-report.md`

## Benefits

- **No merge conflicts** — Each role works in separate directories
- **Clear ownership** — CODEOWNERS enforces who reviews what
- **Consistent pipeline** — Every project follows the same flow
- **Contextual AI assistance** — Each directory has relevant CLAUDE.md rules
- **Audit trail** — All decisions documented in their respective locations

---

Generated from the VAJB Workshop
