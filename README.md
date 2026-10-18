# Forsetum Harness Protocol

[![Cross-platform validation](https://github.com/forsetum/forsetum-harness/actions/workflows/validate.yml/badge.svg)](https://github.com/forsetum/forsetum-harness/actions/workflows/validate.yml)

Forsetum Harness Protocol is a governance protocol for controlled, reliable
AI-assisted execution. Forsetum Harness is its local-first public reference
implementation and tooling: it gives repository-aware AI agents the context,
decisions, constraints, readiness gates, and verification workflow they need
before they change a project.

## Source and Contribution Ownership

GitLab `iddevops-lab/forsetum-harness` is the canonical product source. GitHub
`forsetum/forsetum-harness` is the public distribution and contribution entry
point. Maintainers review imported GitHub changes in GitLab before synchronizing
the approved canonical SHA downstream. Canonical-source cutover is pending
review of the exact candidate and successful evidence from all five GitHub CI
environments. See the [repository runbook](docs/repository-sync.md),
[contribution guide](CONTRIBUTING.md) and [public decisions](docs/decisions.md).

## Quick Start

### Install as an Agent Skill

For the recommended agent-first workflow, install the curated skill from
GitHub:

```bash
npx skills add forsetum/forsetum-harness
```

To make the skill available across projects, use a global install:

```bash
npx skills add forsetum/forsetum-harness -g
```

Add `-y` to skip confirmation prompts, or use `-a codex` to target Codex
explicitly. The skill provides the adoption workflow, repository inspector,
and bundled runtime generated from the canonical templates and scripts in
this repository.

These are intended public installation commands. The recorded local-path
installation probe timed out; successful installation from the public GitHub
revision has not yet been recorded.

### Use the CLI Directly

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

All 27 canonical modules are approved for public distribution in English and
Indonesian, including `business-growth`. See the [module catalog](docs/modules.md)
for the complete list. The curated package now includes all 27 approved modules and a five-environment
CI workflow. Actual CI results are recorded separately from package generation. This approval does
not publish internal project documentation, customer data, or credentials.

## Agent Runtime Compatibility

Forsetum is designed for repository-aware AI agents and coding assistants such
as Claude Code, Cursor, Codex, Copilot, Gemini, Hermes, OpenClaw, and similar
tools. This describes an integration pattern, not official partnership,
certification, endorsement, or guaranteed compatibility with every version.
The skill uses one entry point to select available manifest profiles. Its
results depend on agent capabilities, permissions, shell, and configuration.
Canonical templates, manifests, CLI, and validators remain authoritative.
Codex and Claude Code remain evaluation candidates; interactive approval and
native Windows PowerShell 5.1 evidence are incomplete. Installation alone
does not establish runtime support.

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
./scripts/validate-harness.sh --all
```

The equivalent Windows command is:

```powershell
powershell -File .\scripts\validate-harness.ps1 -All
```

For complete source and package checks, run `bash scripts/test-product.sh` or
`./scripts/test-product.ps1` in native PowerShell. Build an installable skill to
a new destination with `bash scripts/build-skill.sh --output /tmp/forsetum-skill`
or `./scripts/build-skill.ps1 -Output C:\temp\forsetum-skill`.
See [testing compatibility](docs/testing-compatibility.md) for prerequisites.

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
