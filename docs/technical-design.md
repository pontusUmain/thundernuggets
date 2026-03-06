# Technical Design

**Product:** Dahl App — MVP Prototype
**Version:** 1.0
**Status:** Draft
**Last updated:** 2026-03-06
**Based on:** docs/PRD.md v1.0, mobile/CLAUDE.md, DahlPrototype Xcode project

> **Note:** `design/design-spec.md` has not been generated yet. This document proceeds from PRD requirements and the iOS architecture guidelines in `mobile/CLAUDE.md`. Update Section 3 (Design Tokens) once the design spec is complete.
>
> **TODO:** Re-run `/tech-design` once `design/design-spec.md` has been generated. The design spec will add concrete design token definitions, component specifications, and spacing/typography values that should be reflected in the `DesignSystem/` layer of this document.

---

## 1. System Architecture

### Component Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                       iOS APP (SwiftUI)                      │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌──────────┐  │
│  │  Home    │  │  My Day  │  │ E-Commerce │  │  Work    │  │
│  │ Feature  │  │ Feature  │  │  Feature   │  │Assistant │  │
│  └────┬─────┘  └────┬─────┘  └─────┬──────┘  └────┬─────┘  │
│       │             │              │               │         │
│  ┌────▼─────────────▼──────────────▼───────────────▼──────┐  │
│  │                  @Observable Stores                     │  │
│  │  ProjectStore  OrderStore  ScheduleStore  AIStore       │  │
│  └──────────────────────────┬──────────────────────────────┘  │
│                             │                                │
│  ┌──────────────────────────▼──────────────────────────────┐  │
│  │                  Data Layer                             │  │
│  │   NetworkClient (URLSession)  |  JsonHandler (mock)     │  │
│  │   OfflineQueue (SwiftData)    |  Keychain (auth tokens) │  │
│  └──────────────────────────┬──────────────────────────────┘  │
└─────────────────────────────┼────────────────────────────────┘
                              │ HTTPS (TLS 1.3)
              ┌───────────────▼──────────────────┐
              │         BACKEND (future)          │
              │  Auth API  |  Core API  |  AI API │
              └──────────────────────────────────┘

