# Public Skill Package Layout

This is the package contract for the curated distribution discovered by
`npx skills add forsetum/forsetum-harness`. The package is generated from the
canonical repository; runtime copies are distribution output, not a second
authoring source.

## Publication Policy

All 27 canonical EN/ID modules are approved for public distribution under
upstream D-011, including `business-growth`. The product stores all approved IDs and their complete canonical metadata in
`template/`. Native package builders copy these sources into the generated
package-local runtime. Private documents, customer data, and
credentials remain excluded. Actual cross-platform CI status is recorded
separately from package generation.

## Package invariants

discoverable_entrypoint: skills/forsetum-harness/SKILL.md
bundled_inspector: skills/forsetum-harness/scripts/inspect-repository.sh
bundled_decision_handoff_bash: skills/forsetum-harness/scripts/decision-handoff.sh
bundled_decision_handoff_powershell: skills/forsetum-harness/scripts/decision-handoff.ps1
runtime_root: skills/forsetum-harness/runtime
runtime_scripts: skills/forsetum-harness/runtime/scripts
runtime_templates: skills/forsetum-harness/runtime/template/{id,en}
runtime_resolution: package-relative
source_checkout_fallback: canonical-root-only
installed_dependencies: none
network_fetch_at_runtime: forbidden
cwd_dependency: forbidden
private_checkout_dependency: forbidden
local_install_command: npx skills add <public-tree>
public_github_verification: pending-publication
install_status_policy: zero-complete-only; 124-no-install-boundary; 125-no-safe-process-group; other-nonzero-failure
timeout_cleanup: bounded-known-process-group-only

The public tree contains exactly one discoverable skill entry point. An
installed skill resolves its package directory from that entry point and uses
only the bundled inspector and files under its own `runtime/` root. The
caller's current working directory is only the user-selected adoption target,
never a source of templates or scripts.

## Source mapping

The native package builders implement these mappings from this product checkout:

```text
skills/forsetum-harness/SKILL.md <- skills/forsetum-harness/SKILL.md
skills/forsetum-harness/scripts/inspect-repository.sh <- skills/forsetum-harness/scripts/inspect-repository.sh
skills/forsetum-harness/scripts/decision-handoff.sh <- skills/forsetum-harness/scripts/decision-handoff.sh
skills/forsetum-harness/scripts/decision-handoff.ps1 <- skills/forsetum-harness/scripts/decision-handoff.ps1
skills/forsetum-harness/runtime/scripts/init.sh <- scripts/init.sh
skills/forsetum-harness/runtime/scripts/init.ps1 <- scripts/init.ps1
skills/forsetum-harness/runtime/scripts/bundle.sh <- scripts/bundle.sh
skills/forsetum-harness/runtime/scripts/bundle.ps1 <- scripts/bundle.ps1
skills/forsetum-harness/runtime/scripts/validate-harness.sh <- scripts/validate-harness.sh
skills/forsetum-harness/runtime/scripts/validate-harness.ps1 <- scripts/validate-harness.ps1
skills/forsetum-harness/runtime/scripts/validate-template.sh <- scripts/validate-template.sh
skills/forsetum-harness/runtime/scripts/validate-template.ps1 <- scripts/validate-template.ps1
skills/forsetum-harness/runtime/template/id/ <- canonical template/id/ (27 approved modules)
skills/forsetum-harness/runtime/template/en/ <- canonical template/en/ (27 approved modules)
```

The curated package contains exactly these approved IDs in both languages:

```text
web-fullstack,
landing-page,
sales-outreach,
general-office,
mobile-app,
cli-automation,
content-marketing,
research-analysis,
web-starter,
it-infra-ops,
app-maintenance,
procurement-tender,
hr-people-ops,
education-training,
supply-chain-logistics,
event-project-mgmt,
ui-ux-design,
content-creator,
digital-advertising,
academic-education,
health-medical,
construction-civil,
manufacturing-hse,
culinary-fnb,
agribusiness-farming,
sme-business,
business-growth
```

The product gate requires exactly these 27 IDs in both canonical manifests.

Reviewed adapters and references beside the entry point are package content.
Private plans, repository metadata, credentials, and unlisted files are not.

## Runtime invocation

For an installed package, `<skill-dir>` is the directory containing the
installed `SKILL.md`:

```text
bash <skill-dir>/scripts/inspect-repository.sh \
  --target <target> --lang <id|en> --module <manifest-module-id> \
  --template-root <skill-dir>/runtime
<skill-dir>/scripts/decision-handoff.sh --decision <decision> \
  --target <target> --lang <id|en> --module <manifest-module-id> \
  --preview-fingerprint <sha256> \
  --initializer <runtime-init-command> --validator <runtime-validator-command>
<skill-dir>/scripts/decision-handoff.ps1 -Decision <decision> \
  -Target <target> -Lang <id|en> -Module <manifest-module-id> \
  -PreviewFingerprint <sha256> \
  -Initializer <runtime-init-command> -Validator <runtime-validator-command>
<skill-dir>/runtime/scripts/init.sh --lang <id|en> \
  --module <manifest-module-id> --target <target> --name <name>
<skill-dir>/runtime/scripts/validate-harness.sh --all
```

The inspector receives the runtime root explicitly and reads
`<skill-dir>/runtime/template/{id,en}/manifest.json`. The initializer and
validator are the canonical scripts copied into the same runtime and retain
their existing relative layout. The `validate-template.*` files are temporary
compatibility wrappers that delegate to the canonical `validate-harness.*`
files.

The decision handoff is package-local and fail-closed. It returns `CANCELLED`
for `CANCEL`, `DEFERRED` for `DEFER`, `PRESERVE`, or `SKIP`, and delegates the
initializer and validator only for `APPROVE_REPLACE_WITH_BACKUP` after the
exact conflict set, the current inspector `PREVIEW_FINGERPRINT`, backup
mappings, rollback mappings, and explicit `YES` or `NO` `.gitignore` decision
are supplied. It creates or verifies each approved
backup with native shell operations before delegation and never resolves a
command from the caller's working directory.

When exercising the skill from the canonical source checkout, the repository
root may be passed explicitly as `--template-root` for local development.
This fallback does not apply to an installed package.

## Installation evidence boundary

The native package tests build an isolated skill from this checkout, then run
its inspector and handoff from an unrelated working directory. This proves
package-relative runtime resolution and the covered safety behavior. The suite
does not run a network installer. Live `npx skills add forsetum/forsetum-harness`
verification remains pending until its revision, command, exit code, and
installed inventory are recorded. The source repository documents the native build and test commands in
`docs/testing-compatibility.md`.

## Safety and state contract

The package preserves:

```text
inspect -> recommend/select -> preview -> explicit conflict decision -> bootstrap -> validate
```

The inspector remains read-only. Exit code `0` means
`PROCEED_PENDING_APPROVAL`, exit code `3` means `CONFLICT_REVIEW`, and exit
code `2` means invalid inspection inputs or manifest data. No initializer,
overwrite flag, merge, delete, rename, or validator may run before the exact
preview has explicit approval. Cancellation or deferral returns
`Mutation: none` and `Target: unchanged`.
