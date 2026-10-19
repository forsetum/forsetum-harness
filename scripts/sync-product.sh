#!/usr/bin/env bash
# Developer-only publication tool. Runtime/init assets do not depend on this file.
set -Eeuo pipefail
(( BASH_VERSINFO[0] >= 4 )) || { printf 'Bash 4+ is required\n' >&2; exit 1; }
fail() { printf 'STOP: %s\n' "$*" >&2; exit 1; }
usage() {
  cat <<'HELP'
Usage: bash scripts/sync-product.sh --ref refs/heads/main|refs/tags/NAME \
  --approved-sha EXACT_SHA --expected-destination EXACT_SHA|absent [--apply]
Default: validate and report only. Each invocation approves exactly one ref.
Source: git@gitlab.com:iddevops-lab/forsetum-harness.git
Destination: git@github.com:forsetum/forsetum-harness.git
"absent" is allowed only for a new explicit release tag. No URL overrides.
HELP
}
REF= APPROVED= EXPECTED= APPLY=false
while (($#)); do
  case "$1" in
    --ref|--approved-sha|--expected-destination)
      (($# >= 2)) || fail "missing value for $1"
      case "$1" in
        --ref) [[ -z "$REF" ]] || fail 'duplicate ref'; REF="$2" ;;
        --approved-sha) [[ -z "$APPROVED" ]] || fail 'duplicate approval'; APPROVED="$2" ;;
        --expected-destination) [[ -z "$EXPECTED" ]] || fail 'duplicate destination expectation'; EXPECTED="$2" ;;
      esac
      shift 2 ;;
    --apply) [[ "$APPLY" == false ]] || fail 'duplicate apply'; APPLY=true; shift ;;
    --help) usage; exit 0 ;;
    *) fail 'unknown argument (repository identity overrides are prohibited)' ;;
  esac
done
[[ "$APPROVED" =~ ^[0-9a-f]{40}$ ]] || fail 'approved SHA must be an exact lowercase 40-character object ID'
[[ "$EXPECTED" == absent || "$EXPECTED" =~ ^[0-9a-f]{40}$ ]] || fail 'expected destination must be an exact SHA or absent'
case "$REF" in
  refs/heads/main) [[ "$EXPECTED" != absent ]] || fail 'main must already exist at its reviewed destination SHA' ;;
  refs/tags/*) git check-ref-format "$REF" >/dev/null || fail 'invalid tag ref' ;;
  *) fail 'only main or an individual explicit release tag is allowed' ;;
esac
# Isolate repository objects/configuration from the caller, including mixed histories.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES \
  GIT_COMMON_DIR GIT_NAMESPACE GIT_CONFIG_PARAMETERS GIT_CONFIG GIT_SHALLOW_FILE GIT_REPLACE_REF_BASE GIT_TEMPLATE_DIR
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_COUNT=0 GIT_NO_REPLACE_OBJECTS=1
readonly SOURCE_URL='git@gitlab.com:iddevops-lab/forsetum-harness.git'
readonly DESTINATION_URL='git@github.com:forsetum/forsetum-harness.git'
WORK="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-product-sync.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT
cd "$WORK"
git init --template= -q --bare repository.git
cd repository.git
identity_check() {
  [[ "$(git ls-remote --get-url "$SOURCE_URL")" == "$SOURCE_URL" ]] || fail 'source identity changed or URL rewriting detected'
  [[ "$(git ls-remote --get-url "$DESTINATION_URL")" == "$DESTINATION_URL" ]] || fail 'destination identity changed or URL rewriting detected'
}
remote_sha() {
  local output sha remote_ref extra
  output="$(git ls-remote --refs "$1" "$REF")" || fail 'remote ref observation failed'
  if [[ -z "$output" ]]; then printf 'absent\n'; return; fi
  [[ "$output" != *$'\n'* ]] || fail 'unexpected multiple remote refs'
  IFS=$'\t' read -r sha remote_ref extra <<<"$output"
  [[ "$sha" =~ ^[0-9a-f]{40}$ && "$remote_ref" == "$REF" && -z "${extra:-}" ]] || fail 'unexpected remote ref response'
  printf '%s\n' "$sha"
}
check_observations() {
  identity_check
  [[ "$(remote_sha "$SOURCE_URL")" == "$APPROVED" ]] || fail 'source ref no longer equals the approved SHA'
  [[ "$(remote_sha "$DESTINATION_URL")" == "$EXPECTED" ]] || fail 'destination ref no longer equals the observed expectation'
}
check_observations
git fetch --quiet --no-tags "$SOURCE_URL" "$REF:refs/sync/source" || fail 'source fetch failed'
[[ "$(git rev-parse refs/sync/source)" == "$APPROVED" ]] || fail 'fetched source differs from approval'
if [[ "$REF" == refs/heads/main ]]; then
  git cat-file -e "$APPROVED^{commit}" || fail 'main must point to a commit'
  git fetch --quiet --no-tags "$DESTINATION_URL" "$REF:refs/sync/destination" || fail 'destination fetch failed'
  [[ "$(git rev-parse refs/sync/destination)" == "$EXPECTED" ]] || fail 'fetched destination differs from expectation'
  git merge-base --is-ancestor "$EXPECTED" "$APPROVED" || fail 'source rewound or histories diverged; reconcile through review'
elif [[ "$EXPECTED" != absent && "$EXPECTED" != "$APPROVED" ]]; then
  fail 'existing release tags cannot be replaced'
fi
check_observations
if [[ "$EXPECTED" == "$APPROVED" ]]; then
  printf 'NO-OP: %s already equals %s\n' "$REF" "$APPROVED"
  exit 0
fi
if [[ "$APPLY" == false ]]; then
  printf 'DRY-RUN: %s %s -> %s; destination unchanged\n' "$REF" "$EXPECTED" "$APPROVED"
  exit 0
fi
# Ordinary Git update: no force, mirror, prune, deletion or implicit tags.
git -c push.followTags=false push --porcelain "$DESTINATION_URL" "$APPROVED:$REF" || fail 'push rejected; preserve protections and reconcile through review'
identity_check
[[ "$(remote_sha "$DESTINATION_URL")" == "$APPROVED" ]] || fail 'post-push destination differs; inspect remote changes'
printf 'SYNCED: %s equals approved %s\n' "$REF" "$APPROVED"
