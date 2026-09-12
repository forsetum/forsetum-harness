# Adaptive Implementation Readiness Gate — {{PROJECT_NAME}}

> Readiness checkpoint governing the transition between project discovery, planning, and active execution.

## Current Readiness Status: `NOT_READY`

- Allowed States: `NOT_READY` (Default blocker), `READY_FOR_PLAN`, `READY_FOR_IMPLEMENTATION`.
- State transitions require all matching checklist criteria to be verified.

---

## 1. Universal Readiness Checklist (All Projects)

| Check Item | Requirement | Status | Evidence / Notes |
|---|---|---|---|
| Project Mission Defined | `docs/00-overview/mission.md` complete | [ ] | Stated in mission.md |
| Decision Owner Confirmed | `{{DECISION_OWNER}}` identified | [ ] | Recorded in decision-register.md |
| Core Variables Instantiated | Required core variables in `template-variables.md` filled | [ ] | Checked in template-variables.md |
| Protocol Understood | Agent working mode in `AGENTS.md` acknowledged | [ ] | Verified in AGENTS.md |
| Initial Verification Clean | Baseline script execution passes without error | [ ] | Terminal output logged |

---

## 2. Active Domain Module Readiness Checklist

<!-- MODULE_READINESS_START -->
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| *None* | Core | No active domain module checklist attached | [x] | Core only |
<!-- MODULE_READINESS_END -->
