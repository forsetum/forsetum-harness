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
- the normalized operation, impact, backup behavior, approval decision, and
  next state for that exact path; and
- the recovery metadata required before any replacement.

For every existing path, present this complete record before asking for a
decision:

```text
Path: <exact existing path>
Operation: <PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP>
Impact: <concrete effect on this exact path>
Backup behavior: <none | exact protected content and timing>
Replacement metadata: backup_path, rollback_command, gitignore_decision
Backup path: <exact path | not_applicable>
Rollback command: <exact command | not_applicable>
Gitignore decision: YES | NO | not_applicable
Approval decision: <explicit decision for this exact path and operation>
Next state: <CONFLICT_REVIEW | BOOTSTRAP_APPROVED | CANCELLED | DEFERRED>
```

`PRESERVE` and `SKIP` leave the displayed path untouched. `MERGE` must be
targeted to the exact reviewed subpaths. `REPLACE_WITH_BACKUP` requires the
displayed `backup_path`, `rollback_command`, and explicit `gitignore_decision`
before its backup directory is created or its path is replaced. Do not run
bootstrap, merge, delete, rename, or modify any conflicting file until the
user has explicitly decided for every reported conflict. A cancellation or
deferral must leave the target unchanged.

```text
PRESERVE/SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged
Next action: manual handling | CHANGE_TARGET
```

An approved `PRESERVE` or `SKIP` on any conflict is never bootstrap approval
for that target. Do not invoke the initializer or validator; leave the target
unchanged and route the user to manual handling outside this skill or a changed
target.

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

After the user records the decision, route it through the package-local,
shell-native handoff before delegating any command:

`<skill-dir>/scripts/decision-handoff.sh --decision <decision> --target <dir> --lang <id|en> --module <module_id> --preview-fingerprint <sha256> --initializer <approved-initializer-command> --validator <approved-validator-command>`

For `APPROVE_REPLACE_WITH_BACKUP`, repeat `--conflict path=APPROVE_*` for
every exact conflict in the current preview, then pass one exact
`--backup-mapping path=backup` and `--rollback-mapping path=command` for every
approved replacement plus `--gitignore-decision YES|NO`. The handoff rejects
missing, extra, or unapproved paths; creates or verifies each approved backup
with native shell operations; verifies source and backup inventory/hashes; and
only then invokes the initializer. The handoff returns `CANCELLED` or
`DEFERRED` without invoking either command for cancellation, deferral,
preserve, or skip.

On Windows, use the PowerShell-native equivalent without Bash translation:

`<skill-dir>/scripts/decision-handoff.ps1 -Decision <decision> -Target <dir> -Lang <id|en> -Module <module_id> -PreviewFingerprint <sha256> -Initializer <approved-initializer-command> -Validator <approved-validator-command>`

`<sha256>` must be copied from the current `PREVIEW_FINGERPRINT` emitted by the
read-only inspector. If the target, language, module, or governed paths change,
the handoff rejects the stale approval before creating backups or invoking the
initializer and validator.

After the user explicitly approves an action with no `PRESERVE` or `SKIP`
conflict, delegate deterministic file generation to the existing initializer
bundled in the installed package's runtime:

- Unix-like environments: `<skill-dir>/runtime/scripts/init.sh --lang <id|en> --module <module_id> --target <dir> --name <name>`
- Windows PowerShell: `<skill-dir>/runtime/scripts/init.ps1 -Lang <id|en> -Module <module_id> -Target <dir> -Name <name>`

Do not append any unpreviewed or destructive option to the initializer. Do not
replace the initializer with a second implementation in this skill. If the
canonical initializer cannot express the approved targeted merge or replacement
without data loss, stop and require a safe target or manual handling.

After bootstrap, the handoff runs the matching validator from the same package
runtime with the approved target and `-Mode instantiated`/`--mode instantiated`
context. Report its complete result and exit code:

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
Decision: APPROVE_PRESERVE | APPROVE_MERGE | APPROVE_REPLACE_WITH_BACKUP | APPROVE_SKIP | CANCEL | DEFER | CHANGE_TARGET
Target: <displayed target path>
Path: <exact conflicting path>
Operation: <PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP>
Impact: <displayed impact>
Backup behavior: <displayed backup behavior>
Backup path: <exact path | not_applicable>
Rollback command: <exact command | not_applicable>
Gitignore decision: YES | NO | not_applicable
Next state: <displayed next state>
Scope: <displayed files and command>
```

If the user chooses merge, require a concrete merge plan and keep the original
files recoverable. A replacement may proceed only after its backup exists and
its rollback command has been recorded.

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
