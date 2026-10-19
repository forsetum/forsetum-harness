#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HANDOFF="${SCRIPT_DIR}/../scripts/decision-handoff.sh"
INSPECTOR="${SCRIPT_DIR}/../scripts/inspect-repository.sh"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
if command -v sha256sum >/dev/null 2>&1; then
  hash_files() { local file; while IFS= read -r file; do sha256sum "$file"; done; }
else
  hash_files() { local file; while IFS= read -r file; do shasum -a 256 "$file"; done; }
fi
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-handoff-test.XXXXXX")"
trap 'rm -rf -- "$TMP_DIR"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_status() {
  local expected="$1" actual="$2" label="$3"
  [[ "$actual" == "$expected" ]] || fail "$label returned $actual, expected $expected"
}

assert_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

preview_fingerprint() {
  local target="$1" lang="$2" module="$3" output status
  set +e
  output="$(bash "$INSPECTOR" --target "$target" --lang "$lang" --module "$module" --template-root "$REPO_ROOT" 2>&1)"
  status=$?
  set -e
  [[ "$status" == 0 || "$status" == 3 ]] || fail 'preview fingerprint inspection failed'
  printf '%s\n' "$output" | awk -F= '$1 == "PREVIEW_FINGERPRINT" { print $2; exit }'
}

target="$TMP_DIR/target"
mkdir -p "$target/docs"
printf 'local instructions\n' >"$target/AGENTS.md"
printf 'local readme\n' >"$target/README.md"
printf 'local docs\n' >"$target/docs/existing.md"
initializer="$TMP_DIR/initializer"
validator="$TMP_DIR/validator"
spy_log="$TMP_DIR/spy.log"
cat >"$initializer" <<'EOF'
#!/usr/bin/env bash
printf 'initializer' >>"${SPY_LOG:?}"
printf ' %q' "$@" >>"${SPY_LOG:?}"
printf '\n' >>"${SPY_LOG:?}"
EOF
cat >"$validator" <<'EOF'
#!/usr/bin/env bash
printf 'validator' >>"${SPY_LOG:?}"
printf ' %q' "$@" >>"${SPY_LOG:?}"
printf '\n' >>"${SPY_LOG:?}"
EOF
chmod +x "$initializer" "$validator"
export SPY_LOG="$spy_log"
: >"$spy_log"

set +e
missing_output="$(bash "$HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$target" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer" \
  --validator "$validator" \
  --backup-mapping 'AGENTS.md=.forsetum-backups/task/AGENTS.md' \
  --rollback-mapping 'AGENTS.md=restore AGENTS.md' \
  --gitignore-decision NO 2>&1)"
missing_status=$?
set -e
assert_status 2 "$missing_status" 'missing conflict approval'
assert_contains "$missing_output" 'conflict decision set must exactly match target conflicts'
[[ ! -s "$spy_log" ]] || fail 'missing conflict approval invoked a delegated command'
[[ ! -e "$target/.forsetum-backups" ]] || fail 'missing conflict approval created a backup'

: >"$spy_log"
set +e
extra_output="$(bash "$HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer" \
  --validator "$validator" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'README.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'docs/=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'backlog.md=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-mapping 'AGENTS.md=.forsetum-backups/task/AGENTS.md' \
  --backup-mapping 'README.md=.forsetum-backups/task/README.md' \
  --backup-mapping 'docs/=.forsetum-backups/task/docs' \
  --backup-mapping 'backlog.md=.forsetum-backups/task/backlog.md' \
  --rollback-mapping 'AGENTS.md=restore AGENTS.md' \
  --rollback-mapping 'README.md=restore README.md' \
  --rollback-mapping 'docs/=restore docs' \
  --rollback-mapping 'backlog.md=restore backlog.md' \
  --gitignore-decision NO 2>&1)"
