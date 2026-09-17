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

**Expected preview:** State whether the displayed initializer would create or
overwrite `AGENTS.md`, describe the impact, and enter `CONFLICT_REVIEW`.

**Decision and outcome:** No mutation or validation may occur until the user
chooses `APPROVE_OVERWRITE`, supplies a concrete safe `APPROVE_MERGE` plan, or
chooses `CHANGE_TARGET`. `CANCEL` leaves the target byte-for-byte unchanged.

## Fixture D — Existing `docs/`

**State:** The target contains a synthetic `docs/` directory with an existing
`docs/README.md`.

**Inspection:** Report `docs/` and any directly affected child paths as
governance conflicts; do not treat the directory as empty or disposable.

**Expected preview:** List the exact proposed paths under `docs/`, the action
for each path, the impact, and `CONFLICT_REVIEW` as the next state.

**Decision and outcome:** Bootstrap is blocked until every reported conflict
has an explicit decision. A merge requires a recoverable plan. Cancellation or
deferral performs no write and leaves all existing documentation unchanged.

## Fixture E — User cancellation

**State:** Any inspection result, including a conflict-free preview or one or
more reported conflicts.

**Action:** The user selects `CANCEL` or defers a decision.

**Expected outcome:** Do not invoke the initializer, validator, overwrite
flags, merge, delete, or rename operations. Report `Mutation: none` and leave
the target unchanged.
