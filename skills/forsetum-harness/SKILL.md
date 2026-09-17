---
name: forsetum-harness
description: Safely guide adoption of a Forsetum Harness in an existing repository by inspecting context, recommending a canonical profile, previewing changes, and requiring explicit conflict decisions before bootstrap.
---

# Forsetum Harness Adoption

Use this skill when a user wants to add or evaluate a Forsetum Harness in a
repository. The skill is an adoption interface; the canonical templates,
manifests, initializer, and validator remain authoritative.

## Hard Safety Gate

Before any write or bootstrap command:

1. Inspect the target repository read-only.
2. Identify the canonical template source and read its manifest to obtain the
   available language and module IDs. Never invent a profile or module ID.
3. Recommend a profile from observed repository signals, then ask the user to
   choose or confirm it.
4. Show a preview containing the selected language, module, target path, files
   that would be created or changed, and the exact initializer/validator
   commands.
5. Check for existing governance paths, including `AGENTS.md`, `README.md`,
   `backlog.md`, `mission.md`, `governance.md`, and `docs/`.

If any governance path exists or overlaps the preview, stop and report:

- the exact conflicting path;
- whether the initializer would create, update, or overwrite it;
- the effect on the existing project; and
- the available decisions: cancel, choose another target, or explicitly
  approve the displayed overwrite/merge action.

Do not run bootstrap, use `--force`, merge, delete, rename, or modify any
conflicting file until the user has explicitly decided for every reported
conflict. A cancellation or deferral must leave the target unchanged.

## Approved Flow

For deterministic inspection before the conversational approval gate, use the
bundled read-only adapter. In an installed package, `<skill-dir>` is the
directory containing this `SKILL.md`; always pass its package-local runtime
as `--template-root`:

`bash <skill-dir>/scripts/inspect-repository.sh --target <dir> --lang <id|en> --module <module_id> --template-root <skill-dir>/runtime`

When run from the canonical source checkout, the repository root may be
passed explicitly as `--template-root` for local development. The installed
workflow must not resolve scripts or templates from the caller's cwd, a
private checkout, or a network.

The bundled inspector also selects its package-local `runtime/` automatically
when that directory exists, so an installed package remains usable from any
working directory. Keep `--template-root` explicit in agent-generated commands
and use it to override the source-checkout fallback during local development.

Exit code `0` means `PROCEED_PENDING_APPROVAL`; exit code `3` means
`CONFLICT_REVIEW` and requires a decision; exit code `2` means the inspection
inputs or manifest are invalid. The adapter must finish before any initializer
command is considered.

After the user explicitly approves the displayed action, delegate deterministic
file generation to the existing initializer bundled in the installed
package's runtime:

- Unix-like environments: `<skill-dir>/runtime/scripts/init.sh --lang <id|en> --module <module_id> --target <dir> --name <name>`
- Windows PowerShell: `<skill-dir>/runtime/scripts/init.ps1 -Lang <id|en> -Module <module_id> -Target <dir> -Name <name>`

Use `--force` or `-Force` only when the user explicitly approved that exact
overwrite decision in the preview. Do not replace the initializer with a
second implementation in this skill.

After bootstrap, run the matching validator from the same package runtime and
report its complete result and exit code:

- Unix-like environments: `<skill-dir>/runtime/scripts/validate-template.sh --all`
- Windows PowerShell: `<skill-dir>/runtime/scripts/validate-template.ps1 -All`

If the command fails, stop and report the failure; do not retry with
destructive options. Preserve the user's unrelated changes and never expose or
write credentials.

If the user cancels, defers, changes the target, or withholds approval, report
`Mutation: none` and `Target: unchanged`; do not run the initializer or
validator.

## Conflict Decision Record

When a conflict is approved, summarize the user's decision before acting:

```text
Decision: APPROVE_OVERWRITE | APPROVE_MERGE | CANCEL | CHANGE_TARGET
Target: <displayed target path>
Conflicts: <exact paths>
Scope: <displayed files and command>
```

If the user chooses merge, require a concrete merge plan and keep the original
files recoverable. If the initializer cannot express the approved merge
without data loss, stop and ask the user to choose a safe target or perform the
merge manually.

## References

- Read [adoption-contract.md](references/adoption-contract.md) for the input,
  preview, decision, and result contract.
- Read [contract-schema.md](references/contract-schema.md) when producing or
  validating normalized adapter results.
- Read [profile-catalog.md](references/profile-catalog.md) when recommending a
  profile or checking bilingual manifest parity.
- Read [conflict-fixtures.md](references/conflict-fixtures.md) when reviewing
  or testing conflict and cancellation behavior.
- Read [public-package-layout.md](references/public-package-layout.md) when
  running from an installed package or reviewing public source mappings.
