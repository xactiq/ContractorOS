# ContractorOS Product Architecture

## 1) Operating model
ContractorOS is a white-label system that moves a contractor from lead to cash collected.

### Primary workflow
1. Lead enters system
2. Contact and property record created
3. Inspection / measurement captured
4. Internal scope and estimate built
5. Carrier estimate imported when applicable
6. Comparison engine identifies gaps and pricing deltas
7. Supplement draft generated
8. Contract / authorization / production docs generated
9. Job status tracked through completion
10. Invoice, payment, and gross profit tracked

## 2) Product modules

### A. CRM & Pipeline
Purpose: track leads, follow-ups, appointments, sales status, and conversion.

Key functions:
- lead intake
- referral source tracking
- next action / follow-up dates
- rep assignment
- status pipeline
- won / lost reporting

### B. Measurement & Scope
Purpose: capture roof or project measurements and turn them into estimate-ready quantities.

Key functions:
- manual measurement entry
- aerial / ESX measurement import support
- takeoff sheet
- trade/system-specific quantity drivers
- scope checklist by loss type or trade

### C. Estimating Engine
Purpose: produce structured estimates from reusable line items and assemblies.

Key functions:
- master line-item library
- assemblies / packaged scopes
- price list by effective month and region
- estimator override controls
- versioned estimate header + estimate lines

### D. Carrier Import & Comparison
Purpose: bring in insurance/carrier estimate data for comparison against internal scope.

Accepted inputs:
- PDF
- XLSX / CSV
- pasted line items
- future direct integrations if available

Key functions:
- parsed carrier estimate header
- imported line-item table
- normalized descriptions / units / categories
- internal-to-carrier item matching review

### E. Supplement Engine
Purpose: turn estimate comparison into fast supplement output.

Key functions:
- missing scope detection
- underpriced item detection
- quantity variance review
- O&P / detach-reset / code item checks
- supplement worksheet generation
- supplement letter generation
- review / approval before export

### F. Production / Job Ops
Purpose: carry sold work through execution.

Key functions:
- job stage tracking
- work orders / purchase orders
- subcontractor pay sheets
- certificate of completion
- lien waiver and cap sheets
- final walk-through checklist

### G. Documents & Reports
Purpose: generate polished outputs from structured data.

Outputs:
- estimate
- supplement package
- contract
- authorization / permission slip
- scope report
- inspection / photo report
- purchase order
- invoice
- completion certificate
- final waiver
- customer summary

### H. Profitability & Scorecards
Purpose: show whether jobs and the company are actually making money.

Key functions:
- labor burden review
- estimated gross profit
- supplement uplift tracking
- invoice vs collected balance
- close rate dashboard
- job margin by rep / trade / source

### I. Admin / White-label Layer
Purpose: make the product sellable to other contractors.

Configurable fields:
- company name
- logo
- colors
- phone / email / website
- license info
- legal text
- payment terms
- trade defaults
- region / pricing settings

## 3) Core design principles
- one source of truth per data type
- forms pull from tables, not the other way around
- pricing lives in pricing tables, not presentation sheets
- supplement logic is reviewable and auditable
- branded outputs are templated, not hand-built each time
- white-label settings stay separate from business data

## 4) Correct import separation
### Measurement import
Use for ESX / aerial / takeoff-related files.
- fills measurement and quantity drivers
- supports scope building
- does not pretend to be carrier estimate import

### Carrier estimate import
Use for PDF / XLSX / CSV / pasted insurer estimate data.
- fills carrier estimate header + lines
- feeds supplement engine

## 5) Sellable product framing
This is not just a roofing workbook.

This is a **Contractor Operating System** for companies that need:
- CRM discipline
- faster estimating
- supplement speed
- cleaner paperwork
- less admin chaos
- better margin visibility

## 6) Suggested edition structure
### Starter
- CRM
- estimate builder
- basic outputs

### Pro
- pricebook
- measurement import
- supplement engine MVP
- profitability dashboards

### Enterprise / White-label
- branding layer
- custom document set
- onboarding / setup service
- regional pricing configuration
