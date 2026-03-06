# PRD — Dahl App MVP Prototype

**Goal:** Ship a working prototype of the Dahl installer app that validates five product hypotheses and produces a concrete stakeholder decision on next steps.

---

## Core User

**Field VVS installer** — splits time across multiple jobs per day, orders materials from Dahl, currently uses two separate apps and manual processes.

**Primary pain point:** Fragmented tools force context-switching and manual re-entry for job management, ordering, and time reporting.

---

## MVP Features

### 1. Daily Briefing (Home)
Show all jobs for today with status, address, and materials alert on app open.

- [ ] All today's jobs load within 1s from cache
- [ ] Each card: job name, address, start time, status (on track / missing materials)
- [ ] One-tap "Navigate" on first job opens device maps app

### 2. Materials Checklist (My Day)
Per-job checklist of needed materials before leaving for site.

- [ ] Materials section per job: product name, qty needed, qty ordered, delivery status
- [ ] Accessible within 2 taps from job card
- [ ] Undelivered items use icon + text label (not colour-only)

### 3. Order from Job Context
Place an order tied to a project without re-entering project details.

- [ ] Ordering from project pre-fills project association
- [ ] Confirmation shows project name + updated budget %
- [ ] Ordered item appears in project materials list within 5s
- [ ] Max 4 taps from project screen to order confirmation

### 4. Work Assistant (AI)
Describe a site problem, get actionable advice and product recommendations.

- [ ] Accepts text (up to 2,000 chars), responds within 8s on 4G
- [ ] Response includes at least one action step + product recommendation with Dahl SKU
- [ ] Product recommendation links directly to order flow
- [ ] Accepts photo input (JPEG/PNG, ≤10MB)

### 5. Barcode Scan to Order
Scan a product on site to add it to an order instantly.

- [ ] Camera opens within 1s of tapping scan
- [ ] EAN-13 or QR matched to Dahl SKU within 2s
- [ ] No match shows "Product not found" + manual search fallback
- [ ] Matched product added to order form with qty defaulting to 1

### 6. Time Tracking Confirmation
Pre-filled end-of-day time entries confirmable in one tap.

- [ ] Summary shows: project, start time, end time, hours — pre-filled from job data
- [ ] Confirm all entries with one tap
- [ ] Individual entries editable before confirmation
- [ ] Confirmed entries saved to correct project within 3s

### 7. Project Budget View
Real-time spend vs. budget per project.

- [ ] Budget bar: total (SEK), spent (SEK), % consumed
- [ ] Updates within 10s of an order being placed
- [ ] Warning at 80% (icon + text label)
- [ ] Blocking alert at 100% before any further order (with override requiring confirmation)

---

## Critical NFRs

- **Offline:** Home, My Day, and project screens render from cache; offline queued orders submit within 60s of reconnect
- **Security:** TLS 1.3, tokens in iOS Keychain, no PII in logs
- **Accessibility:** 44×44pt touch targets, no colour-only indicators, WCAG 2.1 AA contrast
- **Platform:** iOS 16.0+

---

## Out of Scope

- Manager views (team orders, budget alerts)
- Android support
- Browsable product catalog
- Background location / automated time detection
- Invoicing, quoting, web app
- Multi-language (Swedish only)
- Offline AI responses

---

## Success Metrics

| Metric | Target |
|---|---|
| Hypothesis validation | All 5 hypotheses have documented status by end of workshop |
| Stakeholder outcome | Concrete next-steps decision within 2 weeks of demo |

---

## Key Dependencies

| Dependency | Risk if unavailable |
|---|---|
| Dahl catalog + order API | Search, barcode, and ordering non-functional |
| Flexibla Kontoret API | Job/project data non-functional; fallback: manual entry |
| LLM provider | Work Assistant non-functional; rest of app unaffected |
