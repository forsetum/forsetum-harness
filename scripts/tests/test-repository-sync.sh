#!/usr/bin/env bash
# Test-only PATH adapter maps the immutable production identities to local fixtures.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-sync-test.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
REAL_GIT="$(command -v git)"; export REAL_GIT
SOURCE_FIXTURE="$WORK/source.git"; DEST_FIXTURE="$WORK/destination.git"; export SOURCE_FIXTURE DEST_FIXTURE
mkdir "$WORK/bin"
cat >"$WORK/bin/git" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$*" == 'ls-remote --get-url '* ]]; then
  [[ "${SYNC_TEST_REWRITE:-}" != yes ]] || { printf 'git@example.invalid:wrong.git\n'; exit 0; }
  printf '%s\n' "$3"
  exit 0
fi
args=()
for arg in "$@"; do
  case "$arg" in
    git@gitlab.com:iddevops-lab/forsetum-harness.git) arg="$SOURCE_FIXTURE" ;;
    git@github.com:forsetum/forsetum-harness.git) arg="$DEST_FIXTURE" ;;
  esac
  args+=("$arg")
done
if [[ "${SYNC_TEST_CHECK_TEMPLATE:-}" == yes && " ${args[*]} " == *' init '* ]]; then
  "$REAL_GIT" "${args[@]}"
  if "$REAL_GIT" --git-dir=repository.git config --get test.template >/dev/null; then
    printf 'FAIL: inherited template configuration entered scratch repository\n' >&2
    exit 1
  fi
  for injected in hooks/pre-push refs/heads/template-injected objects/info/alternates; do
    [[ ! -e "repository.git/$injected" ]] || {
      printf 'FAIL: inherited template file entered scratch repository: %s\n' "$injected" >&2
      exit 1
    }
  done
  exit 0
fi
exec "$REAL_GIT" "${args[@]}"
WRAPPER
chmod +x "$WORK/bin/git"
"$REAL_GIT" init -q --bare "$SOURCE_FIXTURE"
"$REAL_GIT" init -q --bare "$DEST_FIXTURE"
"$REAL_GIT" init -q "$WORK/author"
cd "$WORK/author"
"$REAL_GIT" config user.name 'Sync Fixture'
"$REAL_GIT" config user.email 'fixture@example.invalid'
"$REAL_GIT" checkout -qb main
printf 'a\n' > product
"$REAL_GIT" add product
"$REAL_GIT" commit -qm a
A="$("$REAL_GIT" rev-parse HEAD)"
"$REAL_GIT" push -q "$SOURCE_FIXTURE" main
"$REAL_GIT" push -q "$DEST_FIXTURE" main
printf 'b\n' >> product
"$REAL_GIT" commit -qam b
B="$("$REAL_GIT" rev-parse HEAD)"
"$REAL_GIT" push -q "$SOURCE_FIXTURE" main
"$REAL_GIT" tag -a v1.0.0 -m release
TAG="$("$REAL_GIT" rev-parse refs/tags/v1.0.0)"
"$REAL_GIT" push -q "$SOURCE_FIXTURE" refs/tags/v1.0.0
export PATH="$WORK/bin:$PATH"
sync() { bash "$ROOT/scripts/sync-product.sh" "$@" >"$WORK/result.log" 2>&1; }
expect_reject() { if sync "$@"; then fail "accepted unsafe operation: $*"; fi; }
ref() { "$REAL_GIT" --git-dir="$DEST_FIXTURE" rev-parse "$1"; }
# First invocation must succeed and therefore fails RED before the implementation exists.
sync --ref refs/heads/main --approved-sha "$B" --expected-destination "$A" || { cat "$WORK/result.log"; fail 'dry run failed'; }
[[ "$(ref refs/heads/main)" == "$A" ]] || fail 'dry run mutated destination'
# An inherited Git template must not add config, refs, object alternates or hooks.
mkdir -p "$WORK/hostile-template/hooks" "$WORK/hostile-template/refs/heads" \
  "$WORK/hostile-template/objects/info" "$WORK/private-objectstore"
