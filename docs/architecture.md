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