extra_status=$?
set -e
assert_status 2 "$extra_status" 'extra conflict approval'
assert_contains "$extra_output" 'conflict decision set must exactly match target conflicts'
[[ ! -s "$spy_log" ]] || fail 'extra conflict approval invoked a delegated command'
[[ ! -e "$target/.forsetum-backups" ]] || fail 'extra conflict approval created a backup'

: >"$spy_log"
set +e
unsafe_output="$(bash "$HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer" \
  --validator "$validator" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'README.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'docs/=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-mapping 'AGENTS.md=../outside/AGENTS.md' \
  --backup-mapping 'README.md=.forsetum-backups/task/README.md' \
  --backup-mapping 'docs/=../outside/docs' \
  --rollback-mapping 'AGENTS.md=restore AGENTS.md' \
  --rollback-mapping 'README.md=restore README.md' \
  --rollback-mapping 'docs/=restore docs' \
  --gitignore-decision NO 2>&1)"
unsafe_status=$?
set -e
assert_status 2 "$unsafe_status" 'unsafe backup mapping'
assert_contains "$unsafe_output" 'backup mapping must remain within target'
[[ ! -s "$spy_log" ]] || fail 'unsafe backup mapping invoked a delegated command'
[[ ! -e "$target/.forsetum-backups" ]] || fail 'unsafe backup mapping created a backup'

target_fingerprint="$(preview_fingerprint "$target" id app-maintenance)"
[[ "$target_fingerprint" =~ ^[0-9a-fA-F]{64}$ ]] || fail 'preview fingerprint was not emitted'

dangling_target="$TMP_DIR/dangling-target"
mkdir -p "$dangling_target"
ln -s missing-readme-target "$dangling_target/README.md"
dangling_fingerprint="$(preview_fingerprint "$dangling_target" id app-maintenance)"
[[ "$dangling_fingerprint" =~ ^[0-9a-fA-F]{64}$ ]] || fail 'dangling preview fingerprint was not emitted'
: >"$spy_log"
set +e
dangling_output="$(bash "$HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$dangling_target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer" \
  --validator "$validator" \
  --preview-fingerprint "$dangling_fingerprint" \
  --conflict 'README.md=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-mapping 'README.md=.forsetum-backups/task/README.md' \
  --rollback-mapping 'README.md=restore README.md' \
  --gitignore-decision NO 2>&1)"
dangling_status=$?
set -e
assert_status 2 "$dangling_status" 'dangling governance symlink replacement'
assert_contains "$dangling_output" 'could not inventory approved path: README.md'
[[ ! -s "$spy_log" ]] || fail 'dangling governance symlink invoked a delegated command'
[[ ! -e "$dangling_target/.forsetum-backups" ]] || fail 'dangling governance symlink created a backup'

: >"$spy_log"
set +e
stale_fingerprint_output="$(bash "$HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer" \
  --validator "$validator" \
  --preview-fingerprint "$(printf '0%.0s' {1..64})" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'README.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'docs/=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-mapping 'AGENTS.md=.forsetum-backups/task/AGENTS.md' \
  --backup-mapping 'README.md=.forsetum-backups/task/README.md' \
  --backup-mapping 'docs/=.forsetum-backups/task/docs' \
  --rollback-mapping 'AGENTS.md=restore AGENTS.md' \
  --rollback-mapping 'README.md=restore README.md' \
  --rollback-mapping 'docs/=restore docs' \
  --gitignore-decision NO 2>&1)"
stale_fingerprint_status=$?
set -e
assert_status 2 "$stale_fingerprint_status" 'stale preview fingerprint'
assert_contains "$stale_fingerprint_output" 'preview fingerprint does not match the current target preview'
[[ ! -s "$spy_log" ]] || fail 'stale preview fingerprint invoked a delegated command'
[[ ! -e "$target/.forsetum-backups" ]] || fail 'stale preview fingerprint created a backup'

