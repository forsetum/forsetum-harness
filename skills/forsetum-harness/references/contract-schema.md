# Canonical Adoption Contract Schema

This schema is the normalized interface between the adoption skill, platform
adapters, the read-only inspector, and the canonical CLI. Platform adapters may
change presentation, but they must preserve these fields and states.

The machine-checkable safety invariants are:

```text
allowed_states: [INSPECTION, PROCEED_PENDING_APPROVAL, CONFLICT_REVIEW, BOOTSTRAP_APPROVED, VALIDATED, CANCELLED, DEFERRED, BLOCKED]
conflict_paths: [AGENTS.md, docs/]
conflict_path_mode: exact
cancelled_result: {State: CANCELLED, Mutation: none, Target: unchanged}
deferred_result: {State: DEFERRED, Mutation: none, Target: unchanged}
allowed_operations: [PRESERVE, MERGE, REPLACE_WITH_BACKUP, SKIP]
conflict_preview_fields: [path, operation, impact, backup_behavior, approval_decision, next_state]
authorization_basis_values: [HUMAN_APPROVAL, FULL_ALLOW]
authorization_basis_required: every authorization record; not an independent mutation grant
authorization_basis_binding: exact displayed target, path/action set, current PREVIEW_FINGERPRINT
authorization_basis_full_allow_conflicts: PRESERVE or SKIP only; outcome remains DEFERRED with Mutation: none
authorization_basis_human_approval_conflicts: MERGE and REPLACE_WITH_BACKUP
authorization_basis_human_approval_destructive: always action-specific
authorization_basis_handoff: recorded in preview/approval context; no new handoff argument; caller verifies before existing handoff
replace_with_backup_requirements: [backup_path, rollback_command, gitignore_decision]
gitignore_decision: explicit YES or NO when a backup directory is created
handoff_arguments: [target, language, module, preview_fingerprint, initializer, validator]
handoff_preview_fingerprint: required SHA-256 of the exact current inspector preview; changed previews invalidate approval
handoff_conflict_set: exact current conflicts; missing or extra paths invalid
handoff_backup_mapping: exact approved old path to backup path mapping
handoff_backup_inventory: generated pre/post inventory and SHA-256 equality for every approved replacement path
handoff_backup_order: verify inventory/hash and create backup before initializer
handoff_shell_contract: Bash arrays on Unix; native PowerShell parameters on Windows; no bash -x
preserve_skip_result: {State: DEFERRED, Mutation: none, Target: unchanged}
preserve_skip_next_action: manual handling | CHANGE_TARGET
```

## Required Result Fields

| Field | Type | Rule |
| --- | --- | --- |
| `state` | string | One of the states listed below. Unknown states are invalid. |
| `target` | string | Exact target directory selected by the user. |
| `language` | string | `id` or `en`, sourced from the manifest contract. |
| `profile_id` | string | Exact key present in the selected manifest and parity catalog. |
| `manifest_source` | string | Manifest path used for the profile selection. |
| `repository_signals` | list | Read-only facts supporting the recommendation. |
| `proposed_paths` | list | Exact paths proposed for creation or change. |
| `conflicts` | list | Exact existing paths and a complete conflict preview record. Empty when no conflict exists. |
| `decision` | string or null | Required before mutation when conflicts exist. |
| `authorization_basis` | string | `HUMAN_APPROVAL` or `FULL_ALLOW`, bound to the exact displayed target, path/action set, and current preview fingerprint. |
| `command_preview` | list | Exact initializer and validator commands shown before approval. |
| `exit_code` | integer | Inspector/validator exit code, reported without reinterpretation. |
| `validation_evidence` | list | Commands, outcomes, and relevant output after validation. |

## Conflict Preview Record

Every item in a non-empty `conflicts` list must contain all of the following
fields. A directory remains an exact path (for example `docs/`); it must not
be replaced with a vague label such as “documentation”.

| Field | Rule |
| --- | --- |
| `path` | Exact existing target path. |
| `operation` | One of `PRESERVE`, `MERGE`, `REPLACE_WITH_BACKUP`, or `SKIP`. |
| `impact` | Concrete effect on the existing path. |
| `backup_behavior` | Whether no backup applies or which existing content is protected before mutation. |
| `approval_decision` | Explicit decision for this exact path and operation; it is not inherited from another path. |
| `authorization_basis` | `HUMAN_APPROVAL` or `FULL_ALLOW`, bound to the exact displayed target, path/action set, and current preview fingerprint. |
| `next_state` | The state reached if this decision is accepted; unresolved paths remain `CONFLICT_REVIEW`. |
| `backup_path` | Exact backup path when a backup directory is created; otherwise `not_applicable`. |
| `rollback_command` | Reproducible command that restores the exact protected path when a backup is created; otherwise `not_applicable`. |
| `gitignore_decision` | `YES` or `NO` when a backup directory is created; otherwise `not_applicable`. |

Operation rules:

