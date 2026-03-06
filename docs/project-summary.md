# Project Summary

> Last updated: 2026-03-06

## Problem Statement

Dahl is Sweden's leading wholesale supplier for plumbing, heating, and ventilation (VVS), with SEK 8B in annual revenue, 75 stores, and 38,000 craftspeople served. Despite this dominant market position, Dahl's digital experience is fragmented. Installers currently split their workflow across two separate apps — one for ordering (Dahl) and one for job management (Flexibla Kontoret) — alongside manual steps for quoting, invoicing, and time reporting. The result is friction at every step of the working day.

The broader industry context compounds this urgency: only 20% of building materials companies have fully adopted digital commerce. Competitors like Ahlsell are investing heavily in integrated digital tools, and the window for first-mover advantage is closing. The Dahl app MVP is designed to validate whether a unified, installer-first experience — built around the rhythm of an actual working day rather than around a product catalog — can differentiate Dahl and deepen loyalty among its 38,000 active craftspeople.

## Target Audience

- **The Field Installer** — A VVS tradesperson spending 80%+ of their day on job sites (basements, crawl spaces, new builds), often without reliable signal. They own or work for a small installation firm, are already Dahl customers, and want tools that remove friction without adding admin overhead. Their phone is their primary work tool. Pain points: switching between apps to order and manage jobs, manual time reporting, not knowing project costs until month-end.

- **The Installation Company Manager** — Runs a small-to-medium VVS firm with a team of installers. Cares about project margins, team oversight, and keeping purchasing consolidated. Already uses Flexibla Kontoret and sees clear value in tighter integration between job management and ordering. Pain points: poor visibility into per-project costs in real time, no unified view of team activity and orders.

## Core Value Proposition

The Dahl app replaces a fragmented multi-app workflow with a single tool built around how installers actually work — not how a procurement system is organized. Where competing apps are product catalogs with ordering bolted on, the Dahl app structures the entire experience around the working day: a morning briefing, in-field support, and end-of-day wrap-up. The AI Work Assistant layer goes further, turning the app from a commerce tool into a genuine field companion — answering technical VVS questions, recommending products in context, and automating time tracking. No competitor currently offers this combination at the tradesperson level in the Swedish market.

## Hypotheses & Success Criteria

| Hypothesis | Status | Notes |
|---|---|---|
| H1 — The app can be designed around a working day | Open | Key flows: morning briefing card, pre-site material checklist, route nudges |
| H2 — AI can help solve problems, not just find products | Open | Key flows: AI assistant, photo-based troubleshooting, contextual product recommendations |
| H3 — Real-time cost tracking per project is feasible | Open | Key flows: project dashboard with live budget view, inline cost updates on order, threshold alerts |
| H4 — A lightweight day planner reduces admin burden | Open | Key flows: day view with jobs and locations, delivery integration, quick rescheduling |
| H5 — Time tracking can be automated via inference | Open | MVP prioritises confirmation UX (pre-filled entries) over full auto-detection via background location |

## Success Metrics

- **User engagement:** Daily active use by field installers on workdays; session initiated before leaving for first job site (target: >50% of active users open app before 8am on workdays)
- **Retention:** 30-day retention of >60% among onboarded installers
- **Revenue / Business:** Increase in reorder rate via app vs. current web/phone; measurable shift of orders from competing channels to Dahl app
- **Operational:** Reduction in manual time-reporting steps per installer per week; reduction in end-of-month billing disputes linked to cost visibility
- **Prototype-specific:** Stakeholder validation of direction post-demo; qualitative confirmation from installer user testing that the day-structured experience feels intuitive

## Technical Constraints & Platform Requirements

- **Platform:** Mobile-first (iOS primary for prototype). Must perform under poor signal conditions — offline resilience is a hard requirement for field use.
- **UX constraints:** Large tap targets (field use with gloved hands), minimal text input, readable in bright sunlight. Assume intermittent connectivity.
- **Integrations required:** Dahl product catalog and ordering API; Flexibla Kontoret (job management data); location data for route intelligence and time-tracking inference.
- **AI dependency:** Work Assistant requires an LLM capable of VVS-domain reasoning and product matching. Photo-based troubleshooting requires image understanding.
- **MVP scope boundary:** Full background-location time-tracking detection is out of scope for the prototype. The confirmation UX (pre-filled entry, one-tap approval) is in scope.
- **Prototype realism:** Stakeholder demos require real-sounding data (project names, product names, prices). Generic placeholder data is explicitly out of scope.

## Suggested Scope

| Section | Description |
|---|---|
| **Home** | Personal dashboard: daily briefing card, active projects, pending tasks, recent orders, alerts. Morning-first design with immediate calls to action. |
| **My Day** | Task and schedule planner: jobs for today, locations, order of operations, delivery integration, quick rescheduling. |
| **E-Commerce** | Product catalog entry points: ordering from a project context, from the AI assistant, or via barcode scan. MVP focuses on entry points, not full catalog build-out. |
| **Work Assistant** | AI-powered layer: technical problem solving, contextual product recommendations, photo-based troubleshooting, time tracking confirmation UX, cost allocation per project. |

## Timeline & Milestones

| Milestone | Target | Status |
|---|---|---|
| Project brief finalized | March 2026 | Done |
| Prototype workshop | March 2026 | In Progress |
| Working prototype complete | End of workshop | Pending |
| Stakeholder demo & feedback | Post-workshop | Pending |
| Hypothesis validation report | Post-demo | Pending |
| MVP scoping & next steps | TBD | Pending |

## Open Questions

- Which hypotheses require further testing with real installers before committing to MVP build?
- What is the integration complexity of Flexibla Kontoret — is an API available, or does this require a partnership negotiation?
- What LLM provider and model will power the Work Assistant? VVS-domain accuracy needs to be validated before committing.
- What is the data retention and privacy policy for location data used in time-tracking inference?
- Does the prototype target iOS only, or is Android parity required for the stakeholder demo?
- Who owns the Section E (Process, Validation & Next Steps) completion in the original brief — is there a workshop facilitator assigned?
