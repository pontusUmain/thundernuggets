# Product Requirements Document

**Product:** Dahl App — MVP Prototype
**Version:** 1.0
**Status:** Draft
**Last updated:** 2026-03-06
**Owner:** umain (prototype delivery) / Dahl (product owner)

---

## 1. Executive Summary

The Dahl App is a mobile-first tool for VVS (plumbing, heating, ventilation) installers and installation company managers that unifies job management, product ordering, AI-assisted problem solving, and time tracking into a single experience. It is being built now because Dahl — Sweden's leading VVS wholesaler with SEK 8B revenue and 38,000 active craftspeople — faces fragmented digital tooling that splits installer workflows across two separate apps and manual processes, while competitors like Ahlsell accelerate their own digital investments. The MVP prototype validates five core hypotheses about installer behaviour before committing to full product development.

---

## 2. Business Objectives

- **OBJ-1:** Demonstrate a working prototype of all four app sections (Home, My Day, E-Commerce, Work Assistant) sufficient to hold a concrete stakeholder conversation about direction, scope, and next steps.
- **OBJ-2:** Validate or invalidate all five product hypotheses (H1–H5) through prototype testing, producing documented evidence for each.
- **OBJ-3:** Achieve a daily app-open rate of >50% among onboarded field installers on workdays within 3 months of general release (post-prototype).
- **OBJ-4:** Increase reorder rate via the Dahl app by 20% relative to current web/phone baseline within 6 months of launch.
- **OBJ-5:** Reduce average time spent on manual time reporting per installer per week by at least 50% versus current manual entry, measured via in-app time-tracking session data.

---

## 3. User Stories

### The Field Installer

#### US-01: Morning briefing
> As a field installer, I want to see a summary of today's jobs, first location, pending material alerts, and recent order status when I open the app in the morning, so that I can plan my day without switching between apps or making phone calls.

**Acceptance criteria:**
- [ ] Home screen displays all jobs scheduled for the current calendar day within 1 second of app open on a cached data set.
- [ ] Each job card shows: job name, client address, scheduled start time, and a status indicator (on track / missing materials / unconfirmed).
- [ ] A "Missing materials" alert appears on a job card when one or more items linked to that job have not been ordered or confirmed as delivered.
- [ ] The first job of the day is highlighted with a one-tap "Navigate" action that opens the address in the device's default maps application.

#### US-02: Pre-site material checklist
> As a field installer, I want to see a checklist of materials needed for each job before I leave for the site, so that I arrive prepared and avoid unnecessary return trips.

**Acceptance criteria:**
- [ ] Each job in My Day has a "Materials" section listing items linked to the project.
- [ ] Each item shows: product name, quantity needed, quantity ordered, and delivery status.
- [ ] Items that are ordered but not yet delivered are marked with a distinct indicator (not colour-only — must include a text label or icon).
- [ ] The checklist is accessible within 2 taps from the job card on the Home screen.

#### US-03: Order product from job context
> As a field installer, I want to order a product directly from within a project or job, so that the order is automatically associated with that project without manual re-entry.

**Acceptance criteria:**
- [ ] Tapping "Order" from within a project context pre-fills the project association on the order form.
- [ ] The order confirmation screen shows the project name and updated budget impact (e.g. "Added to Projekt X — now at 67% of budget").
- [ ] The ordered item appears in the project's materials list within 5 seconds of order confirmation (optimistic update, confirmed on sync).
- [ ] The order is placed with a maximum of 4 taps from the project screen.

#### US-04: AI-assisted problem solving
> As a field installer, I want to describe a technical problem I'm facing on site and receive actionable advice with relevant product recommendations, so that I can resolve issues without calling a colleague or leaving the site.

**Acceptance criteria:**
- [ ] The Work Assistant accepts a text description of a problem and returns a response within 8 seconds on a 4G connection (≥ 20 Mbps down).
- [ ] The response includes at least one actionable step and, where applicable, one or more product recommendations with product name and Dahl SKU.
- [ ] Product recommendations link directly to the order flow for that product.
- [ ] The assistant accepts a photo input (JPEG or PNG, up to 10MB) and incorporates it into the response context.

#### US-05: Barcode scan to order
> As a field installer, I want to scan a product barcode on site and immediately add it to an order, so that I can reorder consumables without searching the catalog manually.

**Acceptance criteria:**
- [ ] The camera viewfinder opens within 1 second of tapping the scan action.
- [ ] A valid EAN-13 or QR barcode is recognised and matched to a Dahl SKU within 2 seconds of the barcode entering the viewfinder frame.
- [ ] If no match is found, the screen displays "Product not found in Dahl catalog" and offers a manual search fallback.
- [ ] A matched product is added to the order form with quantity defaulting to 1, adjustable before confirmation.