PROTOTYPE NOTE: NetworkClient calls are backed by JsonHandler
(local JSON files) for the prototype. The interface is identical
to the future live implementation — swap the data source only.
```

### Data Flow: Place Order from Project Context (FR-06)

```
1. User taps "Order" on project screen
2. View reads projectId from @Environment ProjectStore
3. OrderFormView initialises with pre-filled projectId
4. User confirms → View calls await orderStore.placeOrder(payload)
5. OrderStore validates payload locally (throws OrderError.invalidPayload)
6. NetworkClient sends POST /v1/orders (or enqueues if offline)
7. On success: OrderStore updates orders array + project.spent
8. ProjectBudgetView re-renders automatically via @Observable
9. Confirmation sheet shown: "Added to [project] — now at X% of budget"
```

---

## 2. Tech Stack

### Decision: Native iOS / SwiftUI

**Chosen:** Native iOS with SwiftUI, Swift 5.10, iOS 16.0 minimum deployment target.

**Alternatives considered:**
| Option | Rejected because |
|---|---|
| React Native | Project already has an Xcode project scaffolded; team has iOS expertise per architecture guidelines; PRD requires offline-first behaviour and barcode scanning that are simpler via native AVFoundation |
| Flutter | Adds Dart runtime complexity; no existing codebase to build on; iOS-only for prototype per PRD Section 6 |

**Justification:** PRD FR-15 requires iOS 16.0+. The existing `DahlPrototype.xcodeproj` and `mobile/CLAUDE.md` establish native SwiftUI as the foundation. Native AVFoundation gives direct access to the camera for barcode scanning (FR-10) with no third-party SDK required.

### Full Stack

| Layer | Technology | Version | Justification |
|---|---|---|---|
| Language | Swift | 5.10 | Ships with Xcode 15.4; required for `@Observable` macro |
| UI framework | SwiftUI | iOS 16+ APIs | Declarative, native; per mobile/CLAUDE.md |
| Navigation | SwiftUI NavigationStack | iOS 16+ | Type-safe navigation; no third-party routing needed |
| State management | `@Observable` + `@Environment` | Swift 5.9+ | Per mobile/CLAUDE.md; replaces ObservableObject |
| Local persistence | SwiftData | iOS 17+ | Native ORM for offline queue and cached data; zero-dependency |
| Keychain | Security framework (KeychainAccess wrapper) | — | Auth token storage; OS-level secure storage per NFR |
| Networking | URLSession | Foundation | Native async/await support; no Alamofire needed |
| Mock data layer | JsonHandler (custom) | — | Local JSON files for prototype; same interface as NetworkClient |
| Barcode scanning | AVFoundation | iOS 16+ | Native camera access for EAN-13/QR (FR-10); no SDK fee |
| AI / LLM | Anthropic API (claude-sonnet-4-6) | — | Best VVS-domain reasoning; streaming response support for 8s latency target (FR-08) |
| Image handling | PhotosUI + SwiftUI AsyncImage | iOS 16+ | Photo input for Work Assistant (FR-16); no third-party needed |
| Push notifications | APNs via UserNotifications framework | iOS 16+ | Budget alerts (FR-19, FR-09) |
| CI/CD | Xcode Cloud | — | Native to Apple ecosystem; TestFlight distribution built in |
| Crash reporting | Sentry iOS SDK | 8.x | Crash reporting + API error capture |

---

## 3. Project Structure

Per `mobile/CLAUDE.md` — single app target, feature-folder layout:

```
DahlPrototype/
├── App/
│   ├── DahlPrototypeApp.swift       # @main, environment injection
│   └── AppEnvironment.swift         # Root @Observable stores injected via .environment()
│
├── Models/
│   ├── Project.swift
│   ├── Order.swift
│   ├── Job.swift
│   ├── TimeEntry.swift
│   ├── Product.swift
│   └── User.swift
│
├── Network/
│   ├── NetworkClient.swift          # URLSession wrapper, auth header, retry
│   ├── APIEndpoint.swift            # Enum of all endpoints
│   ├── OfflineQueue.swift           # SwiftData-backed queue
│   └── NetworkMonitor.swift         # NWPathMonitor wrapper
│
├── Handlers/
│   └── JsonHandler.swift            # Existing — bundle JSON loader
│
├── DesignSystem/
│   ├── Tokens.swift                 # Colors, spacing, typography as static constants
│   ├── Components/
│   │   ├── PrimaryButton.swift
│   │   ├── CardView.swift
│   │   ├── BudgetBar.swift
│   │   └── ...
│   └── Extensions/
│       └── Color+Tokens.swift
│
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeStore.swift          # @Observable
│   │   └── Components/
│   ├── MyDay/
│   │   ├── MyDayView.swift
│   │   ├── ScheduleStore.swift
│   │   └── Components/
│   ├── ECommerce/
│   │   ├── OrderView.swift
│   │   ├── BarcodeScannerView.swift
│   │   ├── OrderStore.swift
│   │   └── Components/
│   └── WorkAssistant/
│       ├── AssistantView.swift
│       ├── AIStore.swift
│       └── Components/
│
├── Stores/
│   ├── ProjectStore.swift           # Shared across features
│   ├── AuthStore.swift
│   └── NotificationStore.swift
│
└── MockData/                        # JSON files for prototype
    ├── projects.json
    ├── jobs.json
    ├── orders.json
    └── products.json
```

---

## 4. State Management

Per `mobile/CLAUDE.md`: `@Observable` for shared state, `@State` for local, `@Binding` for two-way child flow, `@Environment` for injection. No ViewModels.

### Store Pattern

```swift
// Stores/ProjectStore.swift
import Foundation

@Observable
final class ProjectStore {
    var projects: [Project] = []
    var isLoading = false
    var error: String? = nil

    private let client: DataClient  // Protocol — NetworkClient or JsonHandler-backed mock

    init(client: DataClient = LiveDataClient()) {
        self.client = client
    }

