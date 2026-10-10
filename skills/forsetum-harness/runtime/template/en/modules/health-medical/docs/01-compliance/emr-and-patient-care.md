# Clinical Operations & Medical Records Governance — {{PROJECT_NAME}}

> Canonical guide for healthcare facility operations, Electronic Medical Record (EMR) documentation standards, health interoperability compliance, and patient data privacy for `{{PROJECT_NAME}}`.

---

## 1. Healthcare Facility & Compliance Profile

| Parameter | Instantiation Value |
|---|---|
| **Healthcare Facility Classification** | `{{HEALTHCARE_FACILITY_TYPE}}` |
| **Electronic Medical Record Standard** | `{{EMR_STANDARD}}` |
| **Clinical Service Flow** | `{{PATIENT_SERVICE_FLOW}}` |
| **Data Privacy Protection Tier** | `{{DATA_PRIVACY_TIER}}` |
| **Medical Director / Authorized Stakeholder** | `{{DECISION_OWNER}}` |
| **Healthcare Service Mission** | `{{PROJECT_MISSION}}` |

---

## 2. Standardized SOAP Clinical Workflow

1. **Patient Intake & Informed Consent:**
   - Identity verification and biometric/insurance linking.
   - Comprehensive written informed consent before invasive diagnostic or therapeutic procedures.
2. **Standardized Clinical Documentation (SOAP):**
   - **S (Subjective):** Chief complaint, history of present illness, allergies, and surgical history.
   - **O (Objective):** Vital signs (BP, Pulse, Temperature, SpO2), physical examination, and lab results.
   - **A (Assessment):** Primary diagnosis and differential diagnoses with ICD-10 coding.
   - **P (Plan):** Evidence-based pharmacological prescription, dietary orders, and discharge instructions.

---

## 3. Patient Privacy Safeguards & Regulatory Compliance

- [ ] Health data interoperability endpoints validated via national sandbox test suites.
- [ ] Strict role-based access control (RBAC) with immutable access logging for all clinical chart views.
- [ ] Explicit prohibition against transmitting raw unmasked Protected Health Information (PHI) to third-party public AI providers.
- [ ] Clinical sentinel incident reporting register and root cause analysis SOP active.
