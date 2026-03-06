---
name: design-spec
description: "Generate a design specification from a PRD, including screen inventory, user flows, component list, interaction patterns, and state definitions. Optionally generates Pencil.dev .pen wireframes via MCP. Use this skill when the user says 'create a design spec', 'design this', 'what screens do we need', 'map out the UI', 'wireframe this', 'design the flows', or after a PRD has been created and the user wants to move to the design phase. Also trigger when the user mentions Pencil, .pen files, or wants to visualize what the app looks like before writing code."
---

# Design Spec Generator

Take a PRD and produce a complete design specification that bridges product requirements and engineering implementation. Optionally generates Pencil.dev wireframes.

## Why This Exists

A PRD says what to build. A tech design says how to build it. But between those two lives a critical question: what does it actually look like and feel like? Without a design spec, engineers interpret requirements differently, flows get missed, and edge states (empty, error, loading) get punted to "we'll figure it out later." This skill closes that gap.

## Workflow

### Step 1: Read the PRD

Read the PRD at `docs/PRD.md`. If it doesn't exist, stop and tell the user to run `/prd-generator` first. Extract:

- All user stories and their acceptance criteria
- Functional requirements (the FR- numbered items)
- UX requirements if they exist
- Target users / personas
- Platform constraints (iOS, Android, web, etc.)

### Step 2: Generate the Design Spec

Create `docs/design-spec.md` with this structure:

```markdown
# Design Specification: [Product Name]

## 1. Screen Inventory

A complete list of every screen the app needs. For each screen:

| Screen | Purpose | Entry Points | Key Elements |
|--------|---------|-------------|--------------|
| Home | Main dashboard / session list | App launch, tab bar | Session list, FAB, timer button |
| ... | ... | ... | ... |

## 2. Navigation Structure

How screens connect to each other:
- Tab bar structure (if applicable)
- Navigation stack hierarchy
- Modal presentations
- Deep link entry points

Include a text-based sitemap:
```
Tab Bar
├── Home
│   ├── Session Detail
│   │   └── Edit Session
│   └── New Session
├── Search
│   └── Filtered Results
│       └── Session Detail
├── Insights
│   └── Insight Detail
└── Settings
    ├── Tag Library
    ├── Export
    └── Account
```

## 3. User Flows

For each core flow from the PRD's user stories, write a step-by-step flow:

### Flow: [Name]
**Trigger:** What starts this flow
**Happy path:**
1. User sees [screen] with [state]
2. User taps [element]
3. System [responds with]
4. User sees [result]

**Error paths:**
- If [condition] → show [error state]
- If [condition] → fallback to [alternative]

**Edge cases:**
- First-time user (empty state)
- Offline
- Interrupted (app backgrounded mid-flow)

Focus on the 3-5 most important flows. Don't map every possible path — map the ones that matter.

## 4. Component Inventory

List the reusable UI components this app needs:

| Component | Used In | Variants | Notes |
|-----------|---------|----------|-------|
| SessionCard | Home, Search results | Default, compact, with photo | Shows project name, date, rating, tag chips |
| TagChip | Session form, detail, search | Default, selected, removable | Category-colored |
| RatingPicker | Session form, detail | Interactive, read-only | 1-5 stars/emoji |
| ... | ... | ... | ... |

## 5. State Definitions

For every screen, define all possible states:

### [Screen Name]
- **Empty:** First-time user, no data yet. Show [description].
- **Loading:** Data is being fetched/computed. Show [description].
- **Loaded:** Normal state with data. Show [description].
- **Error:** Something went wrong. Show [description + recovery action].
- **Offline:** No network. Show [description + what still works].
- **Partial:** Some data loaded, some failed. Show [description].

Not every screen needs all states. Be pragmatic — a settings screen probably doesn't need a loading state.

## 6. Interaction Patterns

Define the interaction language of the app:

- **Gestures:** Swipe actions, pull-to-refresh, long press behaviors
- **Transitions:** Push, modal, sheet presentations
- **Feedback:** Haptics, animations, success/error indicators
- **Input patterns:** How forms work, validation timing, keyboard behavior

## 7. Responsive & Adaptive

Adapt this section to the project's platform:
- **Web:** Desktop, tablet, mobile breakpoints. Touch vs pointer interactions.
- **Mobile (iOS):** iPhone vs iPad. Dynamic Type. Orientation. SF Symbols.
- **Mobile (Android):** Phone vs tablet. Material You theming.
- **Cross-platform:** Shared design with platform-specific adaptations.
- Dark mode considerations (not just colors — also image treatments, shadows, contrast)

## 8. Accessibility Checklist

- Screen reader reading order for each key screen (VoiceOver / TalkBack / ARIA)
- Custom accessibility labels for non-obvious elements
- Focus management for modal flows
- Reduced Motion alternatives for animations
- Keyboard navigation support (web)
```

### Step 3: Pencil.dev Integration (If Available)

Check if Pencil MCP is available by looking for `.pen` files in the project or checking MCP configuration.

**If Pencil is available:**
Generate wireframes for the key screens. Focus on:
- Home / main screen
- The primary creation flow (e.g., new session form)
- Search / list view
- Detail view

Use the Pencil MCP tools to create `.pen` files with proper component grouping and naming (so the AI can later generate clean code from them).

Save `.pen` files in the `design/` directory. Name files clearly: `design/home.pen`, `design/new-session.pen`, `design/search.pen`, etc.

**If Pencil is NOT available:**
Skip wireframe generation. The text-based design spec is complete and sufficient on its own. Note in the output that wireframes can be added later with Pencil.

### Step 4: Present and Confirm

Save `docs/design-spec.md` and any `design/*.pen` files. Show the user:
- Screen count and list
- The navigation structure
- Key flows covered
- Any design decisions you made and why

Ask if anything is missing before moving to tech design.

## Writing Principles

1. **Think in screens, not features.** A single feature may touch 3 screens. A single screen may serve 4 features. Organize by screens — that's what gets designed and built.

2. **States are not optional.** Every screen has at least 3 states. If you only defined the happy path, you haven't designed the screen — you've designed a screenshot.

3. **Name everything.** Screens, components, flows — give them names. Names become the shared vocabulary between design, engineering, and product. If the component is called "SessionCard" in the design spec, it should be called `SessionCard` in the codebase.

4. **Be platform-native.** Match the platform specified in the PRD. iOS apps use navigation stacks, tab bars, sheets. Web apps use routes, sidebars, modals. Android uses bottom navigation, FABs, Material Design. Don't mix platform patterns.

5. **Don't design what doesn't exist in the PRD.** If the PRD doesn't have a social feature, don't add a profile screen. Stay within scope.
