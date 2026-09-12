# Forsetum Harness Protocol

[![Cross-platform validation](https://github.com/forsetum/forsetum-harness/actions/workflows/validate.yml/badge.svg)](https://github.com/forsetum/forsetum-harness/actions/workflows/validate.yml)

Forsetum Harness Protocol is a governance protocol for controlled, reliable
AI-assisted execution. Forsetum Harness is its local-first public reference
implementation and tooling: it gives repository-aware AI agents the context,
decisions, constraints, readiness gates, and verification workflow they need
before they change a project.

## Quick Start

Clone the public repository and initialize a project-local harness:

```bash
git clone https://github.com/forsetum/forsetum-harness
cd forsetum-harness
./scripts/init.sh
```

On Windows PowerShell:

```powershell
git clone https://github.com/forsetum/forsetum-harness
Set-Location forsetum-harness
.\scripts\init.ps1
```

The initializer supports interactive setup and real options such as `--lang`,
`--module`, `--target`, and `--name`.

## Why Forsetum Exists

AI-assisted work can drift when an agent lacks project context, invents
assumptions, ignores decisions, modifies existing systems without boundaries,
or implements before requirements are ready. Forsetum makes those working
agreements explicit and leaves the resulting artifacts in the project.

## How It Works

The harness is a set of local Markdown governance artifacts and scripts. A
universal governance core is combined with one domain module through a
manifest-driven overlay. The initializer and bundler create a project-local
harness; the validator checks structure, links, and registered placeholders.

## Governance Workflow

```text
Understand → Analyze → Discover → Ask Decisions → Readiness Gate
→ Plan → Implement → Verify → Document
```

The No-Invention Rule requires agents to use known facts and confirmed human
decisions rather than inventing architecture or requirements. The Adaptive
Readiness Gate lets each domain define relevant readiness requirements.

## Core Principles

- Human decisions are authoritative.
- Facts, decisions, constraints, and assumptions remain distinguishable.
- Planning precedes implementation when the readiness gate requires it.
- Verification is evidence, not a promise.
- Governance artifacts stay with the user's project.

## Modules

There are currently 11 modules in both English and Indonesian. Engineering
modules are `web-fullstack`, `web-starter`, `mobile-app`, `cli-automation`,
`app-maintenance`, and `it-infra-ops`. Additional domains are
`landing-page`, `research-analysis`, `content-marketing`, `sales-outreach`,
and `general-office`.

## Supported AI Agents

Forsetum is designed for repository-aware AI agents and coding assistants such
as Claude Code, Cursor, Codex, Copilot, Gemini, Hermes, OpenClaw, and similar
tools. This describes an integration pattern, not official partnership,
certification, endorsement, or guaranteed compatibility with every version.

## Local-First Model

Templates, scaffolding, validation, and generated governance artifacts are
local files. Core public usage does not require a Forsetum account. After the
source repository is retrieved, the local scripts do not require network
access for their documented operations.

## Example Workflow

1. Initialize a harness in the target project.
2. Complete known context and record decisions.
3. Resolve readiness blockers.
4. Ask the agent to read `AGENTS.md`.
5. Require a plan before implementation when the gate requires it.
6. Implement, verify, and document the result.

## Validation

```bash
./scripts/validate-template.sh --all
```

The equivalent Windows command is:

```powershell
powershell -File .\scripts\validate-template.ps1 -All
```

## Forsetum Uses Forsetum

This repository uses `AGENTS.md` and the same governance principles to guide
its own development. The methodology is also used for Forsetum platform work
where applicable; the platform itself is a separate product boundary.

## Documentation

Read the [getting started guide](docs/getting-started.md),
[concepts](docs/concepts.md), [workflow](docs/governance-workflow.md),
[modules](docs/modules.md), and [CLI reference](docs/cli.md).

## Forsetum Platform

Forsetum Harness is the local governance foundation. Forsetum Platform is a
separate higher-level managed experience. Platform capabilities may include
guided discovery, managed harness generation, artifact management, advanced
modules, cloud history, team collaboration, and governance analytics. These
capabilities are not required by the open Harness and are not defined as part
of this repository's local implementation.

## Contributing, Security, and License

See `CONTRIBUTING.md`, `SECURITY.md`, and `CHANGELOG.md` in the public
distribution. The public distribution is licensed under Apache-2.0;
that license applies only to intentionally published Harness files, not to
private Forsetum Platform source code.

Copyright 2026 Rachmanto. See `NOTICE` for attribution.
