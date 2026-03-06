# Design Specification — Dahl App MVP Prototype

**Platform:** iOS 16.0+ (mobile-first, no web/desktop for MVP)
**Locale:** Swedish
**Last updated:** 2026-03-06

---

## 1. App Structure & Navigation

The app uses a **bottom tab bar** with four primary sections matching the PRD's defined areas:

| Tab | Icon | Label |
|---|---|---|
| 1 | House | Hem (Home) |
| 2 | Calendar | Min dag (My Day) |
| 3 | Cart | Beställ (E-Commerce) |
| 4 | Sparkle / Bot | Assistent (Work Assistant) |

**Badge indicators:**
- "Hem" tab: badge count for unread material alerts
- "Min dag" tab: badge count for jobs with missing materials

**Persistent elements:**
- Offline banner (full-width, below nav bar) when device has no network connectivity — includes icon, text label "Offline — visar cachad data", and dismisses automatically on reconnect

---

## 2. Screen Inventory

### 2.1 Onboarding (≤3 screens)

| Screen | Purpose |
|---|---|
| Onboarding-1: Welcome | App intro, value prop in 1–2 sentences |
| Onboarding-2: Sign in | Email / company login — no manual project data entry |
| Onboarding-3: Permissions | Request notifications (required for budget alerts + reminders); location (optional, for route nudge) |

**Constraints:** No manual project data entry during onboarding. Location permission shown with plain-language explanation at first use.

---

### 2.2 Home — Daglig översikt

**Purpose:** Morning briefing. All jobs for today at a glance.

**Layout:**
- Header: date + greeting ("God morgon, [first name]")
- Scrollable list of **Job Cards** for the current calendar day, chronological by start time
- Empty state: "Inga jobb schemalagda idag"

**Job Card anatomy:**
- Job name (primary text)
- Client address (secondary text)
- Scheduled start time
- Status chip: `På spåret` / `Material saknas` / `Ej bekräftat` — chip uses icon + text label (not colour-only)
- For the first job only: prominent **"Navigera"** CTA button (opens device default maps app)
- If status is `Material saknas`: alert row below address showing count of missing items

**States:**
- Loading: skeleton cards (matching card height)
- Cached/offline: renders normally; offline banner displayed
- Error: "Kunde inte ladda jobb — försök igen" with retry button
- Empty: illustration + "Inga jobb schemalagda idag"

**Performance:** Must render from cache within 1s of app open.

---

### 2.3 My Day — Min dag

**Purpose:** Per-job materials checklist before leaving for site.

**Layout:**
- Same chronological job list as Home but with expanded detail per job
- Each job row is expandable (tap to expand) revealing the Materials Checklist inline
- Jobs support drag-to-reorder; order persists across sessions

**Materials Checklist (per job):**
- Header row: "Material" with item count
- Per-item row:
  - Product name
  - Qty needed / Qty ordered (e.g. "3 / 3")
  - Delivery status chip: `Beställt` / `Levererat` / `Ej beställt` — chip uses icon + text label
- Items not yet ordered or delivered use a distinct indicator (warning icon + label, never colour-only)
- "Beställ material" action button at bottom of checklist → enters order flow with project pre-filled

**Accessibility:** Checklist reachable within 2 taps from a job card on Home.

---

### 2.4 Job Detail

**Purpose:** Full view of a single job/project.

**Sections:**
1. **Header:** Job name, client name, address, scheduled time window, status
2. **Budget Bar** (see §2.8)
3. **Materials** — same checklist as in My Day, full-screen
4. **Order history** — orders placed against this project (for manager view: grouped by team member, filterable by date)
5. **Actions:** "Beställ produkt", "Starta tidrapport"

**Navigation entry points:** Tap job card on Home or My Day.

---

### 2.5 Order Flow

**Purpose:** Place an order tied to a project with minimum taps (max 4 from project screen to confirmation).

**Screens in flow:**

**Order-1: Product selection**
- Entry points: (a) "Beställ material" from job/project, (b) barcode scan result, (c) AI recommendation link
- Search field (product name or SKU)
- Scan barcode shortcut button in search bar
- Product list with name, SKU, unit price
- When entered from project context: project association shown as a pre-filled chip at top — not re-selectable

**Order-2: Order form**
- Product name, SKU
- Quantity (stepper, defaults to 1)
- Project association (pre-filled, read-only when entered from project context)
- Delivery address (defaulted to job site address if available)
- "Bekräfta beställning" primary button

**Order-3: Order confirmation**
- Success state: checkmark icon, "Beställning lagd"
- Project name + updated budget: "Tillagt till [Projekt X] — nu på 67% av budget"
- Ordered item appears in project materials list within 5s (optimistic update)
- "Tillbaka till projekt" and "Lägg ny beställning" actions

**Offline behaviour:** Order queued locally; confirmation screen shows "Sparad — skickas när du är online igen." Queued orders auto-submit within 60s of reconnect.

---