    func loadProjects() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            projects = try await client.fetch([Project].self, from: .projects)
        } catch {
            self.error = "Unable to load projects. Pull down to retry."
        }
    }

    func updateBudgetSpent(projectId: String, addedAmount: Int) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].spent.amount += addedAmount
    }
}
```

### Environment Injection at Root

```swift
// App/DahlPrototypeApp.swift
@main
struct DahlPrototypeApp: App {
    @State private var projectStore = ProjectStore()
    @State private var orderStore = OrderStore()
    @State private var scheduleStore = ScheduleStore()
    @State private var authStore = AuthStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(projectStore)
                .environment(orderStore)
                .environment(scheduleStore)
                .environment(authStore)
        }
    }
}
```

### Consuming in a View

```swift
// Features/Home/HomeView.swift
struct HomeView: View {
    @Environment(ProjectStore.self) private var projectStore

    var body: some View {
        Group {
            if projectStore.isLoading {
                SkeletonListView()
            } else if let error = projectStore.error {
                ErrorStateView(message: error, retry: { Task { await projectStore.loadProjects() } })
            } else if projectStore.projects.isEmpty {
                EmptyStateView(message: "No active projects.")
            } else {
                projectListContent
            }
        }
        .task { await projectStore.loadProjects() }
    }
}
```

---

## 5. Data / Network Layer

### DataClient Protocol (enables mock swap)

```swift
// Network/DataClient.swift
protocol DataClient {
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint) async throws -> T
    func post<T: Decodable, B: Encodable>(_ body: B, to endpoint: APIEndpoint) async throws -> T
}

// Prototype: backed by JsonHandler
struct MockDataClient: DataClient {
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint) async throws -> T {
        try JsonHandler.load(endpoint.mockFilename, as: type)
    }
    func post<T: Decodable, B: Encodable>(_ body: B, to endpoint: APIEndpoint) async throws -> T {
        // Return mock confirmation response
        try JsonHandler.load(endpoint.mockResponseFilename, as: type)
    }
}

// Production: backed by URLSession
struct LiveDataClient: DataClient {
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint) async throws -> T {
        let request = try URLRequest(endpoint: endpoint, method: .get)
        let (data, response) = try await URLSession.shared.data(for: request)
        try response.validate()
        return try JSONDecoder.iso8601.decode(T.self, from: data)
    }
    // ...
}
```

### Offline Queue

```swift
// Network/OfflineQueue.swift
import SwiftData

@Model
final class QueuedRequest {
    var id: String
    var endpointRaw: String
    var method: String
    var payloadData: Data
    var createdAt: Date
    var retries: Int

    init(endpoint: APIEndpoint, method: String, payload: some Encodable) throws {
        self.id = UUID().uuidString
        self.endpointRaw = endpoint.path
        self.method = method
        self.payloadData = try JSONEncoder().encode(payload)
        self.createdAt = Date()
        self.retries = 0
    }
}

// Processed in NetworkMonitor.onConnectivityRestored:
// - Dequeue in createdAt order
// - Max 3 retries with exponential backoff: 1s, 4s, 16s
// - On 3rd failure: move to dead-letter, notify user via NotificationStore
```

### Auth Token Storage

```swift
// Stores/AuthStore.swift
import Security

@Observable
final class AuthStore {
    private(set) var isAuthenticated = false
    private(set) var userId: String? = nil

    func saveTokens(access: String, refresh: String, userId: String) throws {
        try Keychain.save(key: "dahl.access_token", value: access)
        try Keychain.save(key: "dahl.refresh_token", value: refresh)
        self.userId = userId
        self.isAuthenticated = true
    }

    func clearSession() {
        Keychain.delete(key: "dahl.access_token")
        Keychain.delete(key: "dahl.refresh_token")
        userId = nil
        isAuthenticated = false
    }
    // Access tokens: 15min TTL. Refresh tokens: 30d TTL.
    // On 401: attempt silent refresh before clearing session.
}
```

---

## 6. API Endpoints

All endpoints derive from PRD functional requirements. For the prototype, each maps to a JSON file in `MockData/`.

### Conventions
- Base URL: `https://api.dahl.se/v1`
- Auth: `Authorization: Bearer <access_token>`
- Errors: `{ "error": { "code": "STRING", "message": "User-facing string" } }`
- Dates: ISO 8601 UTC
- Amounts: integers in minor currency unit (öre); always include `currency` field

