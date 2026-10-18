# Testing Compatibility

The public package includes 27 modules in English and Indonesian and one
self-contained skill runtime. Run the complete standalone product suite from any working directory:

```bash
bash /path/to/forsetum-harness/scripts/test-product.sh
```

On Windows PowerShell 5.1 or PowerShell 7:

```powershell
& C:\path\to\forsetum-harness\scripts\test-product.ps1
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
failure. The suite uses only this checkout and native shell utilities. It has no
private exporter, private documentation, package registry, or network dependency.

A passing job proves the covered checks on its recorded OS/shell version.
Windows Server runner evidence does not establish Windows desktop 10/11
compatibility. These deterministic fixtures do not establish conversational
agent approval UX or guarantee behavior across untested agent configurations.

## Native package builder

Build one installable skill directory from the canonical `scripts/` and
`template/` sources. The destination is the directory containing `SKILL.md`;
choose a new path whose parent already exists:

```bash
bash /path/to/forsetum-harness/scripts/build-skill.sh --output /tmp/forsetum-skill
```

```powershell
& C:\path\to\forsetum-harness\scripts\build-skill.ps1 -Output C:\temp\forsetum-skill
```

Both builders preserve the canonical runtime bytes and include the inspector,
native decision handoffs, adapters, and references. They require no external
runtime dependency. Existing output is rejected, including empty directories
and symlinks. Output within product source directories and symlink or junction
parents is rejected. macOS system `/tmp` and `/var` aliases are supported.
Temporary staging is unique to the invocation and is the only tree removed on
failure. A copy failure after claiming the new destination leaves that partial
output for inspection; rerun with a new path.

The checked-in `skills/forsetum-harness/runtime/` is generated output. After
editing canonical tooling or templates, build to a new temporary skill directory,
review its runtime diff, then copy that runtime into the checked-in runtime.
Run the suite afterward: it compares the complete checked-in runtime with a
fresh build and rejects drift. Do not author the runtime independently.

## Test coverage

`scripts/test-product.sh` runs template validation, package path safety,
inspector and handoff fixtures, contract and adapter checks, catalog mutation
fixtures, business-growth assembly, installed runtime behavior, and the
54-case compatibility gate. `scripts/test-product.ps1` runs native validation,
package build and path safety, decision handoff backup fixtures, and all 54
combinations under the selected PowerShell interpreter.

Each compatibility case checks actual module document links in the stitched
index, every manifest variable key in the registry, and every readiness check
and domain guardrail in the generated readiness document. Equality between
initializer and bundler output is checked in addition to those assertions.
The Bash stitching regression injects failures at each of the three stitching
commands and requires a nonzero result before any target export. A separate
fixture rejects multiline `awk -v` tables to exercise portable table passing.

The suites build isolated installable skills and exercise inspection,
cancellation, rejection of incomplete approval, and runtime delegation outside
the source cwd. They do not execute a live `npx` installer or establish GitHub
installation success. Codex and Claude Code remain Candidates; see the
[adapter evidence boundary](agent-platform-compatibility.md).
