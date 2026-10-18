# Contributing to Forsetum Harness

GitHub `forsetum/forsetum-harness` accepts issues and pull requests. GitLab
`iddevops-lab/forsetum-harness` is the canonical product source. Maintainers import
or cherry-pick contributor changes into GitLab for review and validation, then
synchronize the approved canonical SHA to GitHub. Preserve author attribution
and link the original contribution and canonical review. Avoid blind merges in
both directions. The [repository runbook](docs/repository-sync.md) records the
pending cutover gate and maintainer procedure.

## Changes

- Report reproducible bugs with the command, platform, expected result, and
  actual result.
- Propose new modules with purpose, scope, intended users, and major documents.
- Keep English and Indonesian template structures symmetric where both
  languages are supported.
- Update both manifests and the relevant variable registries for template
  changes.
- Update public documentation when public behavior or terminology changes.
- Run `bash scripts/test-product.sh` before submitting a Bash change, or
  `./scripts/test-product.ps1` under the selected native PowerShell.
- Use `bash scripts/build-skill.sh --output /tmp/forsetum-skill` or
  `./scripts/build-skill.ps1 -Output C:\temp\forsetum-skill` with a new output path
  to build the installable skill. Regenerate its runtime only from canonical
  tooling/templates; see [testing compatibility](docs/testing-compatibility.md).
- Keep unpublished history, project records and credentials out of commits.
  Existing repository histories are retained during canonical cutover.

Prefer focused changes, clear documentation, and evidence from supported
platforms. Never include secrets or private project context.
