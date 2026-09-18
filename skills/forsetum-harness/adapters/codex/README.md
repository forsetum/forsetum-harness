# Codex Reference Adapter

Status: `Candidate` pending the dated manual smoke and conformance evidence
required by the [public package layout contract](../../references/public-package-layout.md).

This adapter translates the canonical adoption contract into the Codex skill
surface. It does not copy template content and does not implement a second
scaffolder. The canonical skill, manifests, inspector, initializer, and
validator remain authoritative.

## Evidence boundary

OpenAI's official [Skills API documentation](https://developers.openai.com/api/reference/go/resources/skills)
documents skill lifecycle operations, including creating, listing, retrieving,
versioning, and retrieving skill content. This supports recording Codex as an
evidence-backed evaluation target. It does not, by itself, prove that every
Codex runtime, operating system, approval surface, or repository workflow has
passed this adapter's conformance and smoke tests.

## Canonical state mapping

The adapter preserves every canonical state; it must not rename or collapse
states when presenting them in Codex:

| State | Codex adapter behavior |
| --- | --- |
| `INSPECTION` | Collect repository and manifest facts read-only. No target mutation. |
| `PROCEED_PENDING_APPROVAL` | Show the complete preview and wait for explicit approval. |
| `CONFLICT_REVIEW` | Report every exact conflict path, impact, and decision option; hard stop before any write. |
| `BOOTSTRAP_APPROVED` | Record approval for the exact displayed target, paths, action, and command, then invoke the canonical initializer. |
| `VALIDATED` | Run the canonical validator and report its command, output summary, and exit code. |
| `CANCELLED` | Stop immediately with `Mutation: none` and `Target: unchanged`. |
| `DEFERRED` | Stop pending a later decision with `Mutation: none` and `Target: unchanged`. |
| `BLOCKED` | Report the unavailable or ambiguous capability with `Mutation: none`; do not guess or fall back to an unsafe action. |

## Reference flow

### 1. Inspect

Run the bundled read-only inspector before considering any bootstrap command:

```text
skills/forsetum-harness/scripts/inspect-repository.sh \
  --target <dir> --lang <id|en> --module <manifest-module-id> \
  --template-root <skill-dir>/runtime
```

The profile/module ID must come from the selected canonical manifest. Exit code
`0` means `PROCEED_PENDING_APPROVAL`, `3` means `CONFLICT_REVIEW`, and `2`
means invalid inspection input or manifest parity failure.

### 2. Conflict hard stop

When `AGENTS.md`, `README.md`, `backlog.md`, `mission.md`, `governance.md`,
`docs/`, or another preview path already exists or overlaps the proposed
change, remain in `CONFLICT_REVIEW`. Present one record per exact path:

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

Do not invoke the initializer, merge, delete, rename, or validator while any
conflict lacks a decision. A replacement requires all displayed recovery
metadata before its backup directory is created.

```text
PRESERVE/SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged
Next action: manual handling | CHANGE_TARGET
```

An approved `PRESERVE` or `SKIP` is not bootstrap approval for that target.
Do not invoke the initializer or validator; leave the target unchanged and
route to manual handling outside the skill or a changed target.

### 3. Explicit approval

For a non-conflicting preview, ask the user to approve the exact displayed
target, paths, profile, and commands. For conflicts, record one of
`APPROVE_PRESERVE`, `APPROVE_MERGE`, `APPROVE_REPLACE_WITH_BACKUP`,
`APPROVE_SKIP`, `CHANGE_TARGET`, `CANCEL`, or `DEFER` for every reported
conflict. A changed preview invalidates the previous approval.

Record the decision before mutation:

```text
Decision: APPROVE_PRESERVE | APPROVE_MERGE | APPROVE_REPLACE_WITH_BACKUP | APPROVE_SKIP | CANCEL | DEFER | CHANGE_TARGET
Target: <preview target>
Path: <exact preview path>
Operation: <PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP>
Impact: <displayed impact>
Backup behavior: <displayed backup behavior>
Backup path: <exact path | not_applicable>
Rollback command: <exact command | not_applicable>
Gitignore decision: YES | NO | not_applicable
Next state: <displayed next state>
Scope: <preview files and command>
```

### 4. Delegate to the canonical initializer

After explicit approval only, route the exact target, language, module, and
complete conflict decision set through `scripts/decision-handoff.sh`. For each
replacement, supply exact backup and rollback mappings; the handoff verifies
inventory/hash and creates the backup before delegation.

On Windows use the native PowerShell handoff with the same contract:

```text
<skill-dir>/scripts/decision-handoff.ps1 -Decision <decision> -Target <dir> \
  -Lang <id|en> -Module <manifest-module-id> \
  -Initializer <runtime-init-command> -Validator <runtime-validator-command>
```

The handoff delegates to the existing initializer only after the exact safety
gate is satisfied:

```text
<skill-dir>/runtime/scripts/init.sh --lang <id|en> --module <manifest-module-id> \
  --target <dir> --name <name>
```

Do not append unpreviewed or destructive options. For Windows, use
`<skill-dir>/runtime/scripts/init.ps1` equivalent. Do not replace these commands
with adapter-owned file generation; stop for manual handling if the canonical
initializer cannot express the approved operation safely.

### 5. Validate and report

Run the matching canonical validator after bootstrap and report the complete
command and exit code:

```text
<skill-dir>/runtime/scripts/validate-template.sh --all
```

On PowerShell, the handoff passes `-Target <dir> -Mode instantiated` to
`<skill-dir>/runtime/scripts/validate-template.ps1`; do not translate the
handoff through Bash or use `bash -x`. Only report `VALIDATED` after the
validator completes successfully; report a failure without retrying with
destructive options.

### 6. Cancellation safety

If the user cancels, defers, changes target, or does not approve the displayed
action, the adapter must return:

```text
State: CANCELLED | DEFERRED
Mutation: none
Target: unchanged
```

No initializer, validator, overwrite flag, merge, delete, or rename may run in
this outcome. The result must preserve the canonical contract's cancellation
invariant exactly: `Mutation: none`.

## Conformance evidence to collect

The reference adapter must pass the shared fixture cases for an empty target,
a target without governance, existing `AGENTS.md`, existing `docs/`, and
cancellation. Record the test command, exit code, output summary, and manual
smoke date in the compatibility matrix before promoting this adapter to
`Supported`.