approved_output="$(bash "$HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer" \
  --validator "$validator" \
  --preview-fingerprint "$target_fingerprint" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'README.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'docs/=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-mapping 'AGENTS.md=.forsetum-backups/task/AGENTS.md' \
  --backup-mapping 'README.md=.forsetum-backups/task/README.md' \
  --backup-mapping 'docs/=.forsetum-backups/task/docs' \
  --rollback-mapping 'AGENTS.md=restore AGENTS.md' \
  --rollback-mapping 'README.md=restore README.md' \
  --rollback-mapping 'docs/=restore docs' \
  --gitignore-decision NO)"
assert_contains "$approved_output" 'State: BOOTSTRAP_APPROVED'
assert_contains "$approved_output" 'BACKUP_MAPPING=AGENTS.md -> .forsetum-backups/task/AGENTS.md'
assert_contains "$approved_output" 'BACKUP_MAPPING=README.md -> .forsetum-backups/task/README.md'
assert_contains "$approved_output" 'BACKUP_MAPPING=docs/ -> .forsetum-backups/task/docs'
assert_contains "$(cat "$spy_log")" "initializer --lang id"
assert_contains "$(cat "$spy_log")" "--module app-maintenance"
printf -v quoted_target '%q' "$target"
assert_contains "$(cat "$spy_log")" "--target $quoted_target"
assert_contains "$(cat "$spy_log")" '--force'
assert_contains "$(cat "$spy_log")" '--name'
assert_contains "$(cat "$spy_log")" "validator --target $quoted_target"
assert_contains "$(cat "$spy_log")" '--mode instantiated'
cmp -s "$target/AGENTS.md" "$target/.forsetum-backups/task/AGENTS.md" \
  || fail 'AGENTS.md backup does not match the approved source'
cmp -s "$target/README.md" "$target/.forsetum-backups/task/README.md" \
  || fail 'README.md backup does not match the approved source'
cmp -s "$target/docs/existing.md" "$target/.forsetum-backups/task/docs/existing.md" \
  || fail 'docs/ backup does not match the approved source'

partial_target="$TMP_DIR/partial-target"
mkdir -p "$partial_target/docs" "$partial_target/.forsetum-backups/task/docs"
printf 'agents source\n' >"$partial_target/AGENTS.md"
printf 'docs source\n' >"$partial_target/docs/existing.md"
printf 'stale backup\n' >"$partial_target/.forsetum-backups/task/docs/existing.md"
partial_before_inventory=$(find "$partial_target" -mindepth 1 -print | LC_ALL=C sort)
partial_before_hashes=$(find "$partial_target" -type f -print | LC_ALL=C sort | hash_files)
partial_fingerprint="$(preview_fingerprint "$partial_target" id app-maintenance)"
: >"$spy_log"
set +e
partial_output="$(cd / && bash "$HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$partial_target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer" \
  --validator "$validator" \
  --preview-fingerprint "$partial_fingerprint" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'docs/=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-mapping 'AGENTS.md=.forsetum-backups/task/AGENTS.md' \
  --backup-mapping 'docs/=.forsetum-backups/task/docs' \
  --rollback-mapping 'AGENTS.md=restore AGENTS.md' \
  --rollback-mapping 'docs/=restore docs' \
  --gitignore-decision NO 2>&1)"
partial_status=$?
set -e
assert_status 2 "$partial_status" 'partial backup preflight failure'
assert_contains "$partial_output" 'existing backup does not match approved source path: docs/'
[[ ! -e "$partial_target/.forsetum-backups/task/AGENTS.md" ]] \
  || fail 'partial backup preflight left the first backup mutation behind'
[[ -s "$spy_log" ]] && fail 'partial backup preflight invoked a delegated command'
[[ "$(find "$partial_target" -mindepth 1 -print | LC_ALL=C sort)" == "$partial_before_inventory" ]] \
  || fail 'partial backup preflight changed target inventory'
[[ "$(find "$partial_target" -type f -print | LC_ALL=C sort | hash_files)" == "$partial_before_hashes" ]] \
  || fail 'partial backup preflight changed target hashes'

printf 'PASS: decision handoff safety fixtures\n'
