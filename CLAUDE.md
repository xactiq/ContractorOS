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
