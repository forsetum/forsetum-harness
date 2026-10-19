# Public Forsetum Harness Agent Guidance

This file governs work in the self-contained Forsetum Harness product repository.
GitLab `iddevops-lab/forsetum-harness` is the canonical product source; GitHub
`forsetum/forsetum-harness` is its public distribution and contribution entry
point. Canonical-source cutover remains pending the exact-commit approval and
five-environment CI evidence described in [repository synchronization](docs/repository-sync.md).

Use canonical `scripts/` and `template/` sources. Build generated skill runtime
with the native builders; never author it independently. Keep English and
Indonesian structures and variable registries in parity. Run
`bash scripts/test-product.sh` for the complete Bash product gate, or
`./scripts/test-product.ps1` under the selected native PowerShell. Read
[testing compatibility](docs/testing-compatibility.md) for builder commands and
evidence boundaries.

Import contributor changes through canonical review before downstream sync.
Publish only approved product history. Retain existing private history separately;
never copy private records or credentials into product commits. Follow
[public decisions](docs/decisions.md) and the synchronization runbook; ordinary
push rejection is a stop condition, never permission to bypass branch review.

Before changing a target project:

1. Understand the project and request.
2. Analyze existing files and constraints.
3. Discover missing facts.
4. Ask for and record decisions.
5. Check the Adaptive Readiness Gate.
6. Plan before implementation when required.
7. Implement only approved changes.
8. Verify with evidence.
9. Document the result.

Follow the No-Invention Rule. Human decisions are authoritative; do not
invent architecture, dependencies, or requirements. Keep secrets and private
project context out of governance artifacts and logs.