### Endpoint Index

| Method | Path | Requirement | Mock file |
|---|---|---|---|
| GET | `/v1/projects` | FR-11 | `projects.json` |
| GET | `/v1/projects/:id` | FR-11, FR-07 | `project_detail.json` |
| GET | `/v1/jobs/today` | FR-01, FR-03 | `jobs_today.json` |
| POST | `/v1/orders` | FR-06, FR-07 | `order_confirmation.json` |
| GET | `/v1/orders?projectId=` | FR-08 (manager) | `orders.json` |
| GET | `/v1/products/barcode/:code` | FR-10 | `product_by_barcode.json` |
| GET | `/v1/products/search?q=` | FR-23 | `product_search.json` |
| POST | `/v1/ai/query` | FR-08, FR-09 | `ai_response.json` |
| GET | `/v1/time-entries/today` | FR-14 | `time_entries_today.json` |
| POST | `/v1/time-entries/confirm` | FR-14 | `time_entry_confirmed.json` |

### `POST /v1/orders`

**Request:**
```json
{
  "projectId": "proj_01j...",
  "items": [
    { "sku": "VVS-4421-B", "quantity": 3 }
  ]
}
```

**Response 201:**
```json
{
  "orderId": "ord_01j...",
  "projectId": "proj_01j...",
  "projectName": "Bergström Bathroom Renovation",
  "budgetConsumedPercent": 67,
  "totalAmount": { "amount": 1245, "currency": "SEK" },
  "estimatedDelivery": "2026-03-07"
}
```

**Errors:** 400 `VALIDATION_ERROR`, 401 `UNAUTHORIZED`, 409 `DUPLICATE_ORDER`, 500 `INTERNAL_ERROR`.

### `POST /v1/ai/query`

**Request:**
```json
{
  "prompt": "The 22mm copper fitting won't seat properly on the press tool. It keeps slipping.",
  "projectId": "proj_01j...",
  "imageBase64": "<optional, ≤10MB JPEG/PNG>"
}
```

**Response 200 (streaming via Server-Sent Events):**
```
data: {"delta": "Check that the jaw profile"}
data: {"delta": " matches the fitting diameter."}
data: {"products": [{"sku": "VVS-4421-B", "name": "22mm Press Jaw Set", "price": 890}]}
data: {"done": true}
```

Client reads via `URLSession.bytes(for:)` and appends deltas to the response string as they arrive, giving perceived sub-1s first response despite the 8s total budget.

---

## 7. Models

```swift
// Models/Project.swift
struct Project: Identifiable, Codable {
    let id: String
    var name: String
    var status: ProjectStatus
    var budget: Money
    var spent: Money
    var updatedAt: Date
}

enum ProjectStatus: String, Codable { case active, completed, archived }
struct Money: Codable { var amount: Int; var currency: String }  // amount in öre

// Models/Job.swift
struct Job: Identifiable, Codable {
    let id: String
    var projectId: String
    var clientAddress: String
    var scheduledStart: Date
    var scheduledEnd: Date
    var status: JobStatus
    var materials: [JobMaterial]
}

enum JobStatus: String, Codable { case onTrack, missingMaterials, unconfirmed }
struct JobMaterial: Codable { var productName: String; var needed: Int; var ordered: Int; var delivered: Bool }

// Models/Order.swift
struct Order: Identifiable, Codable {
    let id: String
    var projectId: String
    var items: [OrderItem]
    var totalAmount: Money
    var status: OrderStatus
    var placedBy: String
    var createdAt: Date
}

enum OrderStatus: String, Codable { case pending, confirmed, shipped, delivered }
struct OrderItem: Codable { var sku: String; var name: String; var quantity: Int; var unitPrice: Money }
```

---

## 8. Error Handling

