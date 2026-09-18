# Forsetum Harness Protocol v0.1.0

First public release of the Forsetum Harness Protocol and its reference
tooling.

## Highlights

- Governance protocol for controlled, reliable AI-assisted execution.
- Explicit context, decisions, constraints, readiness gates, planning,
  verification, and documentation.
- No-Invention Rule and Adaptive Readiness Gate guidance.

## Governance Model

The harness keeps facts, decisions, constraints, and assumptions visible to
the agent. Work proceeds through a governed workflow before implementation and
is verified and documented afterward.

## Included Tooling

- Bash and PowerShell initialization and bundling.
- Template validation and static preview generation.
- Local-first, zero-dependency repository tooling.

## Modules

The English and Indonesian template libraries each contain 11 domain modules,
combined with a universal governance core.

## Supported Environments

Bash 4.0+ is supported on Linux, macOS, and Git Bash. PowerShell 7.6.6 has
passed the handoff regression test on Linux. Windows PowerShell 5.1 and native
Windows path behavior remain untested and are not claimed as supported here.

## Known Limitations

- This is an early 0.x release; protocol and tooling details may evolve.
- Agent behavior depends on whether the selected AI tool reads and follows
  repository governance instructions.
- The protocol does not guarantee elimination of hallucinations.
- Vendor-specific agent integrations may vary.
- Forsetum Platform managed/cloud capabilities are a separate product
  boundary and are not required by this repository.

## Getting Started

Clone the repository and run `./scripts/init.sh`, or use
`.\scripts\init.ps1` on Windows PowerShell. See the getting started guide
for options and examples.

## License

The public distribution is licensed under Apache-2.0. Copyright 2026 Rachmanto;
see `NOTICE` for attribution. This license boundary applies to the published
Forsetum Harness distribution and does not license private Forsetum Platform
source code.