- `PRESERVE` leaves the existing path intact and does not mutate that path.
- `MERGE` is limited to the exact reviewed subpaths and requires a concrete,
  recoverable merge plan. If the plan creates a backup directory, it must also
  provide `backup_path`, `rollback_command`, and an explicit `YES` or `NO`
  `gitignore_decision` before mutation.
- `REPLACE_WITH_BACKUP` may replace only the displayed exact path after its
  pre-mutation backup is created. It always requires `backup_path`,
  `rollback_command`, and an explicit `YES` or `NO` `gitignore_decision`.
- `SKIP` omits the proposed path from bootstrap and does not mutate that path.

Authorization-basis rules:

- `FULL_ALLOW` is explicit, bounded to the displayed scope, and may authorize
  routine non-destructive decisions within it. For a reported conflict, its
  only valid per-path decisions are `PRESERVE` and `SKIP`; both retain the
  required `DEFERRED`, `Mutation: none`, `Target: unchanged` outcome.
- `MERGE` requires `HUMAN_APPROVAL` after human review of the exact merge plan,
  paths, impact, and current preview. This preserves D-027; `FULL_ALLOW` cannot
  approve a merge.
- `REPLACE_WITH_BACKUP` and every other destructive action require
  `HUMAN_APPROVAL` specific to that action, regardless of `FULL_ALLOW`.
- Record `authorization_basis` in the preview/approval record. The existing
  handoff arguments remain unchanged and do not carry or upgrade this basis;
  the caller must verify the record before invoking the handoff with the exact
  operation, target, path set, and current fingerprint.

A selected `PRESERVE` or `SKIP` operation for any conflict must not produce
`BOOTSTRAP_APPROVED` for that target. The required result is `DEFERRED` with
`Mutation: none` and `Target: unchanged`; the only next actions are manual
handling outside the skill or `CHANGE_TARGET`. The initializer and validator
must not run for that deferred target.

## Allowed States

- `INSPECTION`: facts are being collected; no mutation is permitted.
- `PROCEED_PENDING_APPROVAL`: no conflict was detected; preview awaits approval.
- `CONFLICT_REVIEW`: conflicts exist; every conflict requires an exact per-path
  decision and authorization basis. A bounded `FULL_ALLOW` may supply that
  basis only for `PRESERVE` or `SKIP`, which defer unchanged and do not require
  a separate mutation approval.
- `BOOTSTRAP_APPROVED`: the exact displayed action is covered by either
  `HUMAN_APPROVAL` or a bounded `FULL_ALLOW` for a conflict-free routine action;
  conflict `PRESERVE`/`SKIP` outcomes remain `DEFERRED` and cannot bootstrap.
- `VALIDATED`: canonical validation completed with evidence.
- `CANCELLED`: user cancelled; mutation is `none`.
- `DEFERRED`: user deferred a decision; mutation is `none`.
- `BLOCKED`: required capability, manifest parity, or platform behavior is unavailable; mutation is `none`.

## Decision Rules

Allowed conflict decisions are `APPROVE_PRESERVE`, `APPROVE_MERGE`,
`APPROVE_REPLACE_WITH_BACKUP`, `APPROVE_SKIP`, `CHANGE_TARGET`, `CANCEL`, and
`DEFER`. Replacement must be approved as `APPROVE_REPLACE_WITH_BACKUP` with
its displayed backup and rollback evidence under `HUMAN_APPROVAL`. `MERGE`
requires `HUMAN_APPROVAL` following human review. A per-conflict
`FULL_ALLOW` basis is valid only for `PRESERVE` or `SKIP`, which do not
authorize bootstrap. A decision is valid only for the exact target, path,
operation, impact, backup behavior, action set, command, authorization basis,
and fingerprint shown in the current preview. A changed preview invalidates
the previous decision.

The following synthetic result illustrates a cancellation:

```json
{
  "state": "CANCELLED",
  "target": "./sample-project",
  "language": "en",
  "profile_id": "web-starter",
  "manifest_source": "template/en/manifest.json",
  "repository_signals": ["package.json present"],
  "proposed_paths": ["AGENTS.md", "docs/"],
  "conflicts": [
    {
      "path": "AGENTS.md",
      "operation": "REPLACE_WITH_BACKUP",
      "impact": "existing instructions would be replaced only after backup",
      "backup_behavior": "backup pending before replacement",
      "backup_path": ".forsetum-backups/2026-09-17T00-00-00Z/AGENTS.md",
      "rollback_command": "cp .forsetum-backups/2026-09-17T00-00-00Z/AGENTS.md AGENTS.md",
      "gitignore_decision": "NO",
      "authorization_basis": "HUMAN_APPROVAL",
      "approval_decision": "CANCEL",
      "next_state": "CANCELLED"
    }
  ],
  "decision": "CANCEL",
  "command_preview": ["scripts/init.sh --lang en --module web-starter --target ./sample-project"],
  "exit_code": 3,
  "validation_evidence": [],
  "mutation": "none"
}
```

Any result that reports `CANCELLED`, `DEFERRED`, or `BLOCKED` with a mutation
other than `none` is invalid. Any `CONFLICT_REVIEW` result without exact
conflict paths is invalid.