### 2.6 Barcode Scanner

**Purpose:** Scan EAN-13 or QR code to add a product to an order without catalog search.

**Layout:**
- Full-screen camera viewfinder
- Scanning reticle overlay (rectangular guide frame)
- "Stäng" (X) button top-left
- Instruction text below reticle: "Rikta mot streckkoden"

**States:**
- Scanning: animated reticle
- Match found: product card slides up from bottom with name, SKU, price; "Lägg till beställning" CTA
- No match: "Produkt hittades inte i Dahl-katalogen" + "Sök manuellt" fallback (search field pre-filled with any decoded text)

**Performance:** Viewfinder opens within 1s; match resolved within 2s of barcode entering frame.

---

### 2.7 Work Assistant — Arbetsassistent

**Purpose:** Describe a technical problem on site, receive actionable advice and product recommendations.

**Layout:**
- Chat-style interface (messages scroll from bottom)
- Input bar at bottom: text field (up to 2,000 chars) + photo attach button + send button
- Assistant messages display in distinct bubble style; user messages right-aligned
- Disclaimer label below first assistant message: "Råd från AI — verifiera alltid med produktdatablad"

**Input modes:**
- Text (keyboard)
- Photo attachment: JPEG/PNG ≤10MB — shows thumbnail in input bar before send; included in message bubble after send

**Assistant response anatomy:**
- Actionable steps (numbered list)
- Product recommendations section (if applicable): card per product showing product name, Dahl SKU, "Beställ" button → enters Order flow

**States:**
- Sending: input bar disabled, spinner in send button
- Streaming response: text appears progressively; loading indicator until first token arrives
- Error (timeout / no network): "Inget svar — kontrollera anslutningen" inline error with retry

**Performance:** Response begins streaming within 8s on 4G (≥20 Mbps down).

---

### 2.8 Project Budget View (component, embedded in Job Detail)

**Purpose:** Real-time spend vs. budget per project.

**Component layout:**
- Label row: "Budget" + total amount (SEK) right-aligned
- Progress bar: filled portion represents % spent
- Sub-label: amount spent + percentage (e.g. "45 200 kr — 67%")
- Below bar: threshold indicators

**Threshold states:**

| Threshold | Visual treatment |
|---|---|
| <80% | Normal — no alert |
| ≥80% | Warning icon (⚠) + label "Nära budgetgräns" alongside bar |
| 100% | Error icon + label "Budget överskriden"; **blocking alert** shown before any new order is placed |

**Blocking alert at 100%:**
- Title: "Budgeten är slut"
- Body: "[Projekt X] — [amount] kr spenderade av [budget] kr"
- Actions: "Avbryt" (primary, safe action) + "Lägg ändå" (destructive, requires second confirmation tap)

**Updates:** Spent amount updates within 10s of an order being placed against the project.

---

### 2.9 Time Tracking — Tidrapportering

**Purpose:** Pre-filled end-of-day time entries confirmable in one tap.

**Entry points:**
- "Bekräfta tid" shortcut card on Home (appears after 15:00 on workdays, or always accessible via job detail)
- Configurable daily push notification (P2)

**Layout:**
- Header: today's date + "Bekräfta dina timmar"
- List of pre-filled time entries, one per job:
  - Project name
  - Start time — End time
  - Total hours (calculated)
  - Edit icon (pencil) per row
- Footer: total hours for the day
- "Bekräfta alla" primary button (confirms all entries in one tap)

**Edit entry sheet (bottom sheet):**
- Project selector (pre-selected)
- Start time picker
- End time picker
- "Spara" button

**States:**
- No entries: "Inga jobb registrerade idag" + manual "Lägg till tid" action
- Saving: button shows spinner; entries confirmed within 3s
- Saved: checkmark animation + "Timmar sparade"

---

### 2.10 Manager Views

**Purpose:** Team order overview and budget monitoring (secondary user, US-08/US-09).

**Team Order Overview (within Job Detail, manager role):**
- Orders grouped by team member
- Per-order row: product name, qty, unit price, total cost, installer name
- Filter bar: Idag / Denna vecka / Denna månad / Anpassat
- Loads within 2s for ≤500 orders

**Budget Threshold Notification (push):**
- Delivered within 60s of threshold crossing
- Contains: project name, current spend (SEK), total budget (SEK), deep link to project screen
- Configurable thresholds: 50% / 80% / 100% per project (P2, from project settings)

---

## 3. Key User Flows

### Flow 1 — Morning briefing
```
App open → Home (cached, <1s)
  → Job card list for today
  → Tap first job "Navigera" → device maps app
```

### Flow 2 — Pre-site materials check
```
Home → tap job card
  → My Day (job expanded) OR Job Detail
  → Materials section
  → Review checklist (≤2 taps from Home)
  → [Missing items] → "Beställ material" → Order Flow (project pre-filled)
```

