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
change, remain in `CONFLICT_REVIEW`. Present the exact path, create/update/
merge/overwrite action, impact, and available decisions. Do not invoke the
initializer, `--force`, merge, delete, rename, or validator while any conflict
lacks a decision.

### 3. Explicit approval

For a non-conflicting preview, ask the user to approve the exact displayed
target, paths, profile, and commands. For conflicts, record one of
`APPROVE_OVERWRITE`, `APPROVE_MERGE`, `CHANGE_TARGET`, or `CANCEL` for every
reported conflict. A changed preview invalidates the previous approval.

Record the decision before mutation:

```text
Decision: APPROVE_OVERWRITE | APPROVE_MERGE | CANCEL | CHANGE_TARGET
Target: <preview target>
Conflicts: <exact preview paths>
Scope: <preview files and command>
```

### 4. Delegate to the canonical initializer

After explicit approval only, delegate to the existing initializer:

```text
<skill-dir>/runtime/scripts/init.sh --lang <id|en> --module <manifest-module-id> \
  --target <dir> --name <name>
```

Use `--force` only when that exact overwrite action was explicitly approved.
For Windows, use `<skill-dir>/runtime/scripts/init.ps1` equivalent. Do not replace
these commands with adapter-owned file generation.

### 5. Validate and report

Run the matching canonical validator after bootstrap and report the complete
command and exit code:

```text
<skill-dir>/runtime/scripts/validate-template.sh --all
```

On PowerShell, use `<skill-dir>/runtime/scripts/validate-template.ps1 -All`.
Only report `VALIDATED` after the validator completes successfully; report a
failure without retrying with destructive options.

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
