# Repository ownership and synchronization

The canonical product source is `iddevops-lab/forsetum-harness` on GitLab.
`forsetum/forsetum-harness` on GitHub is the public distribution and contribution
entry point. Synchronization runs only from the canonical product repository to
GitHub. The product repository contains its own intentionally public history;
only that history may be transferred to GitHub.

## Transition status and activation gate

Canonical-source cutover is not activated yet. A maintainer must review the
concrete candidate commit and record successful GitHub Actions evidence for that
exact SHA in all five environments: Ubuntu Bash, macOS Bash 4+, Windows Git
Bash, Windows PowerShell 5.1 and Windows PowerShell 7. Local Linux results do
not satisfy this gate. Review repository identity, complete reachable history,
license, scope and the exact destination SHA before approving a shared-main
update. An earlier candidate's green run cannot approve a changed candidate.

GitLab credentials, protected variables, runner configuration, branch rules and
SSH host verification still require maintainer configuration. Their presence
and a successful synchronization have not been established by local fixtures.
Retain both existing histories during the transition. Do not rewrite, delete,
or publish an existing private repository or its historical objects.

## Maintainer setup

1. Verify the GitLab project namespace and project identity and the GitHub
   organization/repository identity in their authenticated settings. Review both
   SSH URLs below. An identity change requires human review and a code change;
   the tool deliberately has no repository override option.
2. Protect canonical `main` and release tags and retain GitHub required pull
   request review and required checks. `Linux Validation` and `Windows PowerShell
   Validation` aggregate all five GitHub environments. Do not remove or bypass
   these requirements to make synchronization succeed. A blocked push stops the
   process; agree a reviewed, protection-compatible integration path first.
3. Provision a dedicated SSH identity externally with the minimum access needed
   to read this GitLab product and update the approved GitHub product refs.
   Never reuse a broad account token or place credentials in Git URLs, command
   arguments, artifacts or source. Separate keys can be selected through an
   externally maintained SSH configuration for interactive use.
4. Verify GitLab and GitHub host key fingerprints through a trusted independent
   source. Provide pinned `known_hosts` entries before connecting. Do not use
   runtime `ssh-keyscan` output as its own trust evidence.
5. Configure an isolated Linux shell runner with Bash 4+, Git and standard native
   utilities. Review CI changes before allowing any pipeline access to secrets.
   Restrict protected file variables `SYNC_SSH_PRIVATE_KEY` and `SYNC_KNOWN_HOSTS`
   to the canonical protected context. The key file must be usable noninteractively.
   Keep secrets out of merge request and fork pipelines. Restrict who can supply
   pipeline variables and run the protected manual synchronization job.
6. Keep `SYNC_ENABLE` unset normally. After the exact-SHA gate above, a maintainer
   may start a web pipeline on protected canonical `main` with `SYNC_ENABLE=true`,
   `SYNC_APPROVED_SHA` equal to that pipeline commit, and
   `SYNC_EXPECTED_DESTINATION` equal to the independently observed GitHub main
   SHA. Review the manual job before starting it. The job first runs native Linux
   product validation, then dry run and apply with resource serialization. Other
   pipeline sources and projects do not expose the job. Tags use the individual
   reviewed local procedure below; CI does not implicitly publish them.

These settings and SSH files are external prerequisites. The repository does
not grant permission to bypass GitHub or GitLab protections. If ordinary push
is incompatible with the current rules, leave synchronization disabled and
resolve the review/integration procedure with the repository owners.

## Inspect, approve and dry run

Use a clean checkout of the product repository. Never use a repository containing
unpublished history as a publication source. The script fetches exactly one
chosen source ref into a fresh temporary bare repository and ignores caller Git
object stores, global/system Git configuration and URL rewriting. It never
pushes local branches or uses the checkout's remotes. Its immutable identities
are:

```text
source      git@gitlab.com:iddevops-lab/forsetum-harness.git
destination git@github.com:forsetum/forsetum-harness.git
```

With authentication and pinned host verification already configured, inspect:

