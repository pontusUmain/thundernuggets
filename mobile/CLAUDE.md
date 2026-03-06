# Mobile Rules

- Platform-specific build commands and patterns go here
- Follow the tech design in `docs/tech-design.md`
- Follow the design spec in `design/design-spec.md`

---

## iOS Architecture Guidelines

### Project Structure

Organise code by feature folder within a single app target:

- `Models/` — domain data structures and entities
- `Network/` — API client, request/response handling, offline queue
- `DesignSystem/` — design tokens, reusable UI components, theming
- `Features/` — one subfolder per major app section (Home, MyDay, ECommerce, WorkAssistant)

### UI Paradigm

SwiftUI is the default. Embrace its declarative nature. Do not introduce UIKit unless a specific capability is unavailable in SwiftUI (e.g. certain camera APIs).

**Do not use ViewModels.** State lives in views or `@Observable` objects passed via the environment.

### State Management

| Wrapper | Use for |
|---|---|
| `@State` | Local, ephemeral view state (e.g. toggle, sheet presented) |
| `@Binding` | Two-way data flow from parent to child |
| `@Observable` | Shared state across multiple views |
| `@Environment` | Dependency injection (services, stores, design tokens) |

State flows down, actions flow up. Keep state ownership as close to the usage point as possible. Do not hoist state higher than necessary.

### Async / Concurrency

Use `async/await` as the default for all asynchronous operations. Do not use Combine for new code.

Use `.task` view modifiers for lifecycle-aware async work — they cancel automatically when the view disappears.

```swift
// ✅ Correct
.task {
    await store.loadProjects()
}

// ❌ Avoid
.onAppear {
    cancellable = publisher.sink { ... }
}
```

### Build Verification

Always build after code changes and fix all compilation errors before moving to the next task. Do not leave the codebase in a non-compiling state.