#### US-06: Time tracking confirmation
> As a field installer, I want to see pre-filled time entries for my day at end of shift, so that I can confirm my hours with a single tap instead of entering them manually.

**Acceptance criteria:**
- [ ] A time entry summary is presented at the end of the working day (trigger: user-initiated from Home, or at a configurable daily reminder time).
- [ ] Each entry shows: project name, start time, end time, and total hours — pre-filled based on job schedule data.
- [ ] The user can confirm all entries with one tap, or edit individual entries before confirming.
- [ ] Confirmed entries are saved and associated with the correct project within 3 seconds.

#### US-07: Real-time project cost view
> As a field installer, I want to see how much of a project's budget has been spent so far, so that I can make ordering decisions without waiting for end-of-month reconciliation.

**Acceptance criteria:**
- [ ] Each project screen shows a budget bar displaying: total budget (SEK), amount spent to date (SEK), and percentage consumed.
- [ ] The spent amount updates within 10 seconds of an order being placed against that project.
- [ ] When spend reaches 80% of budget, a warning indicator appears (icon + text label, not colour-only).
- [ ] When spend reaches 100% of budget, a blocking alert is shown before the user can place a further order against that project.

---

### The Installation Company Manager

#### US-08: Team order overview
> As a manager, I want to see all orders placed by my team members against each project, so that I can monitor purchasing without requiring individual check-ins.

**Acceptance criteria:**
- [ ] A project view shows all orders placed against that project, grouped by team member.
- [ ] Each order entry shows: product name, quantity, unit price, total cost, and the name of the installer who placed it.
- [ ] The view is filterable by date range (today / this week / this month / custom).
- [ ] The combined view loads within 2 seconds for a project with up to 500 historical orders.

#### US-09: Budget threshold alert
> As a manager, I want to receive a notification when a project reaches 80% of its budget, so that I can review spend before it exceeds the approved amount.

**Acceptance criteria:**
- [ ] A push notification is sent to the manager when any project in their organisation reaches 80% of its set budget.
- [ ] The notification contains: project name, current spend (SEK), total budget (SEK), and a deep link to the project screen.
- [ ] The notification is delivered within 60 seconds of the threshold being crossed.
- [ ] The manager can configure per-project notification thresholds (50%, 80%, 100%) from the project settings screen.

---

## 4. Functional Requirements

### P0 — Must Have

| ID | Requirement | Related User Story |
|---|---|---|
| FR-01 | Home screen displays a daily briefing card showing all jobs scheduled for the current day, with project name, address, start time, and materials alert status for each. | US-01 |
| FR-02 | Each job card on the Home screen includes a one-tap action to open the job address in the device's default maps app (iOS: Apple Maps / Google Maps if installed). | US-01 |
| FR-03 | My Day screen presents jobs for the current day in chronological order, with job name, client address, scheduled time window, and a materials checklist per job. | US-02 |
| FR-04 | The app renders all previously-loaded Home, My Day, and Project screens while offline, using the most recently cached data. Offline state is indicated by a persistent banner. | US-01, US-02 |
| FR-05 | Orders placed while offline are queued locally and submitted automatically within 60 seconds of network connectivity being restored. | US-03 |
| FR-06 | Ordering from within a project context pre-fills the project association and does not require the user to re-select it on the order form. | US-03 |
| FR-07 | The order confirmation screen displays the project name and the updated budget percentage after the order is placed. | US-03 |
| FR-08 | The Work Assistant accepts a text prompt of up to 2,000 characters and returns a response within 8 seconds on a 4G connection (≥ 20 Mbps down). | US-04 |
| FR-09 | Work Assistant responses that include product recommendations display the product name, Dahl SKU, and a tappable link to the order flow for that product. | US-04 |
| FR-10 | The barcode scanner recognises EAN-13 and QR codes and matches them to Dahl SKUs within 2 seconds of the barcode entering the viewfinder. | US-05 |
| FR-11 | Each project screen displays a budget bar showing total budget (SEK), amount spent (SEK), and percentage consumed, updated within 10 seconds of a new order being placed. | US-07 |
| FR-12 | A warning indicator (icon + text label) appears on the project budget bar when spend reaches 80% of the set budget. | US-07 |
| FR-13 | A blocking alert is shown before any order can be placed against a project that has reached 100% of its set budget. The alert includes the project name, current spend, and an option to proceed anyway (requires confirmation). | US-07 |
| FR-14 | The time tracking summary screen presents pre-filled entries for the current day, each showing project name, start time, end time, and hours. All entries can be confirmed with a single tap. | US-06 |
| FR-15 | The app supports iOS 16.0 and above. | All |

