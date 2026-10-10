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

From the source checkout, validate the template library and root harness:

```bash
./scripts/validate-harness.sh --all
```

```powershell
powershell -File .\scripts\validate-harness.ps1 -All
```

After completing project context and resolving generated placeholders, validate
the target as an instantiated project:

```bash
./scripts/validate-harness.sh --target ./my-project --mode instantiated
```

```powershell
powershell -File .\scripts\validate-harness.ps1 -Target .\my-project -Mode instantiated
```

Validation provides evidence for the checks it runs. Agent behavior depends on
runtime capabilities, permissions, shell, and configuration; native Windows
PowerShell 5.1 evidence remains pending.

## Next Steps

Open the generated `AGENTS.md`, complete known project context, record human
decisions, and resolve readiness blockers before asking an AI agent to plan or
implement changes.
