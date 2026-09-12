# Getting Started

## Prerequisites

- Git 2.25 or newer.
- Bash 4.0+ on Linux, macOS, or Git Bash, or PowerShell 5.1+ on Windows.

## Initialize

From the repository root, run the interactive initializer:

```bash
./scripts/init.sh
```

```powershell
.\scripts\init.ps1
```

For a non-interactive setup:

```bash
./scripts/init.sh --lang en --module web-starter --target ./my-project --name "My Project"
```

```powershell
.\scripts\init.ps1 -Lang en -Module web-starter -Target .\my-project -Name "My Project"
```

Use a module name from the [module reference](modules.md). The scripts create
the harness in the target directory and interpolate the project name where
provided.

## Validate

```bash
./scripts/validate-template.sh --all
```

```powershell
powershell -File .\scripts\validate-template.ps1 -All
```

## Next Steps

Open the generated `AGENTS.md`, complete known project context, record human
decisions, and resolve readiness blockers before asking an AI agent to plan or
implement changes.
