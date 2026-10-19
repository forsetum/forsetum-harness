# Public Architecture

```text
             Governance Core
                    │
                    ▼
             Domain Module
                    │
                    ▼
              Bundled Harness
                    │
                    ▼
               Target Project
                    │
                    ▼
                 AI Agent
```

The core contains universal governance documents. A selected domain module is
applied as an overlay. `manifest.json` describes modules and their readiness
variables. English and Indonesian libraries use the same module structure.

The scaffolder initializes a target directory, the bundler assembles core plus
module into a directory or ZIP, and the validator checks files, links, manifests,
and placeholders. This public architecture describes the local Harness; it
does not expose or define Forsetum Platform internals.

## Product source and distribution

The self-contained product repository owns canonical templates, manifests,
CLI/validators, native builders, curated skill sources and product tests. The
checked-in skill runtime is generated from canonical tooling and templates.
Developer-only build, test and synchronization tools do not enter that runtime.
See [testing compatibility](testing-compatibility.md) for local commands.

Canonical changes are reviewed in GitLab `iddevops-lab/forsetum-harness` and flow
one way to the GitHub public downstream `forsetum/forsetum-harness`. GitHub
contributions are imported into canonical review before publication. The
synchronization tool uses a fresh bare repository, fixed remote identities,
exact approved source SHA and expected destination SHA, and one explicit main
or release-tag ref per operation. It cannot mirror, force push or delete refs.

Cutover remains pending exact-candidate review, all five GitHub CI environments
and externally configured protected credentials/branch rules. Existing private
history stays separate and is retained. Recovery uses canonical revert commits
and reviewed forward synchronization. See the [runbook](repository-sync.md) and
[public decision register](decisions.md).