printf '[test]\n  template = injected\n' >"$WORK/hostile-template/config"
printf '%s\n' "$A" >"$WORK/hostile-template/refs/heads/template-injected"
printf '%s\n' "$WORK/private-objectstore" >"$WORK/hostile-template/objects/info/alternates"
cat >"$WORK/hostile-template/hooks/pre-push" <<'HOOK'
#!/usr/bin/env bash
printf 'inherited hook ran\n' >"$SYNC_TEST_HOOK_MARKER"
HOOK
chmod +x "$WORK/hostile-template/hooks/pre-push"
SYNC_TEST_HOOK_MARKER="$WORK/template-hook-ran"; export SYNC_TEST_HOOK_MARKER
GIT_TEMPLATE_DIR="$WORK/hostile-template" SYNC_TEST_CHECK_TEMPLATE=yes \
  sync --ref refs/heads/main --approved-sha "$B" --expected-destination "$A" --apply || {
    cat "$WORK/result.log"; fail 'inherited template isolation failed'
  }
[[ ! -e "$SYNC_TEST_HOOK_MARKER" ]] || fail 'inherited template hook executed'
[[ "$(ref refs/heads/main)" == "$B" ]] || fail 'main did not advance'
sync --ref refs/heads/main --approved-sha "$B" --expected-destination "$B" --apply || fail 'no-op failed'
expect_reject --ref refs/heads/main --approved-sha "$B" --expected-destination "$A" --apply
expect_reject --ref refs/heads/main --approved-sha "$A" --expected-destination "$B" --apply
expect_reject --ref refs/heads/main --approved-sha "$B" --expected-destination absent --apply
expect_reject --ref refs/heads/topic --approved-sha "$B" --expected-destination "$B" --apply
expect_reject --ref 'refs/tags/*' --approved-sha "$TAG" --expected-destination absent --apply
expect_reject --ref refs/tags/missing --approved-sha "$TAG" --expected-destination absent --apply
expect_reject --source-url git@example.invalid:other.git --ref refs/heads/main --approved-sha "$B" --expected-destination "$B" --apply
expect_reject --destination-url git@example.invalid:other.git --ref refs/heads/main --approved-sha "$B" --expected-destination "$B" --apply
SYNC_TEST_REWRITE=yes expect_reject --ref refs/heads/main --approved-sha "$B" --expected-destination "$B" --apply
sync --ref refs/tags/v1.0.0 --approved-sha "$TAG" --expected-destination absent || fail 'tag dry run failed'
if "$REAL_GIT" --git-dir="$DEST_FIXTURE" show-ref --verify --quiet refs/tags/v1.0.0; then fail 'tag dry run mutated destination'; fi
sync --ref refs/tags/v1.0.0 --approved-sha "$TAG" --expected-destination absent --apply || { cat "$WORK/result.log"; fail 'tag creation failed'; }
[[ "$(ref refs/tags/v1.0.0)" == "$TAG" ]] || fail 'annotated tag object changed'
sync --ref refs/tags/v1.0.0 --approved-sha "$TAG" --expected-destination "$TAG" --apply || fail 'tag no-op failed'
expect_reject --ref refs/tags/v1.0.0 --approved-sha "$TAG" --expected-destination absent --apply
# Publish a different same-name tag in the source fixture; it must never replace destination.
"$REAL_GIT" tag -fa v1.0.0 -m changed >/dev/null
NEW_TAG="$("$REAL_GIT" rev-parse refs/tags/v1.0.0)"
"$REAL_GIT" push -q --force "$SOURCE_FIXTURE" refs/tags/v1.0.0
expect_reject --ref refs/tags/v1.0.0 --approved-sha "$NEW_TAG" --expected-destination "$TAG" --apply
[[ "$(ref refs/tags/v1.0.0)" == "$TAG" ]] || fail 'existing tag replaced'
# Independent destination work must stop synchronization, even when its SHA was observed.
"$REAL_GIT" checkout -qb destination "$A"
printf 'c\n' > destination-only
"$REAL_GIT" add destination-only
"$REAL_GIT" commit -qm c
C="$("$REAL_GIT" rev-parse HEAD)"
"$REAL_GIT" push -q --force "$DEST_FIXTURE" HEAD:refs/heads/main
expect_reject --ref refs/heads/main --approved-sha "$B" --expected-destination "$C" --apply
[[ "$(ref refs/heads/main)" == "$C" ]] || fail 'divergent destination changed'
# A source rewind to A cannot rewind destination B.
"$REAL_GIT" push -q --force "$SOURCE_FIXTURE" "$A:refs/heads/main"
"$REAL_GIT" push -q --force "$DEST_FIXTURE" "$B:refs/heads/main"
expect_reject --ref refs/heads/main --approved-sha "$A" --expected-destination "$B" --apply
[[ "$(ref refs/heads/main)" == "$B" ]] || fail 'source rewind propagated'
printf 'PASS: isolated one-way synchronization, approvals, dry run, tags and divergence\n'
