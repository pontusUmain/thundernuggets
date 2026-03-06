# Dahl MVP — Project Brief

## Background & Context

Dahl is Sweden's leading wholesale supplier for plumbing, heating, and ventilation (VVS), with SEK 8B in annual revenue, 75 stores, and 38,000 craftspeople served across the country.

Despite this dominant market position, Dahl's digital experience is fragmented. Installers currently split their workflow across two separate apps — one for ordering (Dahl) and one for job management (Flexibla Kontoret) — alongside manual steps for quoting, invoicing, and time reporting.

The broader industry context compounds this: only 20% of building materials companies have fully adopted digital commerce. Competitors like Ahlsell are investing heavily, and the window for first-mover advantage is closing.

**The goal of this MVP is twofold:**
1. Validate a set of hypotheses about what a unified installer experience could look like if built around the actual rhythm of a working day.
2. Produce a working prototype that demonstrates the core experience and sparks a concrete conversation about direction, scope, and next steps.

---

## Target Groups

### The Field Installer
A VVS tradesperson spending 80%+ of their day on job sites — basements, crawl spaces, new builds — often without reliable signal. They own or work for a small installation firm, are already Dahl customers, and want tools that reduce friction without adding admin. Their phone is their office.

### The Installation Company Manager
Runs a small-to-medium VVS firm with a team of installers. Cares about project margins, team oversight, and keeping purchasing consolidated. Already uses Flexibla Kontoret and sees real value in tighter integration between job management and ordering.

---

## Prototype Scope

The prototype covers four core sections of the app, each mapped to a distinct part of the installer's workflow.

### 1. Home
A personal dashboard giving the installer an at-a-glance summary of their day — active projects, pending tasks, recent orders, and alerts. The entry point that orients everything else. On mobile, this should function as a "morning briefing": a single, human-readable summary of the day ahead with immediate calls to action.

### 2. My Day
A task and schedule planner built around the working day. What jobs are on today, where, and in what order. The goal is to give installers a structured view before they leave in the morning and a way to stay on top of it while in the field.

### 3. E-Commerce
Dahl's product catalog, ordering, and reorder flows — unified and optimized for mobile use on the job site. Includes barcode scanning and AI-powered visual product search. For the MVP, focus on the *entry points* into ordering (from a project, from the AI assistant, from a scan) rather than building out the full catalog.

### 4. Work Assistant
The intelligent layer of the app. Project notes, AI-powered problem solving, product recommendations in context, time tracking, and cost allocation per project. This is where the app goes beyond commerce and becomes a genuine work tool.

---

## Hypotheses to Validate

The following hypotheses frame what the prototype should explore and what the team should aim to validate through user testing and stakeholder feedback.

### H1 — The app can be designed around a working day
An installer's needs follow a clear rhythm: preparing before leaving, executing on site, and wrapping up after. An app structured around this arc will feel intuitive in a way that generic B2B tools never do.

**Key flows to prototype:**
- Morning briefing card: today's jobs, first stop, one-tap alerts for missing materials
- Pre-site material checklist linked to each job, auto-generated from project data
- Route intelligence: if a needed item is available at a store on the way to a job, surface it as a nudge with a one-tap "add stop" action

### H2 — We can help installers solve problems, not just find products
The real need isn't always "find this SKU." It's "this fitting doesn't match — what do I do?" An AI-powered assistant that understands VVS context can answer that, and surface the right product as part of the answer.

**Key flows to prototype:**
- AI assistant that takes a problem description and returns actionable advice
- Product recommendations tied to the problem context
- Photo-based troubleshooting: snap a photo, get guidance and matching products

### H3 — We can help users keep track of cost per project in real time
Installers rarely know their margin until the job is done. By automatically tagging every order, material, and hour to a project, the app can give a live cost-vs-budget view that removes end-of-month surprises.

**Key flows to prototype:**
- Project dashboard: materials ordered so far vs. budget
- Inline cost update triggered by placing an order ("Added to Projekt X — now at 67% of budget")
- Alerts when nearing budget thresholds

### H4 — We can help users plan and track their day
Between multiple job sites, supply runs, and ad-hoc tasks, the working day is hard to manage. A lightweight planner connected to projects and orders can bring structure without adding admin burden.

**Key flows to prototype:**
- Day view with jobs, locations, and order of operations
- Integration with project data and upcoming deliveries
- Quick rescheduling and task prioritization

### H5 — Routine tasks like time tracking can be automated
Time reporting is universally disliked and inconsistently done. Using location and job data, the app can infer when an installer arrives and leaves a site, and reduce manual logging to a single confirmation tap.

**Key flows to prototype:**
- End-of-day summary with pre-filled time entries per project
- One-tap confirmation instead of manual entry

> **Note for MVP:** Full auto-detection via background location is technically complex to prototype. Prioritise the confirmation UX — show a pre-filled entry and let the user approve it — rather than building the detection layer.

---

## Design Principles

- **Mobile-first, field-ready.** Assume poor signal, gloved hands, and bright sunlight. Large tap targets, minimal text input, offline resilience.
- **The app should feel like it already knows your day.** Proactive over reactive. Surface the right information before the user has to ask.
- **Reduce admin, don't add it.** Every feature should remove a step from the installer's day, not introduce a new one.
- **Realism matters in the prototype.** Use real-sounding project names, product names, and prices. Generic placeholders undermine stakeholder confidence.
