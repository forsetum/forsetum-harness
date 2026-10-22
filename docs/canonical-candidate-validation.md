# Canonical GitLab candidate validation

This workflow provides GitHub Actions evidence for one exact commit from the canonical GitLab product repository before downstream synchronization. It does not publish the candidate source, synchronize refs, or replace the normal review and synchronization procedure in [repository-sync.md](repository-sync.md).

## Maintainer setup

Before running the workflow, configure the GitHub Actions environment named `canonical-source-validation`:

1. Require approval from designated maintainers. Enable prevention of self-approval where the repository plan supports it.
2. Add environment secret `CANONICAL_GITLAB_READ_KEY` containing a dedicated GitLab deploy key with read-only access to `iddevops-lab/forsetum-harness`. Do not reuse the synchronization key.
3. Add environment secret `CANONICAL_GITLAB_KNOWN_HOSTS` containing GitLab host key entries whose fingerprints were verified through an independent trusted source. Do not generate trust at runtime with `ssh-keyscan`.
4. Keep GitLab main protected. Do not expose these secrets to pull-request or fork workflows.

The workflow grants `contents: read` and accepts no destination, repository, ref, or command overrides. Its source URL is fixed in the workflow.

## Run and review

After this workflow has been merged into GitHub `main` and the protected environment is configured:

1. Open **Actions → Validate canonical GitLab candidate → Run workflow** and select `main`.
2. Enter the full lowercase 40-character SHA of the GitLab `main` candidate.
3. Have an authorized reviewer approve the protected environment gate.
4. Confirm all five jobs pass for the same logged SHA: Ubuntu Bash, macOS Bash 4+, Windows Git Bash, Windows PowerShell 5.1, and Windows PowerShell 7.
5. Record the exact SHA and run link in the canonical review record. If GitLab main advances before synchronization, validate and review the new tip again.

The fetch step checks that the requested SHA is the GitLab main tip before and after a shallow fetch. Any mismatch stops the run. The workflow can only proceed when dispatched from GitHub `main`. A workflow-only pull request cannot run this manual workflow; merge it first, configure the environment, then dispatch it from `main`. The ordinary five-environment workflow still validates the pull request itself.

## Source handling

Each runner fetches the candidate independently from GitLab using pinned host verification. The private key is exposed only to the fetch step, written to a temporary file, and removed when that step exits. Test steps receive no GitLab credentials. The workflow does not upload source artifacts or test artifacts to GitHub. The candidate test scripts execute on GitHub-hosted runners, so do not configure other secrets or write permissions on this environment.

A successful run is compatibility evidence for that exact SHA. It is not approval to synchronize, a security certification, or permission to bypass branch protection. Continue to follow [repository-sync.md](repository-sync.md) for human review and the protected one-way synchronization process.