### Flow 3 — Order from project (max 4 taps)
```
Job Detail [tap 1: "Beställ produkt"]
  → Order-1: Product selection [tap 2: select product]
  → Order-2: Order form [tap 3: "Bekräfta beställning"]
  → Order-3: Confirmation ✓
```

### Flow 4 — AI problem solving → order
```
Work Assistant tab
  → Type problem description (+ optional photo)
  → Receive response with product recommendation
  → Tap "Beställ" on product card → Order Flow
```

### Flow 5 — Barcode scan to order
```
Order-1 search bar → tap scan icon [<1s to open viewfinder]
  → Point at barcode → [<2s] match found
  → Product card: "Lägg till beställning"
  → Order-2: form (qty=1, adjust if needed) → confirm
```

### Flow 6 — End-of-day time confirmation
```
Home → "Bekräfta tid" card (or push notification deep link)
  → Time tracking screen (pre-filled entries)
  → [Optional: tap edit icon → edit sheet → save]
  → "Bekräfta alla" → saved ✓ (within 3s)
```

### Flow 7 — Budget alert response (manager)
```
Push notification: "[Projekt X] vid 80% av budget"
  → Deep link → Job Detail → Budget Bar (warning state)
  → Order history (grouped by installer, filtered this week)
```

---

## 4. Component Inventory

| Component | Used in | Notes |
|---|---|---|
| Job Card | Home, My Day | Status chip, conditional "Navigera" button |
| Status Chip | Job Card, Materials row | Always icon + text, never colour-only |
| Materials Checklist | My Day, Job Detail | Per-item delivery status chip |
| Budget Bar | Job Detail | Three threshold states; blocking alert at 100% |
| Order Form | Order Flow | Project pre-fill, qty stepper |
| Product Card | Order-1, Work Assistant | Name, SKU, price, "Beställ" CTA |
| Barcode Viewfinder | Scanner screen | Full-screen; match/no-match states |
| Chat Bubble | Work Assistant | User (right) / Assistant (left) variants |
| Time Entry Row | Time Tracking | Pre-filled; inline edit via bottom sheet |
| Offline Banner | Global (persistent) | Icon + text; auto-dismisses on reconnect |
| Skeleton Loader | Home, My Day | Matches target card height |
| Empty State | All screens | Illustration + message + optional CTA |
| Error State | All screens | Message + retry button |
| Blocking Alert | Budget (100%) | Two-action: cancel (primary) + proceed (destructive) |
| Bottom Sheet | Edit time entry, product match | Handles safe area; dismissible by swipe or tap outside |

---

## 5. Interaction Patterns

### Loading
- All data-dependent screens show skeleton loaders (not spinners) while loading
- Skeletons match the height and layout of target content

### Empty states
- Every list/screen has a defined empty state: illustration + Swedish copy + optional CTA
- Never show a blank screen

### Error states
- Inline error messages below affected input fields
- Full-screen error state for network failures: icon + message + "Försök igen" button
- Toast notifications for non-blocking errors (e.g. sync failure in background)

### Offline
- Persistent banner shown immediately on loss of connectivity
- Cached screens remain fully navigable
- Order and time entry inputs remain active; queued actions shown with "Väntar på nätverk" indicator
- Queued items auto-submit within 60s of reconnect

### Optimistic updates
- Placed orders appear immediately in project materials list (within 5s); confirmed on sync
- If sync fails, item is marked with a retry indicator

### Gestures
- Swipe-to-dismiss on bottom sheets
- Drag-to-reorder on My Day job list (long-press activates, new order persisted)
- Pull-to-refresh on Home and My Day (triggers fresh network fetch)

---

## 6. Accessibility Requirements

| Requirement | Detail |
|---|---|
| Touch targets | Minimum 44×44pt for all interactive elements (critical for gloved-hand use) |
| Colour-only prohibition | Every colour-coded indicator must include an icon or text label |
| VoiceOver | All icon-only buttons must have `accessibilityLabel`; status chips must convey state in label |
| Contrast | Body text: ≥4.5:1 (WCAG 2.1 AA); large text (≥18pt regular / ≥14pt bold): ≥3:1 |
| Dynamic Type | App fully functional at "Accessibility Extra Large" — no overflow or truncated labels |
| Focus order | Logical reading order for VoiceOver; modal sheets trap focus until dismissed |

---

## 7. Design Constraints & Platform Notes

- **iOS 16.0+ only** — use SwiftUI-native components where possible; no custom nav patterns that conflict with iOS HIG
- **Safe areas** — all content respects top/bottom safe areas (notch, Dynamic Island, home indicator)
- **Dark mode** — not required for MVP prototype, but colour tokens should be defined to support it later
- **Scroll performance** — all scrollable lists must maintain 60fps on iPhone 12 (A14 Bionic) or newer
- **Swedish locale** — all copy in Swedish; date/time formatted for `sv-SE`; currency as `SEK` with space separator (e.g. `45 200 kr`)
- **No web/desktop** — iOS mobile only for this release