### P1 — Should Have

| ID | Requirement | Related User Story |
|---|---|---|
| FR-16 | The Work Assistant accepts a photo input (JPEG or PNG, ≤ 10MB) and incorporates the image into the problem-solving response. | US-04 |
| FR-17 | A "Missing materials" alert appears on a job card when one or more items linked to that job have not been ordered or confirmed as delivered. | US-01 |
| FR-18 | My Day jobs can be reordered via drag-and-drop, with the new order persisted across app sessions. | US-02 |
| FR-19 | A push notification is delivered to the manager within 60 seconds when a project reaches the configured budget threshold (default: 80%). | US-09 |
| FR-20 | The project order view is filterable by date range: today, this week, this month, and a custom date range picker. | US-08 |
| FR-21 | Route nudge: when a Dahl store has a needed item in stock and is within 2km of the route between the installer's current location and their next job, a notification surfaces a one-tap "add stop" action. | US-01 |
| FR-22 | Individual time entries can be edited (start time, end time, project) before confirmation. | US-06 |
| FR-23 | The barcode scanner falls back to a manual text search if no barcode match is found, pre-filling the search field with any decoded text from the barcode. | US-05 |

### P2 — Nice to Have

| ID | Requirement | Related User Story |
|---|---|---|
| FR-24 | End-of-day time tracking summary is triggered automatically by a configurable daily reminder notification at a user-set time. | US-06 |
| FR-25 | Manager can configure per-project budget alert thresholds (50%, 80%, 100%) from the project settings screen. | US-09 |
| FR-26 | The Work Assistant supports voice input (speech-to-text) as an alternative to keyboard entry. | US-04 |
| FR-27 | Project cost view includes a breakdown by category (materials, labour, other) where category data is available. | US-07 |
| FR-28 | Android 12+ support (post-prototype). | All |

---

## 5. Non-Functional Requirements

### Performance
- The Home dashboard must fully render with cached data within 1 second of app open.
- The Home dashboard must fully render with fresh network data within 3 seconds on a 4G connection (≥ 20 Mbps down).
- Product search must return results within 500ms for queries against a catalog of up to 100,000 SKUs.
- The barcode scanner viewfinder must open within 1 second of the scan action being tapped.
- All screens must scroll at 60 fps on an iPhone 12 or newer (A14 Bionic chip or equivalent).
- Work Assistant responses must begin streaming within 8 seconds of prompt submission on a 4G connection.

### Security
- All client-server communication must use TLS 1.3. TLS 1.2 is the minimum fallback; unencrypted HTTP connections are rejected.
- Auth tokens (access and refresh) must be stored in iOS Keychain, not in UserDefaults or any plaintext file.
- Access tokens expire after 15 minutes. Refresh tokens expire after 30 days of inactivity.
- No user PII (name, address, contact details) may appear in application logs or crash reports.
- Location data used for route nudges and time-tracking inference must not be transmitted to Dahl servers without explicit user opt-in, displayed at first use.

### Accessibility
- All interactive elements must have an `accessibilityLabel` readable by VoiceOver where the visible label is not descriptive (e.g. icon-only buttons).
- All text must meet WCAG 2.1 AA minimum contrast ratio: 4.5:1 for body text, 3:1 for large text (≥ 18pt regular or ≥ 14pt bold).
- No information may be conveyed by colour alone — every colour-coded indicator must include an icon or text label.
- All touch targets must be a minimum of 44×44pt to support gloved-hand use in field conditions.
- The app must be fully operable with Dynamic Type sizes up to "Accessibility Extra Large" without horizontal overflow or truncated labels.

### Reliability & Availability
- The backend API must maintain 99.5% uptime measured monthly, excluding planned maintenance windows.
- Offline-queued orders must be submitted automatically within 60 seconds of network connectivity being restored.
- App crashes must not result in loss of locally-queued orders or unsaved time entries. Both are persisted to local storage before any network operation is attempted.
- The app must not display a blank screen for any state: every screen must have a defined loading state, empty state, and error state.