### Error Taxonomy

| Code | User-facing message (displayed in ErrorStateView) | Logged to Sentry |
|---|---|---|
| `UNAUTHORIZED` | "Your session has expired. Please sign in again." | No |
| `FORBIDDEN` | "You don't have permission to do that." | Yes (warn) |
| `NOT_FOUND` | "That item no longer exists." | No |
| `VALIDATION_ERROR` | Field-level message from response body | No |
| `DUPLICATE_ORDER` | "This order was already submitted." | Yes (warn) |
| `RATE_LIMITED` | "Too many requests. Please wait a moment." | Yes (warn) |
| `NETWORK_OFFLINE` | "You're offline. This will be sent when you reconnect." | No |
| `INTERNAL_ERROR` | "Something went wrong. We've been notified." | Yes (error) |
| `PARSE_ERROR` | "Something went wrong. We've been notified." | Yes (error) |

### Swift Error Pattern

```swift
// Network/NetworkError.swift
enum NetworkError: LocalizedError {
    case unauthorized
    case forbidden
    case notFound
    case validationError(fields: [String: String])
    case duplicateOrder
    case rateLimited
    case offline
    case serverError(code: String)
    case parseError(underlying: Error)

    var userMessage: String {
        switch self {
        case .unauthorized: return "Your session has expired. Please sign in again."
        case .offline: return "You're offline. This will be sent when you reconnect."
        case .serverError, .parseError: return "Something went wrong. We've been notified."
        // ...
        }
    }
}
```

All async store methods follow this pattern — never propagate raw errors to views:

```swift
func placeOrder(_ payload: OrderPayload) async {
    isSubmitting = true
    submissionError = nil
    defer { isSubmitting = false }
    do {
        let confirmation = try await client.post(payload, to: .orders)
        lastConfirmation = confirmation
    } catch let error as NetworkError {
        submissionError = error.userMessage  // String — safe to show in UI
    } catch {
        submissionError = NetworkError.serverError(code: "UNKNOWN").userMessage
        Sentry.capture(error)
    }
}
```

---

## 9. Barcode Scanner (FR-10)

AVFoundation — no third-party SDK.

```swift
// Features/ECommerce/BarcodeScannerView.swift
import AVFoundation
import SwiftUI

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onScan: (String) -> Void  // Returns raw barcode string

    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController(onScan: onScan)
    }
    // ScannerViewController sets up AVCaptureSession with
    // AVMetadataObjectTypeEAN13Code + AVMetadataObjectTypeQRCode.
    // Calls onScan on main thread within 2s of barcode entering frame (FR-10).
    // Camera viewfinder must open within 1s of tap (FR-10) — session starts
    // in viewDidLoad, not viewDidAppear.
}
```

---

## 10. AI Streaming (FR-08, FR-09)

```swift
// Features/WorkAssistant/AIStore.swift
@Observable
final class AIStore {
    var responseText = ""
    var recommendedProducts: [Product] = []
    var isStreaming = false
    var error: String? = nil

    func query(prompt: String, projectId: String, imageData: Data? = nil) async {
        isStreaming = true
        responseText = ""
        recommendedProducts = []
        error = nil
        defer { isStreaming = false }

        let payload = AIQueryPayload(prompt: prompt, projectId: projectId, imageBase64: imageData?.base64EncodedString())

        do {
            let (stream, _) = try await URLSession.shared.bytes(for: URLRequest(endpoint: .aiQuery, body: payload))
            for try await line in stream.lines {
                guard line.hasPrefix("data: "),
                      let data = line.dropFirst(6).data(using: .utf8),
                      let event = try? JSONDecoder().decode(AIStreamEvent.self, from: data)
                else { continue }

                if let delta = event.delta { responseText += delta }
                if let products = event.products { recommendedProducts = products }
            }
        } catch {
            self.error = "Unable to reach the assistant. Check your connection."
            Sentry.capture(error)
        }
    }
}
```

---

## 11. Performance

