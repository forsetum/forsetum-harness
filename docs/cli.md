# CLI Reference

The current CLI surface is a set of Bash and PowerShell scripts, not a
unified `forsetum` command.

## init

Initializes a harness in a target project. Bash:

```bash
./scripts/init.sh --lang en --module web-starter --target ./my-project --name "My Project"
```

PowerShell:

```powershell
.\scripts\init.ps1 -Lang en -Module web-starter -Target .\my-project -Name "My Project"
```

Options are language, module, target directory, and project name. Interactive
mode is available with no options. Invalid arguments return a non-zero status.

## bundle

Combines core and one module into a directory or ZIP:

```bash
./scripts/bundle.sh --lang en --module web-starter --name "My Project" --output ./dist/my-project.zip
```

```powershell
.\scripts\bundle.ps1 -Lang en -Module web-starter -Name "My Project" -Output .\dist\my-project.zip
```

Use `--dir`/`-Dir` instead of `--output`/`-Output` for an uncompressed
directory. The module is required and exactly one output form is required.

## validate-template

Validates template files, manifests, links, and placeholder registration:

```bash
./scripts/validate-template.sh --all
./scripts/validate-template.sh --template en
```

```powershell
powershell -File .\scripts\validate-template.ps1 -All
powershell -File .\scripts\validate-template.ps1 -Template en
```

Validation exits non-zero on an error.

## build-previews

Builds the current `web-starter` preview ZIPs:

```bash
./scripts/build-previews.sh
```

```powershell
.\scripts\build-previews.ps1
```

This writes generated artifacts under `dist/previews/` in the source
repository. It is not a public export command.
