# AI Agent Protocol — {{PROJECT_NAME}} (Universal Core)

> This document establishes mandatory operational rules for autonomous AI agents working in this repository (Hermes Agent, OpenClaw, Claude Code, Cursor, Windsurf, Antigravity, and compatible runtimes).

## 1. Project Context

- Project Name: `{{PROJECT_NAME}}`
- Mission: `{{PROJECT_MISSION}}`
- Primary Decision Owner: `{{DECISION_OWNER}}`
- Active Domain Module: Refer to `docs/INDEX.md` and `docs/08-reference/template-variables.md`

### Mandatory Reading Order

Before proposing or executing any non-trivial modification, the agent MUST read:

1. `README.md` (Project Overview & Quickstart)
2. `docs/INDEX.md` (Master Document Map)
3. `docs/00-overview/mission.md` (Mission, Scope, and Success Metrics)
4. Active Domain Module Documentation listed in `docs/INDEX.md`
5. `docs/08-reference/decision-register.md` (Recorded Architectural Decisions)
6. `docs/09-governance/implementation-readiness.md` (Readiness Gate Status)

## 2. Universal Agent Working Mode

Follow this strict phased loop:
**Understand → Analyze → Discover → Ask/Confirm Decisions → Readiness Gate → Plan → Ask/Confirm Plan → Implement → Verify → Document**.

1. **Understand & Analyze**: Inspect workspace files, active documentation, and past commits.
2. **Discover & Ask**: Identify missing specifications, ambiguities, or trade-offs. Present 2–3 concrete options with one recommended option. Never invent architecture or unconfirmed requirements.
3. **Readiness Gate**:
   - `NOT_READY`: Default state. Implementation is strictly prohibited.
   - `READY_FOR_PLAN`: Allowed only after all core requirements and decisions in `decision-register.md` are confirmed.
   - `READY_FOR_IMPLEMENTATION`: Implementation begins ONLY after the plan is explicitly approved and readiness checklist in `docs/09-governance/implementation-readiness.md` is satisfied.
4. **Implement & Verify**: Work incrementally in bite-sized tasks. Test after each step. Provide automated or documented proof before claiming completion.
5. **Document**: Update `backlog.md`, decision registers, and corresponding module documents.

## 3. Human Escalation & Boundaries

The agent MUST stop and ask for human confirmation when:
1. An action causes irreversible data loss or external destruction.
2. An action requires confidential credentials, API keys, or financial expenditure.
3. A requirement conflicts with recorded decisions in `docs/08-reference/decision-register.md`.
4. The plan encounters an unforeseen blocker where every path forward is a guess.

## 4. Verification and Quality Standard

- All deliverables (code, configurations, copy, scripts) must be verified using local commands before reporting completion.
- When test suites or linting tools exist, run:
  ```bash
  ./scripts/validate-template.sh
  ```
  or corresponding project test commands.
- Never assert success without showing terminal execution evidence.