### Scalability
- The backend must support 5,000 concurrent active sessions at prototype launch, scaling to 38,000 concurrent users (Dahl's full craftsperson base) without architectural changes.

---

## 6. Out of Scope

- **Android support** — iOS only for the MVP prototype. Android is P2 for a subsequent release.
- **Full product catalog build-out** — E-Commerce scope is limited to ordering entry points (from project, from AI assistant, from barcode scan). A browsable full catalog is out of scope for the prototype.
- **Background location tracking for automated time detection** — The confirmation UX (pre-filled entries) is in scope; automatic detection of site arrival/departure via background location is not.
- **Invoicing and quoting flows** — Manual quoting and invoice generation remain outside this product's scope.
- **Web application** — No browser-based interface for this release.
- **Integration with systems other than Flexibla Kontoret and the Dahl catalog API** — Third-party ERP, accounting, or payroll integrations are out of scope.
- **Multi-language support** — Swedish is the only supported locale for the prototype.
- **Offline AI responses** — The Work Assistant requires a network connection. There is no offline fallback for AI queries.

---

## 7. Dependencies

| Dependency | Type | Owner | Risk if unavailable |
|---|---|---|---|
| Dahl product catalog API | External API | Dahl IT | Product search, barcode matching, and ordering are non-functional |
| Dahl order placement API | External API | Dahl IT | All ordering flows are non-functional |
| Flexibla Kontoret API | Third-party integration | Flexibla Kontoret team | Job data, project data, and My Day are non-functional; app reverts to manual project entry |
| LLM provider (AI/Work Assistant) | External API | TBD — Anthropic or equivalent | Work Assistant is non-functional; rest of app unaffected |
| iOS push notification service (APNs) | Platform service | Apple | Budget alerts and daily reminders are non-functional |
| Device camera (barcode scanning) | Device capability | iOS | Barcode scan flow is non-functional; manual search fallback available |
| Device location (route nudges) | Device capability / user permission | iOS + user | Route nudge feature is non-functional; rest of app unaffected |

---

## 8. Success Metrics & KPIs

| Metric | Baseline | Target | Measurement method |
|---|---|---|---|
| Daily active users (workdays) | 0 (new product) | >50% of onboarded installers open app before 08:00 on workdays | Analytics: session start time event |
| 30-day retention | 0 (new product) | ≥60% of onboarded installers active after 30 days | Analytics: cohort retention report |
| Reorder rate via app | TBD — current rate via web/phone (establish at kickoff) | +20% within 6 months of launch | Backend: order source attribution |
| Time to place a reorder | TBD — establish via prototype usability testing | ≤60 seconds from app open to order confirmation | UX instrumentation: timed funnel |
| Time tracking adoption | 0% (no current in-app tracking) | ≥70% of active installers submit at least one time entry per week | Analytics: time entry submission event |
| Prototype hypothesis validation | 0 of 5 validated | All 5 hypotheses have documented status (validated / partially validated / open) by end of workshop | Workshop output report |
| Stakeholder demo outcome | — | Concrete decision on next steps (MVP scope + timeline) produced within 2 weeks of demo | Workshop output |

---

## 9. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Flexibla Kontoret API unavailable or not documented | High | High | Design My Day and project screens with a manual data entry fallback; negotiate API access in parallel with prototype build |
| Dahl catalog API has restrictive rate limits or unstable uptime | Medium | High | Implement client-side caching of catalog data with a 1-hour TTL; design barcode flow to work with local cache |
| LLM provider produces VVS-inaccurate responses | Medium | High | Validate LLM domain accuracy with 20 real VVS problem descriptions before prototype demo; add disclaimer to AI responses |
| Offline sync conflict (same order placed twice after reconnect) | Medium | Medium | Implement idempotency keys on all order requests; display duplicate order warning to user before submission |
| Low installer adoption due to onboarding friction | Medium | High | Prototype must include a minimal onboarding flow (≤3 screens) that does not require manual data entry of existing projects |
| Background location permission denied by users | High | Low | Route nudge and time-tracking features degrade gracefully without location permission; no core functionality depends on it |
| Prototype build scope too large for workshop timeframe | High | Medium | Prioritise P0 requirements and H1/H2 hypotheses; H3–H5 flows can be partially mocked if time-constrained |

---

## 10. Open Questions

| Question | Owner | Due |
|---|---|---|
| Does Flexibla Kontoret have a documented, accessible API, or does integration require a partnership negotiation? | Dahl product owner | Before prototype kickoff |
| Which LLM provider and model powers the Work Assistant? VVS-domain accuracy must be validated before the stakeholder demo. | umain tech lead | Week 1 of prototype build |
| What is the data retention and deletion policy for location data used in time-tracking and route nudges? | Dahl legal / privacy | Before any location feature is built |
| Is Android parity required for the stakeholder demo, or is iOS sufficient? | Dahl product owner | Before prototype kickoff |
| What is the existing baseline reorder rate (orders per installer per month) via web and phone channels? Required to set OBJ-4 target. | Dahl data / analytics | Before prototype kickoff |
| Will the prototype connect to Dahl's production catalog API or a sandbox/staging environment? | Dahl IT | Week 1 of prototype build |
| Who is the designated workshop facilitator responsible for completing Section E (Process, Validation & Next Steps) of the original brief? | umain / Dahl | Before workshop |
