# Public product decisions

| Decision | Status | Rationale |
| --- | --- | --- |
| GitLab `iddevops-lab/forsetum-harness` is canonical; GitHub `forsetum/forsetum-harness` is the public downstream. | Confirmed direction; cutover pending. | One reviewed source of product changes. |
| Product source, builders, templates, runtime and validation are self-contained. | Confirmed. | Development and installation must not depend on unpublished sources. |
| Publish only deliberately public product history; retain existing private history separately. | Confirmed. | Public distribution must not expose unpublished context. |
| Synchronize only approved main commits and individual approved release tags, with exact source and destination observations. | Confirmed. | Narrow, reviewable one-way updates without rewriting history. |
| Import GitHub contributions for review in GitLab before downstream publication. | Confirmed. | Preserve authorship while keeping a single canonical integration flow. |
| Require all five GitHub environment results for the exact cutover candidate and keep existing review protections. | Activation gate pending. | Local checks cannot establish remote compatibility or authorization. |
| Correct main through reviewed forward reverts; never replace published release tags. | Confirmed. | Recover without destroying shared history. |

See the [synchronization runbook](repository-sync.md) for activation prerequisites,
identity checks, maintainer credentials and evidence boundaries.
