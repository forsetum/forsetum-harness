# Bug Triage & Regression Prevention SOP — {{PROJECT_NAME}}

## 1. Bug Remediation Workflow

Every reported bug in `{{HOST_APPLICATION}}` must be resolved following 4 structured phases:
**Reproduction → Root Cause Analysis (RCA) → Surgical Patch → Non-Regression Verification**.

## 2. Four-Phase Procedure

### Phase 1: Bug Reproduction
- Never attempt a code change before reliably reproducing the defect in staging or a local environment.
- Capture: Exact input payloads, initial data state, full stack traces, and expected behavior.

### Phase 2: Root Cause Analysis (RCA)
- Trace execution paths across `{{PRIMARY_LANGUAGE}}` sources.
- Clarify whether the issue originates in custom modules, configuration drift, legacy data corruption, or upstream code.

### Phase 3: Minimal Surgical Patch
- Keep code diffs minimal and targeted (*atomic & surgical*).
- Refrain from opportunistic refactoring during emergency bug fixes.

### Phase 4: Non-Regression Verification
Prior to deploying into production:
- [ ] The reproduction test case now passes consistently.
- [ ] Standard user flows surrounding the touched component operate normally.
- [ ] No database query anomalies or resource spikes are introduced.