| Requirement | Mechanism |
|---|---|
| Home renders cached data in <1s (FR: performance) | Stores pre-populate from SwiftData cache on init; network refresh runs in background |
| Lists scroll at 60fps | Use `List` with `.id`-stable items; avoid `AnyView` wrappers; profile with Instruments Time Profiler |
| Scanner viewfinder opens in <1s (FR-10) | `AVCaptureSession.startRunning()` called in `viewDidLoad`, not `viewDidAppear` |
| AI first token <8s (FR-08) | Streaming via SSE — first character renders as it arrives; no waiting for full response |
| Images | Use `AsyncImage` with `.fill` content mode + skeleton placeholder; never load full-res images in list rows |

---

## 12. Security

- **Auth tokens:** Stored in Keychain via Security framework. Never in `UserDefaults` or any `.plist`.
- **TLS:** `URLSession` enforces ATS (App Transport Security) by default — no plain HTTP allowed.
- **Location data:** Requested only with `WhenInUse` authorisation. Never transmitted to backend without explicit opt-in (PRD NFR). Used only for route nudge and time-tracking inference.
- **AI inputs:** User-provided text and images sent over TLS. AI responses rendered as plain `Text()` — never as HTML or via `attributedString` from untrusted source.
- **No secrets in code:** API base URL in `Info.plist`; API keys injected via Xcode Cloud environment variables, never hardcoded.

---

## 13. Testing Strategy

| Layer | Tool | Coverage target |
|---|---|---|
| Store logic | XCTest | 85% of store methods |
| Network layer | XCTest with MockDataClient | 100% of NetworkClient paths |
| UI flows (P0) | XCUITest | All P0 acceptance criteria |
| JsonHandler | XCTest | Happy path + file-not-found + decode failure |

```swift
// Tests/ProjectStoreTests.swift
final class ProjectStoreTests: XCTestCase {
    func testLoadProjectsPopulatesArray() async throws {
        let store = ProjectStore(client: MockDataClient())
        await store.loadProjects()
        XCTAssertFalse(store.projects.isEmpty)
        XCTAssertNil(store.error)
    }

    func testLoadProjectsSetsErrorOnFailure() async throws {
        let store = ProjectStore(client: FailingDataClient())
        await store.loadProjects()
        XCTAssertNotNil(store.error)
        XCTAssertTrue(store.projects.isEmpty)
    }

    func testBudgetWarningAt80Percent() {
        var project = Project.fixture(budgetAmount: 10000, spentAmount: 8000)
        XCTAssertTrue(project.isNearBudget)  // 80% threshold (FR-12)
    }
}
```

---

## 14. Deployment

| Environment | Distribution | Trigger |
|---|---|---|
| Development | Simulator / personal device via Xcode | Manual |
| Staging | TestFlight internal group | Merge to `main` via Xcode Cloud |
| Stakeholder demo | TestFlight external link | Manual promote |
| Production | App Store | Manual, post-validation |

**Xcode Cloud workflow:**
1. On push to `main`: run `xcodebuild test` (unit + UI), then archive and distribute to TestFlight internal group.
2. Build failures block TestFlight distribution.
3. Rollback: re-distribute a previous TestFlight build — no code change required.

---

## 15. Open Technical Decisions

| Decision | Options | Owner | Due |
|---|---|---|---|
| Authentication provider | Sign in with Apple vs OAuth 2.0 PKCE via Dahl identity provider | Dahl IT + umain tech lead | Before auth implementation |
| AI provider | Anthropic claude-sonnet-4-6 vs claude-haiku-4-5 (latency vs cost) | umain tech lead | Before Work Assistant implementation |
| Push notification entitlement | Requires Apple developer account with APNs — confirm available for prototype | umain iOS lead | Week 1 |
| SwiftData availability | SwiftData requires iOS 17+; PRD specifies iOS 16 minimum. Decision: use SwiftData for offline queue (iOS 17+ devices) with UserDefaults fallback for iOS 16, or raise minimum to iOS 17 | umain tech lead + Dahl PM | Before offline queue implementation |
| Flexibla Kontoret integration | Mock JSON for prototype; live API TBD pending partner agreement | Dahl product owner | Post-prototype |
