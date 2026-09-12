# {{PROJECT_NAME}}

> {{PROJECT_MISSION}}

This repository is governed by an **AI Agent Harness** that coordinates work between human contributors and autonomous AI agents.

---

## 1. Quickstart

### Prerequisites
- Native OS Terminal (Linux, macOS, Git Bash, or Windows PowerShell)
- AI Agent runtime (Cursor, Claude Code, Hermes Agent, OpenClaw, or Antigravity)

### Project Structure
- [`AGENTS.md`](file:///AGENTS.md): Operational instructions, working protocols, and safety gates for AI agents.
- [`QUICKSTART.md`](file:///QUICKSTART.md): 5-minute setup guide for working with AI IDEs.
- [`backlog.md`](file:///backlog.md): Prioritized task roadmap, active tasks, and milestone tracker.
- [`docs/`](file:///docs/): Single source of truth containing mission, reference registries, and governance.
- [`scripts/`](file:///scripts/): Verification and validation tooling.

---

## 2. Working with AI Agents

When opening this project with an AI coding agent:
1. Ensure the agent has read [`AGENTS.md`](file:///AGENTS.md) and [`docs/INDEX.md`](file:///docs/INDEX.md).
2. Check [`docs/09-governance/implementation-readiness.md`](file:///docs/09-governance/implementation-readiness.md) to review current readiness status.
3. Track and pick tasks from [`backlog.md`](file:///backlog.md).

---

## 3. Verification

Run the project verification script to ensure documentation integrity, placeholder registration, and link validity:

**POSIX Shell (Linux / macOS / Git Bash):**
```bash
./scripts/validate-template.sh
```

**Windows PowerShell:**
```powershell
powershell -File .\scripts\validate-template.ps1
```
