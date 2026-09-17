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

4. Present the profile, target, paths, initializer/validator commands, and all
   conflict actions/impacts. Inspector exit code `3` means `CONFLICT_REVIEW`;
   stop and collect explicit decisions before any bootstrap or validation.
5. After approval of the exact non-conflicting or explicitly resolved preview,
   delegate to `.claude/skills/forsetum-harness/runtime/scripts/init.sh` (or
   its `init.ps1` equivalent on Windows). Use a force flag only for an
   explicitly approved overwrite decision.
6. Run the bundled canonical validator and record its exit code and evidence.

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
