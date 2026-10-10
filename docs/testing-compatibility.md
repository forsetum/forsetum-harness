# Testing Compatibility

The public package includes 27 modules in English and Indonesian and one
self-contained skill runtime. Run its smoke gate from any working directory:

```bash
bash /path/to/forsetum-harness/scripts/test-compatibility.sh
```

On Windows PowerShell 5.1 or PowerShell 7:

```powershell
& C:\path\to\forsetum-harness\scripts\test-compatibility.ps1
```

The gate checks exact module inventory, complete metadata fields, byte parity
between templates/scripts and bundled runtime, and all 54 language/module
combinations with actual initializer and directory bundler executions. It also
checks installed handoff cancellation and rejection of incomplete conflict
approval without changing the target. All targets are isolated temporary
fixtures, including paths with spaces.

GitHub Actions runs Ubuntu Bash, macOS Bash 4+, Windows Git Bash, Windows
PowerShell 5.1, and Windows PowerShell 7 separately. The workflow requires all
jobs to pass and uploads OS/shell versions, commit IDs, and logs even after a
failure. Source-maintainer CI additionally checks exporter private boundaries;
the public package tests itself without depending on that private exporter.

A passing job proves the covered checks on its recorded OS/shell version.
Windows Server runner evidence does not establish Windows desktop 10/11
compatibility. These deterministic fixtures do not establish conversational
agent approval UX or guarantee behavior across untested agent configurations.
