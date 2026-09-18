# Adoption Contract

This contract defines the read-only inspection, preview, decision gate, and
mutation handoff for the `forsetum-harness` adoption skill. The normalized
fields and states are defined in [contract-schema.md](contract-schema.md). It
is an instruction-layer contract; the canonical manifest, templates,
initializer, and validator remain authoritative.

## 0. Runtime and source mode

The installed package is self-contained. Resolve `<skill-dir>` as the
directory containing the installed `SKILL.md`, invoke the bundled inspector,
and pass `--template-root <skill-dir>/runtime`. Bootstrap and validation must
use `<skill-dir>/runtime/scripts/`; manifests must be read from
`<skill-dir>/runtime/template/{id,en}/`. The caller's current working
directory is only a target selector. Do not read from a private source
checkout or fetch runtime files over the network.

During source-checkout development only, the canonical repository root may be
passed explicitly as `--template-root`. This fallback does not apply to an
installed package. See [public-package-layout.md](public-package-layout.md)
for the complete mapping.

## 1. Inspection inputs

The skill must collect and display these observed inputs before proposing any
write:

| Input | Required observation |
| --- | --- |
| Repository root | The target repository selected by the user. |
| Existing governance paths | Presence and relevant contents of paths such as `AGENTS.md`, `README.md`, `backlog.md`, `mission.md`, `governance.md`, and `docs/`. |
| Language | The selected `id` or `en` value, sourced from the canonical manifest or initializer contract. |
| Module/profile | A module ID present in the canonical manifest; never an invented ID. |
| Target path | The exact directory proposed for bootstrap. |
| Repository signals | Read-only facts used to explain the profile recommendation, such as detected project files or existing documentation. |

Inspection must not create directories, write reports into the target, run the
initializer, use overwrite flags, or alter existing files.

## 2. Preview output

Before asking for approval, present a complete preview containing:

```text
Adoption preview
Language: <id|en>
Module/profile: <canonical module id>
Target: <user-selected target path>
Create: <non-conflicting paths>
Existing/conflicting: <exact paths, or none>
Initializer: <canonical init command for the detected shell>
Validator: <canonical validator command>
Next state: <PROCEED_PENDING_APPROVAL | CONFLICT_REVIEW>
```

For every existing or overlapping governance path, the preview must contain a
separate complete record:

```text
Path: <exact existing path>
Operation: PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP
Impact: <concrete effect on this exact path>
Backup behavior: <none | exact protected content and timing>
Backup path: <exact path | not_applicable>
Rollback command: <exact command | not_applicable>
Gitignore decision: YES | NO | not_applicable
Approval decision: <explicit decision for this exact path and operation>
Next state: <CONFLICT_REVIEW | BOOTSTRAP_APPROVED | CANCELLED | DEFERRED>
```

`PRESERVE` and `SKIP` leave the existing path untouched. `MERGE` is only a
targeted, reviewed merge of the displayed subpaths; it cannot be inferred from
an existing filename. `REPLACE_WITH_BACKUP` requires the displayed backup path
and reproducible rollback command before replacement. Whenever either a merge
or replacement creates a backup directory, `Gitignore decision` must be an
explicit `YES` or `NO` for that exact backup directory; no `.gitignore` change
may be implicit. The preview is an informational boundary: showing a command
does not authorize running it.

```text
PRESERVE/SKIP result: {State: DEFERRED, Mutation: none, Target: unchanged}
PRESERVE/SKIP next action: manual handling | CHANGE_TARGET
```

An approved `PRESERVE` or `SKIP` on any conflict is not bootstrap approval for
the displayed target. Do not invoke the initializer or validator for that
target; preserve it unchanged and route the user to manual handling outside
the skill or a changed target.

## 3. Conflict decision gate

If any governance conflict is found, enter `CONFLICT_REVIEW` and stop. Ask for
an explicit decision for every reported conflict. The available decisions are:

- `APPROVE_PRESERVE`: retain the exact existing path and exclude it from
  bootstrap mutation.
- `APPROVE_MERGE`: approve a concrete, recoverable merge plan; do not infer one.
- `APPROVE_REPLACE_WITH_BACKUP`: approve only the displayed replacement,
  backup path, rollback command, and `.gitignore` decision.
- `APPROVE_SKIP`: exclude the exact path from bootstrap mutation.
- `CHANGE_TARGET`: choose a target path whose proposed files do not conflict.
- `CANCEL`: stop without bootstrap, validation, or any mutation.
- `DEFER`: stop and leave the decision unresolved without mutation.

No initializer, force flag, merge, delete, rename, or validator may run while a
reported conflict lacks a decision. A decision applies only to the exact
paths, action, target, and command shown in the preview. A changed preview
requires a new decision.

Record an approved conflict decision before mutation. The handoff also requires
the `PREVIEW_FINGERPRINT` emitted by the current inspector; changing the target,
profile, or governed path inventory invalidates the approval:

```text
Decision: APPROVE_PRESERVE | APPROVE_MERGE | APPROVE_REPLACE_WITH_BACKUP | APPROVE_SKIP | CANCEL | DEFER | CHANGE_TARGET
Target: <preview target>
Conflicts: <exact preview paths>
Scope: <preview files and command>
Preview fingerprint: <current PREVIEW_FINGERPRINT SHA-256>
```

If a merge cannot be performed without risking data loss, stop and require a
safe target or manual handling. A replacement may not begin before the exact
backup exists, matches the approved source inventory/hash, and the rollback
mapping has been recorded. Existing user files remain recoverable.

## 4. Explicit approval and result

Only after the user explicitly approves the displayed non-conflicting action,
or every displayed conflict receives a decision, route the decision through the
shell-appropriate package-local handoff. The handoff must receive the exact
target, language, module, current preview fingerprint, initializer, validator,
and per-path decision set.
For replacement, it must also receive exact old-path/backup and old-path/
rollback mappings, verify the approved source inventory and SHA-256 hashes,
create or verify backups before invoking the canonical initializer, and pass
the selected target/profile arguments to both initializer and validator. Use
the canonical runtime scripts; do not implement a second scaffolding engine in
the skill.

On Windows, invoke `scripts/decision-handoff.ps1` directly with PowerShell
parameters. A PowerShell adapter must not translate the command through Bash or
use `bash -x`.

Report the initializer command, validator command, exit codes, and resulting
paths. If the user cancels, defers, changes the target, or approval is absent,
the required result is:

```text
State: CANCELLED | DEFERRED | TARGET_CHANGED
Mutation: none
Target: unchanged
```

Use only the normalized states and required fields from `contract-schema.md`.
Do not translate an inspector conflict into an approval, and do not report
`VALIDATED` until the canonical validator has completed.
