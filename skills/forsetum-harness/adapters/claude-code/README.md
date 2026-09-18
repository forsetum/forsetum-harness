# Claude Code Adapter

Status: `Candidate`; official interface verified, but adapter conformance and
manual runtime smoke evidence are still required before `Supported`.

## Official Interface and Distribution

Claude Code skills use a directory containing `SKILL.md`, YAML frontmatter,
and Markdown instructions. Project-scoped skills load from
`.claude/skills/<skill-name>/SKILL.md` and can be invoked as slash commands.
Supporting files can remain beside `SKILL.md` and be referenced with relative
links. The existing `forsetum-harness` skill uses this format, so the adapter
does not need to translate or duplicate its instructions.

To install into a target repository, copy the complete canonical skill
directory, preserving its structure:

```text
skills/forsetum-harness/          -> .claude/skills/forsetum-harness/
```

The installed entry point is
`.claude/skills/forsetum-harness/SKILL.md`.

The copied directory must include `SKILL.md`, `references/`, and `scripts/`.
Do not copy template profile content into a separate adapter-owned catalog.
Invoke the skill as:

```text
/forsetum-harness
```

Official references:

- [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Claude Code permission modes](https://code.claude.com/docs/en/permissions)
- [Claude Code CLI reference](https://code.claude.com/docs/en/cli-usage)

## Canonical State Mapping

The adapter preserves every normalized contract state:

| State | Claude Code behavior |
| --- | --- |
| `INSPECTION` | Read target and manifests only; no write tools or commands are invoked. |
| `PROCEED_PENDING_APPROVAL` | Show the full preview and ask for approval before bootstrap. |
| `CONFLICT_REVIEW` | Report exact paths, actions, and impact; stop and ask for a decision for each conflict. |
| `BOOTSTRAP_APPROVED` | Proceed only for the exact preview the user approved. |
| `VALIDATED` | Run the canonical validator and report its command and exit code. |
| `CANCELLED` | Stop with `Mutation: none` and `Target: unchanged`. |
| `DEFERRED` | Stop with `Mutation: none` and `Target: unchanged`. |
| `BLOCKED` | Report the missing capability or ambiguity; do not guess or mutate. |

The default permission behavior asks before Bash commands and file edits. Keep
that behavior for this workflow. Do not enable `bypassPermissions`,
`--dangerously-skip-permissions`, or broad `allowed-tools` rules for adoption.
The skill's conversational conflict decision is separate from Claude Code's
tool permission prompt: both gates must pass.

## Reference Flow

1. Read the target repository and both canonical manifests without writing.
2. Use the profile catalog to recommend only a manifest-backed module ID.
3. Run the bundled read-only inspector from the installed skill directory:

   ```bash
   bash <skill-dir>/scripts/inspect-repository.sh \
     --target . --lang <id|en> --module <manifest-module-id> \
     --template-root <skill-dir>/runtime
   ```

4. Present the profile, target, paths, initializer/validator commands, and one
   complete conflict record per exact path:

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

   Inspector exit code `3` means `CONFLICT_REVIEW`; stop and collect explicit
   decisions before any bootstrap or validation. A replacement requires its
   displayed recovery metadata before its backup directory is created.

   ```text
   PRESERVE/SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged
   Next action: manual handling | CHANGE_TARGET
   ```

   An approved `PRESERVE` or `SKIP` is not bootstrap approval for that target.
   Do not invoke the initializer or validator; leave the target unchanged and
   route to manual handling outside the skill or a changed target.
5. After approval of the exact non-conflicting or explicitly resolved preview,
   route the target, language, module, complete per-path decision set, and
   replacement backup mappings through the package-local handoff. Use
   `.claude/skills/forsetum-harness/scripts/decision-handoff.sh` on Unix-like
   hosts and `.claude/skills/forsetum-harness/scripts/decision-handoff.ps1`
   natively on Windows. The handoff verifies inventory/hash and creates each
   approved backup before invoking the canonical initializer; do not translate
   the Windows path through Bash or use `bash -x`.
6. The handoff delegates bootstrap to the bundled canonical
   `<skill-dir>/runtime/scripts/init.sh` (or `init.ps1` on Windows), then runs
   the bundled canonical validator with the exact target and
   instantiated mode; record its exit code and evidence.

   ```bash
   <skill-dir>/runtime/scripts/validate-template.sh --all
   ```

The installed skill's runtime is package-local and must not use a private
checkout, network fetch, or caller cwd as a template/script source. Claude
Code's Bash approval does not replace the Harness approval gate. If a
user cancels, defers, changes the target, or has not approved the preview, do
not invoke the initializer, validator, merge, overwrite, delete, or rename.
Return:

```text
State: CANCELLED | DEFERRED
Mutation: none
Target: unchanged
```

## Verification Status

The adapter's static conformance test checks state preservation, official
installation/invocation format, canonical inspector/initializer/validator
handoff, and cancellation behavior. The compatibility matrix must remain
`Candidate` until an interactive Claude Code smoke test records all required
scenarios and a test date.