```bash
git ls-remote --refs git@gitlab.com:iddevops-lab/forsetum-harness.git refs/heads/main
git ls-remote --refs git@github.com:forsetum/forsetum-harness.git refs/heads/main
```

Record the exact source SHA, expected destination SHA, approval and matching CI
run links in the maintainer's review record. Replace the uppercase arguments
below with those full lowercase 40-character SHA values:

```bash
bash scripts/sync-product.sh --ref refs/heads/main \
  --approved-sha APPROVED_SOURCE_SHA --expected-destination OBSERVED_GITHUB_SHA
```

The default only checks and reports. Apply the same reviewed update explicitly:

```bash
bash scripts/sync-product.sh --ref refs/heads/main \
  --approved-sha APPROVED_SOURCE_SHA --expected-destination OBSERVED_GITHUB_SHA --apply
```

Source and destination identities and exact refs are checked before fetching and
again before pushing. Main must exist at the supplied destination SHA and be an
ancestor of the approved source commit. Missing refs, changed observations,
source rewinds, divergent histories and invalid ref names stop the operation.
Only ordinary non-force Git updates are used. Remote protection failures stop
the operation. No mirror, all-branch update, deletion or implicit tag transfer is
supported. The source's complete reachable product history is still transferred
as required by Git; isolated fetching does not remove private ancestors. Review
history before approving any source commit.

Remote checks are observations, not a distributed transaction. A concurrent
forward-only GitHub update could race the final observation; ordinary Git still
rejects a non-fast-forward push, and the script checks the resulting destination
SHA. Serialize publication, freeze direct destination writes during an approved
window, and re-observe/review if either remote changes. A post-push check failure
requires inspection; do not assume it undoes a successful push.

## Individual release tags

Approve one full `refs/tags/NAME` and its exact object SHA, including the tag
object SHA for an annotated tag. Inspect that exact ref on both remotes. An
approved new tag requires an explicit absence expectation:

```bash
bash scripts/sync-product.sh --ref refs/tags/v1.0.0 \
  --approved-sha APPROVED_TAG_OBJECT_SHA --expected-destination absent
bash scripts/sync-product.sh --ref refs/tags/v1.0.0 \
  --approved-sha APPROVED_TAG_OBJECT_SHA --expected-destination absent --apply
```

Existing identical tags are a no-op when their exact SHA is supplied as the
expectation. Existing differing tags are rejected and must never be replaced.
Create a new reviewed release tag to correct a release. Tag wildcards, `--tags`
and global mirroring are prohibited.

## Contribution and recovery

GitHub issues and pull requests are welcome. Maintainers import or cherry-pick
approved contributor changes into GitLab, review and validate them there, and
synchronize the resulting exact canonical SHA to GitHub. Cherry-picking may
change the SHA: review the final canonical commit and its own CI evidence.
Do not automatically merge both directions or push contributor branches through
this tool. Preserve authorship and link the original contribution and review.

If GitHub main has independent changes, stop synchronization. Preserve both
histories, compare the changes and reconcile them through reviewed canonical
commits. Re-observe both tips and obtain approval before retrying. Never force
push to resolve divergence or bypass required pull request review.

Recover a faulty published main change with a reviewed revert commit in the
canonical product repository, validate that new commit, obtain exact-SHA approval
and synchronize it forward. Do not reset shared main, delete refs or rewrite
published/private history. Retain the pre-cutover repositories and records; no
destructive rollback is part of this procedure.

## Local validation

```bash
bash scripts/tests/test-repository-sync.sh
bash scripts/test-product.sh
bash scripts/build-skill.sh --output /tmp/forsetum-skill
```

Choose a new builder destination with an existing parent. The synchronization
fixture uses local bare repositories through a test-only PATH adapter; the
production script has no fixture mode or alternate publishing destination. It
checks dry run, main no-op/fast forward, divergence/rewind, stale approvals,
wrong identity/ref, explicit annotated tags and refusal to replace tags. The
fixture does not prove credentials, server protection rules or live CI success.
This developer tool is excluded from the installable skill runtime.
