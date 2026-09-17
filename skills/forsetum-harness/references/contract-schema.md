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
| `conflicts` | list | Exact existing paths and their proposed action/impact. Empty when no conflict exists. |
| `decision` | string or null | Required before mutation when conflicts exist. |
| `command_preview` | list | Exact initializer and validator commands shown before approval. |
| `exit_code` | integer | Inspector/validator exit code, reported without reinterpretation. |
| `validation_evidence` | list | Commands, outcomes, and relevant output after validation. |

## Allowed States

- `INSPECTION`: facts are being collected; no mutation is permitted.
- `PROCEED_PENDING_APPROVAL`: no conflict was detected; preview awaits approval.
- `CONFLICT_REVIEW`: conflicts exist; every conflict requires a user decision.
- `BOOTSTRAP_APPROVED`: the exact displayed action was approved.
- `VALIDATED`: canonical validation completed with evidence.
- `CANCELLED`: user cancelled; mutation is `none`.
- `DEFERRED`: user deferred a decision; mutation is `none`.
- `BLOCKED`: required capability, manifest parity, or platform behavior is unavailable; mutation is `none`.

## Decision Rules

Allowed conflict decisions are `APPROVE_OVERWRITE`, `APPROVE_MERGE`,
`CHANGE_TARGET`, and `CANCEL`. A decision is valid only for the exact target,
paths, action, and command shown in the current preview. A changed preview
invalidates the previous decision.

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
  "conflicts": [{"path": "AGENTS.md", "action": "overwrite", "impact": "existing instructions would be replaced"}],
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
