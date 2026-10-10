# Inbound Receiving & Quality Inspection — {{PROJECT_NAME}}

> Canonical document establishing inbound freight receipt workflows, quality control (QC) sampling protocols, and non-conformance reporting (NCR) procedures for `{{PROJECT_NAME}}`.

---

## 1. Supply Chain Operational Profile

| Parameter | Value |
|---|---|
| **Operational Scope** | `{{SUPPLY_CHAIN_SCOPE}}` |
| **Inventory Valuation Method** | `{{INVENTORY_METHOD}}` |
| **Warehouse Management System** | `{{WAREHOUSE_SYSTEM}}` |
| **Outbound Distribution Model** | `{{DELIVERY_MODEL}}` |
| **Logistics Decision Authority** | `{{DECISION_OWNER}}` |

---

## 2. Inbound Receiving Standard Operating Procedure

Every supplier consignment undergoes a 5-step receiving and validation protocol:

```mermaid
graph LR
    A["1. Document Verification (PO & BOL/Packing Slip)"] --> B["2. Freight Unloading & Staging"]
    B --> C["3. Physical Count & Seal Audit"]
    C --> D["4. QC Inspection & Sampling"]
    D --> E["5. System Ingest (GRN in WMS) & Put-away"]
```

| Step | Core Activity | Reference Document | Responsible Role | SLA Tolerance |
|---|---|---|---|---|
| **1. Documentation** | Cross-check packing slip / Bill of Lading against system Purchase Order | PO & Vendor Packing Slip | Receiving Admin | Max 30 mins |
| **2. Unloading & Staging** | Unload freight to designated receiving dock staging area | Inbound Delivery Manifest | Material Handlers | Fleet volume dependent |
| **3. Quantity Audit** | Verify carton counts, pallet integrity, container seal IDs, and lot numbers | Receiving Tally Sheet | Warehouse Checker | Day of arrival |
| **4. QC Sampling** | Physical attribute testing, expiry date checks, and functional audits | QC Inspection Form (AQL) | Inbound QC Inspector | Max 4 working hours |
| **5. GRN & Put-away** | Generate Goods Receipt Note (GRN) in WMS and allocate to bin location | GRN & Bin Location Label | Forklift / Floor Staff | Same day (T+0) |

---

## 3. Quality Control (QC) Sampling Protocol

Receipt inspection adheres to standardized *Acceptable Quality Level* (AQL) thresholds:

| Item Classification | QC Test Methodology | Sample Size Protocol | Maximum Defect Limit (AQL) |
|---|---|---|---|
| **Raw Materials / Critical Parts** | Engineering specs, dimensional tolerance, functional stress | 10% per arrival lot | 0% critical defects (Zero Tolerance) |
| **Finished Goods / Retail Items** | Visual packaging check, barcode scannability, basic features | Random sampling (ANSI/ASQ Z1.4 Level II) | Major defects ≤ 1.5%, Minor ≤ 4.0% |
| **Packaging & Consumables** | Burst strength, cleanliness, visual alignment | 5 units per pallet | Max 2.5% defect rate |

---

## 4. Non-Conformance Handling & NCR Reporting

When discrepancies, freight damage, or QC testing failures occur:

1. **Immediate Physical Quarantine:** Affix prominent red `REJECT / QUARANTINE` tags and move goods to Quarantine Zone D.
2. **NCR Issuance:** Inbound QC logs a formal Non-Conformance Report (NCR) within 2 hours of discovery.
3. **Supplier Escalation:** Procurement alerts the supplier within 24 hours providing:
   - Photographic evidence of damaged cartons or defect manifestations.
   - Associated Purchase Order and Packing Slip references.
   - Driver-acknowledged discrepancy notice.
4. **Discrepancy Resolution Paths:**
   - **Full Rejection:** Supplier replaces the complete damaged consignment.
   - **Partial Acceptance:** Release passed lots while docking invoice amounts for rejected quantities.
   - **Emergency Concession:** Conditional acceptance requiring explicit written authorization from `{{DECISION_OWNER}}`.
