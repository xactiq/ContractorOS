# ContractorOS — Claude Context

## What this project is
A white-label contractor operating system for insurance-restoration and general contractors. Logan sells this to contractors as a product (not a custom build for one client). Goal: replace broken spreadsheets with one system for lead → estimate → supplement → job → invoice.

## Owner
Logan McEntire — McEntire Construction, Gustine TX. He is the builder and seller of this product, not the end user.

## Product has two tracks

### Track 1: Web app (primary — what's actively being built)
- `index.html` — single-file React + Supabase app. Tabs: Dashboard, Pipeline, Clients, Jobs, Estimates, Supplements, Docs.
- `schema.sql` — Supabase Postgres schema (clients, jobs, estimates, supplements, docs tables)
- Supabase project is already set up (URL and anon key are in index.html)
- Deploy target: Vercel (static site hosting)
- Status: **Supabase connected, GitHub push + Vercel deploy still needed**

### Track 2: XLSX workbook (secondary)
- `v1/ContractorOS_v1.xlsx` — skeleton workbook with all tabs stubbed out (headers only, no formulas or formatting)
- `workbook-schema.md` — full 24-tab schema spec
- Status: skeleton only, needs formatting, dropdowns, formulas, print sheets

## Immediate next steps (web app)
1. `git init` in this folder, push to GitHub
2. Connect GitHub repo to Vercel → deploy
3. Optional: set up custom domain (e.g. crm.xactiq.net) in Vercel

## Immediate next steps (XLSX)
Per `v1/REVIEW-NOTES.md`:
- better formatting
- dropdowns
- starter formulas
- print/output sheets
- supplement worksheet layout

## Key files
- `index.html` — full web app source
- `schema.sql` — Supabase schema (already run)
- `build-roadmap.md` — phased build plan
- `workbook-schema.md` — full tab/field spec
- `offer-and-packaging.md` — how to sell it, pricing tiers
- `product-architecture.md` — system design

## Selling model
- Template License: $997–$2,500
- Setup + Customization: $2,500–$7,500
- Managed Optimization: monthly/quarterly retainer

## Important restraints
- Do not over-engineer. Keep it sellable and repeatable.
- Supplement speed is the killer feature — lead with that in any sales asset.
- White-label first: branding, logo, company name must be swappable without breaking the engine.

## ⚠️ Known issue: this repo has drifted from production (found 2026-08-09)
`app.xactiq.net` and its Supabase project (`qjzaxgfwbevztzqlgbwp`) no longer match what's
checked in here. The live app is a multi-tenant SaaS (Stripe subscriptions in `profiles`,
`org_members`, `tasks`, `leads`, `feedback`, `changelog`, RLS enabled on every table) — not
the single-tenant `index.html`/`schema.sql` prototype in this repo (hardcoded to "McEntire
Construction", RLS disabled). The live schema has ~20 tables this repo has never seen.

Consequence: `.github/workflows/daily-diagnostics.yml` has been diagnosing the *stale
prototype* every morning, not the real product, so its RLS/growth-count checks are
meaningless. That produced ~29 consecutive unmerged PRs (June 23 – Aug 8) all titled some
variant of "fix false-positive warnings in daily diagnostics" and ~65 open
`diagnostic-report` issues — none of it addresses a real problem, because the target file
isn't what's deployed.

**Do not open another "fix diagnostics false positive" PR.** The fix isn't in this repo —
it's pointing diagnostics at the real production repo/schema, or retiring this workflow.
That decision (and cleanup of the stale PRs/issues) needs Logan's sign-off; flag it, don't
action it solo.
