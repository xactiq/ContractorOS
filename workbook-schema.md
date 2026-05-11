# ContractorOS Workbook / Database Schema

## Master tabs / tables

### 1. Dashboard
- KPIs: open leads, inspections booked, estimates out, supplements pending, jobs won, unpaid balances, gross profit, close rate

### 2. Leads_CRM
- LeadID
- CreatedDate
- LeadSource
- ReferralSource
- CustomerName
- Phone
- Email
- Address1
- City
- State
- Zip
- LeadStatus
- NextFollowUpDate
- AssignedRep
- Notes

### 3. Contacts
- ContactID
- LeadID
- JobID
- Name
- Role
- Phone
- Email
- PreferredContactMethod
- Notes

### 4. Jobs_Master
- JobID
- LeadID
- CustomerName
- Address1
- City
- State
- Zip
- LossType
- Carrier
- ClaimNumber
- PolicyNumber
- DateOfLoss
- InspectionDate
- Estimator
- SalesRep
- JobStage
- ContractSigned
- ProductionStatus
- InvoiceStatus
- SupplementStatus
- Notes

### 5. Measurements
- MeasurementID
- JobID
- SourceType
- RoofType
- TotalSquares
- RidgeLF
- HipLF
- ValleyLF
- StarterLF
- DripEdgeLF
- RakesLF
- EaveLF
- Stories
- Pitch
- WastePct
- Notes

### 6. Measurement_Import
- ImportID
- JobID
- FileType
- Vendor
- ImportedDate
- RawReference
- ParseStatus
- Notes

### 7. Price_Lists
- PriceListID
- PriceSourceType
- Region
- Zip
- EffectiveMonth
- EffectiveYear
- PriceListCode
- ImportedDate
- Notes

### 8. Line_Item_Library
- ItemCode
- Category
- Subcategory
- Description
- Unit
- TaxFlag
- OandPEligible
- DefaultWastePct
- AliasGroup
- ActiveFlag

### 9. Line_Item_Pricing
- PriceListID
- ItemCode
- UnitPrice
- LaborComponent
- MaterialComponent
- TaxComponent
- EffectiveDate

### 10. Assemblies
- AssemblyID
- AssemblyName
- Trade
- LossType
- Description
- ActiveFlag

### 11. Assembly_Lines
- AssemblyID
- ItemCode
- DefaultQtyFormula
- SortOrder
- Notes

### 12. Estimate_Header
- EstimateID
- JobID
- VersionNumber
- VersionType
- PriceListID
- CreatedDate
- PreparedBy
- EstimateStatus
- Subtotal
- TaxTotal
- OandPAmount
- RCV
- ACV
- Deductible
- NetClaimValue
- Notes

### 13. Estimate_Lines
- EstimateID
- LineNo
- ItemCode
- Description
- Qty
- Unit
- UnitPrice
- TaxAmount
- LaborAmount
- MaterialAmount
- LineTotal
- SourceAssemblyID
- OverrideFlag
- ScopeGroup

### 14. Carrier_Estimate_Header
- CarrierEstimateID
- JobID
- Carrier
- ClaimNumber
- PolicyNumber
- InsuredName
- LossType
- DateOfLoss
- PriceListCode
- ImportSource
- ImportedDate
- Notes

### 15. Carrier_Estimate_Lines
- CarrierEstimateID
- LineNo
- CarrierItemCode
- CarrierDescription
- Qty
- Unit
- UnitPrice
- LineTotal
- Category
- RoomArea
- Notes

### 16. Item_Match_Map
- MatchID
- CarrierEstimateID
- CarrierLineNo
- InternalItemCode
- MatchType
- ConfidenceScore
- OverrideFlag
- ReviewedBy
- ReviewStatus
- Notes

### 17. Supplement_Findings
- FindingID
- JobID
- EstimateID
- CarrierEstimateID
- FindingType
- InternalItemCode
- CarrierLineNo
- ReasonCode
- JustificationTemplate
- QtyDelta
- UnitPriceDelta
- AmountDelta
- EvidenceNote
- Status

### 18. Supplement_Output
- SupplementID
- JobID
- EstimateID
- CarrierEstimateID
- DraftDate
- PreparedBy
- SupplementStatus
- TotalRequested
- LetterPath
- WorksheetPath
- Notes

### 19. Tasks_Followups
- TaskID
- LeadID
- JobID
- TaskType
- DueDate
- Owner
- Priority
- Status
- CompletedDate
- Notes

### 20. Documents_Register
- DocumentID
- JobID
- DocumentType
- VersionLabel
- GeneratedDate
- GeneratedBy
- FilePath
- DeliveryStatus
- Notes

### 21. Invoices_Payments
- InvoiceID
- JobID
- InvoiceType
- Amount
- IssuedDate
- PaidDate
- PaymentMethod
- BalanceRemaining
- Notes

### 22. Profitability
- JobID
- EstimateRevenue
- EstimatedLaborCost
- EstimatedMaterialCost
- SubcontractCost
- GrossProfitDollars
- GrossProfitPct
- CollectedToDate
- OutstandingBalance

### 23. Settings_Lists
Support lists for:
- reps
- lead sources
- carriers
- loss types
- job stages
- payment methods
- document types
- supplement reason codes

### 24. Branding_Settings
- BrandName
- LegalName
- Phone
- Email
- Website
- Address
- PrimaryColor
- SecondaryColor
- LogoPath
- LicenseText
- PaymentTerms
- ContractTextVersion

## Output sheets / views
- Estimate_Print
- Supplement_Worksheet_Print
- Supplement_Letter_Print
- Contract_Print
- Authorization_Print
- Inspection_Report_Print
- PO_Print
- Invoice_Print
- Completion_Certificate_Print
- Lien_Waiver_Print
- Customer_Summary_Print

## Non-negotiable rules
- All print sheets are output-only
- No pricing is manually maintained on print tabs
- No duplicate customer/job entry across modules
- Supplement findings require human review before final output
- Branding and legal text live in separate settings tables
