# Conflict Fixtures

These synthetic fixtures define expected behavior for reviewers and future
runtime adapters. Paths and project names are intentionally generic; fixtures
contain no credentials or machine-specific locations.

For each fixture, inspection is read-only. The target may be mutated only in
the explicitly approved, non-conflicting case.

## Fixture A — Empty target

**State:** The target directory exists and contains no files.

**Inspection:** No governance paths are present. The user selects a language
and a module ID that the canonical manifest exposes.

**Expected preview:** Show the selected language, canonical module, target,
files to create, and the canonical initializer and validator commands.

**Decision and outcome:** After explicit approval, bootstrap may proceed and
validation may run. Before approval, the target remains unchanged.

## Fixture B — Target with no governance files

**State:** The target contains synthetic application files such as
`src/example.txt` and `package.json`, but no `AGENTS.md`, `README.md`,
`backlog.md`, `mission.md`, `governance.md`, or `docs/` path.

**Inspection:** Report the application files only as repository signals and
confirm that no governance conflict was observed.

**Expected preview:** List only the proposed governance paths as creates and
show the selected canonical profile and commands.

**Decision and outcome:** After explicit approval, bootstrap may proceed. No
existing application file may be overwritten; without approval, the target
remains unchanged.

## Fixture C — Existing `AGENTS.md`

**State:** The target contains a synthetic `AGENTS.md` with project-local
instructions.

**Inspection:** Report `AGENTS.md` as an exact governance conflict and do not
assume that its contents can be merged.

**Expected preview:** State the exact path, `PRESERVE` operation, impact, and
recovery fields. The operation's next state must describe the outcome after
the user approves it.

```text
Path: AGENTS.md
Operation: PRESERVE
Impact: project-local instructions remain authoritative and are not changed
Backup behavior: none; the existing path is retained
Backup path: not_applicable
Rollback command: not_applicable
Gitignore decision: not_applicable
Approval decision: APPROVE_PRESERVE
Next state: DEFERRED after APPROVE_PRESERVE
```

**Decision and outcome:** `APPROVE_PRESERVE` produces:

```text
PRESERVE outcome: State: DEFERRED, Mutation: none, Target: unchanged
Next action: manual handling | CHANGE_TARGET
```

Do not invoke the initializer or validator for this target. A different
operation requires a new exact preview; `CANCEL` or `DEFER` also leaves the
target byte-for-byte unchanged.

## Fixture D — Existing `README.md` targeted merge

**State:** The target contains a synthetic `README.md` with project overview
content and a reviewed marker for a governance section.

**Inspection:** Report `README.md` as an exact conflict. The displayed merge
is limited to that reviewed governance section; all other README content is
preserved.

**Expected preview:**

```text
Path: README.md
Operation: MERGE
Impact: add only the reviewed governance section; preserve all other README content
Backup behavior: none for the reviewed additive merge
Backup path: not_applicable
Rollback command: not_applicable
Gitignore decision: not_applicable
Approval decision: APPROVE_MERGE
Next state: CONFLICT_REVIEW until every other conflict is decided
```

**Decision and outcome:** The merge may proceed only after explicit approval
of the exact reviewed section. If its merge plan creates a backup directory,
it must instead name the exact backup path and rollback command and receive an
explicit `.gitignore` `YES` or `NO` decision before mutation.

## Fixture E — Existing `backlog.md` replacement with backup

**State:** The target contains a synthetic `backlog.md` that is explicitly
approved for replacement.

**Inspection:** Report `backlog.md` as an exact conflict and do not replace it
until the pre-mutation backup is available.

**Expected preview:**

```text
Path: backlog.md
Operation: REPLACE_WITH_BACKUP
Impact: replace the displayed backlog.md only after preserving its current content
Backup behavior: copy the current backlog.md before replacement
Backup path: .forsetum-backups/2026-09-17T00-00-00Z/backlog.md
Rollback command: cp .forsetum-backups/2026-09-17T00-00-00Z/backlog.md backlog.md
Gitignore decision: YES | NO
Approval decision: APPROVE_REPLACE_WITH_BACKUP
Next state: CONFLICT_REVIEW until every other conflict is decided
```

**Decision and outcome:** Neither the backup nor the replacement occurs before
the exact approval. The `.gitignore` choice applies only to the displayed
backup directory and may not be made implicitly.

## Fixture F — Existing `docs/`

**State:** The target contains a synthetic `docs/` directory with an existing
`docs/README.md`.

**Inspection:** Report `docs/` and any directly affected child paths as
governance conflicts; do not treat the directory as empty or disposable.

**Expected preview:** List the exact `docs/` path, `SKIP` operation, impact,
and recovery fields. The operation's next state must describe the outcome
after the user approves it.

```text
Path: docs/
Operation: SKIP
Impact: retain the existing documentation tree and omit it from bootstrap
Backup behavior: none; the existing tree is not changed
Backup path: not_applicable
Rollback command: not_applicable
Gitignore decision: not_applicable
Approval decision: APPROVE_SKIP
Next state: DEFERRED after APPROVE_SKIP
```

**Decision and outcome:** `APPROVE_SKIP` produces:

```text
SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged
Next action: manual handling | CHANGE_TARGET
```

Do not invoke the initializer or validator for this target. A merge requires a
recoverable plan in a new exact preview. Cancellation or deferral performs no
write and leaves all existing documentation unchanged.

## Fixture G — User cancellation or deferral

**State:** Any inspection result, including a conflict-free preview or one or
more reported conflicts.

**Action:** The user selects `CANCEL` or `DEFER` for an unresolved conflict.

**Expected cancellation outcome:** Do not invoke the initializer, validator,
overwrite flags, merge, delete, or rename operations. Report `State:
CANCELLED`, `Mutation: none`, and leave the target unchanged.

**Expected deferral outcome:** Do not invoke the initializer, validator,
overwrite flags, merge, delete, or rename operations. Report `State:
DEFERRED`, `Mutation: none`, and leave the target unchanged.
