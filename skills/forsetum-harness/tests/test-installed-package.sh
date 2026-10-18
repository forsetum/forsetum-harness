#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
BUILDER="${ROOT_DIR}/scripts/build-skill.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-installed-package.XXXXXX")"
INSTALLED_SKILL="${TMP_DIR}/installed skill"
trap 'rm -rf -- "$TMP_DIR"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

assert_status() {
  local expected="$1" actual="$2" label="$3"
  [[ "$actual" == "$expected" ]] || fail "$label returned $actual, expected $expected"
}

hash_tree() {
  local root="$1" file relative
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    relative="${file#"$root/"}"
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$file" | awk -v path="$relative" '{ print $1 "  " path }'
    else
      shasum -a 256 "$file" | awk -v path="$relative" '{ print $1 "  " path }'
    fi
  done < <(find "$root" -type f -print | LC_ALL=C sort)
}

inventory_tree() {
  local root="$1" path relative type
  find "$root" -mindepth 1 -print | while IFS= read -r path; do
    relative="${path#"$root/"}"
    if [[ -d "$path" ]]; then type=d; else type=f; fi
    printf '%s %s\n' "$relative" "$type"
  done | LC_ALL=C sort
}

source_inventory_tree() {
  inventory_tree "$1" | grep -v '^\.forsetum-backups\(/\| \)' || true
}

source_hash_tree() {
  hash_tree "$1" | grep -v '  \.forsetum-backups/' || true
}

bash "$BUILDER" --output "$INSTALLED_SKILL" >"$TMP_DIR/build.out" 2>&1 \
  || fail 'native builder could not create the installed skill'
[[ "$(find "$INSTALLED_SKILL" -type f -name SKILL.md | wc -l | tr -d ' ')" == 1 ]] \
  || fail 'installed package must have one discoverable skill'

INSPECTOR="$INSTALLED_SKILL/scripts/inspect-repository.sh"
DECISION_HANDOFF="$INSTALLED_SKILL/scripts/decision-handoff.sh"
DECISION_HANDOFF_PS1="$INSTALLED_SKILL/scripts/decision-handoff.ps1"
RUNTIME_ROOT="$INSTALLED_SKILL/runtime"
[[ -x "$INSPECTOR" ]] || fail 'installed inspector is not executable'
[[ -x "$DECISION_HANDOFF" ]] || fail 'installed decision handoff is not executable'
[[ -f "$DECISION_HANDOFF_PS1" ]] || fail 'installed PowerShell decision handoff is missing'
grep -Fq 'param (' "$DECISION_HANDOFF_PS1" || fail 'PowerShell handoff does not declare native parameters'
grep -Fq '& $Initializer -Lang $Lang -Module $Module -Target $Target -Force -Name $targetName' "$DECISION_HANDOFF_PS1" \
  || fail 'PowerShell handoff does not forward target/profile arguments natively'
grep -Fq '& $Validator -Target $Target -Mode instantiated' "$DECISION_HANDOFF_PS1" \
  || fail 'PowerShell handoff does not forward validator target context natively'
if grep -Fq 'bash -x' "$DECISION_HANDOFF_PS1"; then
  fail 'PowerShell handoff requires Bash -x on Windows'
fi
[[ -f "$RUNTIME_ROOT/template/en/manifest.json" ]] || fail 'installed English manifest is missing'
[[ -f "$RUNTIME_ROOT/template/id/manifest.json" ]] || fail 'installed Indonesian manifest is missing'

empty_target="$TMP_DIR/empty"
mkdir -p "$empty_target"
before_inventory="$(inventory_tree "$empty_target")"
before_hashes="$(hash_tree "$empty_target")"
set +e
empty_output="$(cd / && bash "$INSPECTOR" --target "$empty_target" --lang en --module web-starter --template-root "$RUNTIME_ROOT" 2>"$TMP_DIR/empty.err")"
empty_status=$?
set -e
assert_status 0 "$empty_status" 'empty target inspection'
assert_contains "$empty_output" 'STATE=PROCEED_PENDING_APPROVAL'
assert_contains "$empty_output" "MANIFEST=$RUNTIME_ROOT/template/en/manifest.json"
assert_contains "$empty_output" 'PREVIEW_PATH=AGENTS.md'
assert_contains "$empty_output" 'OPERATION=CREATE'
assert_contains "$empty_output" 'CREATE_PATH=AGENTS.md'
[[ "$(inventory_tree "$empty_target")" == "$before_inventory" ]] || fail 'empty inspection changed target inventory'
[[ "$(hash_tree "$empty_target")" == "$before_hashes" ]] || fail 'empty inspection changed target hashes'
empty_preview="$TMP_DIR/empty.preview"
printf '%s\n' "$empty_output" >"$empty_preview"

set +e
installed_default_output="$(cd / && bash "$INSPECTOR" --target "$empty_target" --lang en --module web-starter 2>"$TMP_DIR/default.err")"
installed_default_status=$?
set -e
assert_status 0 "$installed_default_status" 'installed package default-root inspection'
assert_contains "$installed_default_output" "MANIFEST=$RUNTIME_ROOT/template/en/manifest.json"

non_governance="$TMP_DIR/non-governance"
mkdir -p "$non_governance/src"
printf 'source\n' >"$non_governance/src/app.txt"
before_inventory="$(inventory_tree "$non_governance")"
before_hashes="$(hash_tree "$non_governance")"
set +e
non_governance_output="$(cd / && bash "$INSPECTOR" --target "$non_governance" --lang id --module app-maintenance --template-root "$RUNTIME_ROOT")"
non_governance_status=$?
set -e
assert_status 0 "$non_governance_status" 'non-governance inspection'
assert_contains "$non_governance_output" 'STATE=PROCEED_PENDING_APPROVAL'
[[ "$(inventory_tree "$non_governance")" == "$before_inventory" ]] || fail 'non-governance inspection changed target inventory'
[[ "$(hash_tree "$non_governance")" == "$before_hashes" ]] || fail 'non-governance inspection changed target hashes'

conflict_target="$TMP_DIR/conflict"
mkdir -p "$conflict_target/docs"
printf 'keep\n' >"$conflict_target/AGENTS.md"
printf 'keep docs\n' >"$conflict_target/docs/existing.md"
before_inventory="$(inventory_tree "$conflict_target")"
before_hashes="$(hash_tree "$conflict_target")"
set +e
conflict_output="$(cd / && bash "$INSPECTOR" --target "$conflict_target" --lang id --module app-maintenance --template-root "$RUNTIME_ROOT")"
conflict_status=$?
set -e
assert_status 3 "$conflict_status" 'conflict inspection'
assert_contains "$conflict_output" 'STATE=CONFLICT_REVIEW'
assert_contains "$conflict_output" 'CONFLICT=AGENTS.md'
assert_contains "$conflict_output" 'CONFLICT=docs/'
assert_contains "$conflict_output" 'CONFLICT_ACTION=STOP_AND_REQUEST_USER_DECISION'
assert_contains "$conflict_output" 'PREVIEW_PATH=AGENTS.md'
assert_contains "$conflict_output" 'OPERATION=REVIEW_REQUIRED'
assert_contains "$conflict_output" 'PATH=AGENTS.md'
assert_contains "$conflict_output" 'IMPACT=existing content remains untouched unless explicitly approved'
assert_contains "$conflict_output" 'BACKUP_BEHAVIOR=preview only; backup required before replacement'
assert_contains "$conflict_output" 'BACKUP_PATH=.forsetum-backups/forsetum-harness-preview/AGENTS.md'
assert_contains "$conflict_output" 'APPROVAL_DECISION=REQUIRED_FOR_THIS_PATH'
assert_contains "$conflict_output" 'NEXT_STATE=CONFLICT_REVIEW'
assert_contains "$conflict_output" 'AVAILABLE_OPERATIONS=PRESERVE|MERGE|REPLACE_WITH_BACKUP|SKIP'
assert_contains "$conflict_output" 'PREVIEW_BACKUP_ROOT=.forsetum-backups/forsetum-harness-preview'
assert_contains "$conflict_output" 'BACKUP_MAPPING=AGENTS.md -> .forsetum-backups/forsetum-harness-preview/AGENTS.md'
assert_contains "$conflict_output" 'ROLLBACK_COMMAND=restore --from .forsetum-backups/forsetum-harness-preview/AGENTS.md --to AGENTS.md'
assert_contains "$conflict_output" 'GITIGNORE_DECISION=REQUIRED_YES_OR_NO'
conflict_fingerprint="$(printf '%s\n' "$conflict_output" | awk -F= '$1 == "PREVIEW_FINGERPRINT" { print $2; exit }')"
[[ "$conflict_fingerprint" =~ ^[0-9a-fA-F]{64}$ ]] || fail 'installed conflict inspection did not emit a preview fingerprint'
[[ "$(inventory_tree "$conflict_target")" == "$before_inventory" ]] || fail 'conflict inspection changed target inventory'
[[ "$(hash_tree "$conflict_target")" == "$before_hashes" ]] || fail 'conflict inspection changed target hashes'
[[ ! -e "$conflict_target/.forsetum-backups" ]] || fail 'conflict inspection created a backup root'
conflict_preview="$TMP_DIR/conflict.preview"
printf '%s\n' "$conflict_output" >"$conflict_preview"

failure_target="$TMP_DIR/failure-conflict"
mkdir -p "$failure_target/docs"
printf 'keep\n' >"$failure_target/AGENTS.md"
printf 'keep docs\n' >"$failure_target/docs/existing.md"

initializer_spy="$TMP_DIR/initializer-spy"
validator_spy="$TMP_DIR/validator-spy"
cat >"$initializer_spy" <<'EOF'
#!/usr/bin/env bash
printf 'initializer-called\n' >>"${SPY_LOG:?}"
printf 'initializer-cwd=%q\n' "$PWD" >>"${SPY_LOG:?}"
printf 'initializer-args=%q\n' "$@" >>"${SPY_LOG:?}"
EOF
cat >"$validator_spy" <<'EOF'
#!/usr/bin/env bash
printf 'validator-called\n' >>"${SPY_LOG:?}"
printf 'validator-cwd=%q\n' "$PWD" >>"${SPY_LOG:?}"
printf 'validator-args=%q\n' "$@" >>"${SPY_LOG:?}"
EOF
chmod +x "$initializer_spy" "$validator_spy"
export SPY_LOG="$TMP_DIR/command-spy.log"
: >"$SPY_LOG"

set +e
missing_metadata_output="$(bash "$DECISION_HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$conflict_target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer_spy" \
  --validator "$validator_spy" 2>&1)"
missing_metadata_status=$?
set -e
assert_status 2 "$missing_metadata_status" 'replacement without recovery metadata'
assert_contains "$missing_metadata_output" 'ERROR: conflict decision set must exactly match target conflicts'
[[ ! -s "$SPY_LOG" ]] || fail 'incomplete replacement metadata invoked initializer or validator'

: >"$SPY_LOG"
set +e
bare_operation_output="$(bash "$DECISION_HANDOFF" \
  --decision REPLACE_WITH_BACKUP \
  --target "$conflict_target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer_spy" \
  --validator "$validator_spy" \
  --preview-fingerprint "$conflict_fingerprint" \
  --backup-path '.forsetum-backups/forsetum-harness-preview/AGENTS.md' \
  --rollback-command 'restore --from .forsetum-backups/forsetum-harness-preview/AGENTS.md --to AGENTS.md' \
  --gitignore-decision NO 2>&1)"
bare_operation_status=$?
set -e
assert_status 2 "$bare_operation_status" 'bare replacement operation'
assert_contains "$bare_operation_output" 'ERROR: unsupported decision: REPLACE_WITH_BACKUP'
[[ ! -s "$SPY_LOG" ]] || fail 'bare replacement operation invoked initializer or validator'
[[ "$(inventory_tree "$conflict_target")" == "$before_inventory" ]] || fail 'bare replacement operation changed target inventory'
[[ "$(hash_tree "$conflict_target")" == "$before_hashes" ]] || fail 'bare replacement operation changed target hashes'

approved_output="$(cd / && bash "$DECISION_HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$conflict_target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer_spy" \
  --validator "$validator_spy" \
  --preview-fingerprint "$conflict_fingerprint" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'docs/=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-mapping 'AGENTS.md=.forsetum-backups/forsetum-harness-preview/AGENTS.md' \
  --backup-mapping 'docs/=.forsetum-backups/forsetum-harness-preview/docs' \
  --rollback-mapping 'AGENTS.md=restore --from .forsetum-backups/forsetum-harness-preview/AGENTS.md --to AGENTS.md' \
  --rollback-mapping 'docs/=restore --from .forsetum-backups/forsetum-harness-preview/docs --to docs/' \
  --gitignore-decision NO)" \
  || fail 'approved replacement handoff should delegate successfully'
assert_contains "$approved_output" 'State: BOOTSTRAP_APPROVED'
assert_contains "$approved_output" 'Mutation: delegated'
assert_contains "$approved_output" 'BACKUP_MAPPING=AGENTS.md -> .forsetum-backups/forsetum-harness-preview/AGENTS.md'
assert_contains "$approved_output" 'ROLLBACK_MAPPING=AGENTS.md -> restore --from .forsetum-backups/forsetum-harness-preview/AGENTS.md --to AGENTS.md'
assert_contains "$approved_output" 'GITIGNORE_DECISION=NO'
assert_contains "$(cat "$SPY_LOG")" 'initializer-called'
assert_contains "$(cat "$SPY_LOG")" 'validator-called'
assert_contains "$(cat "$SPY_LOG")" "initializer-args=--lang"
assert_contains "$(cat "$SPY_LOG")" "initializer-args=id"
assert_contains "$(cat "$SPY_LOG")" "initializer-args=--module"
assert_contains "$(cat "$SPY_LOG")" "initializer-args=app-maintenance"
assert_contains "$(cat "$SPY_LOG")" "initializer-args=--target"
assert_contains "$(cat "$SPY_LOG")" "initializer-args=$conflict_target"
assert_contains "$(cat "$SPY_LOG")" 'initializer-args=--force'
assert_contains "$(cat "$SPY_LOG")" 'initializer-args=--name'
assert_contains "$(cat "$SPY_LOG")" "validator-args=--target"
assert_contains "$(cat "$SPY_LOG")" "validator-args=$conflict_target"
assert_contains "$(cat "$SPY_LOG")" 'validator-args=--mode'
assert_contains "$(cat "$SPY_LOG")" 'validator-args=instantiated'
assert_contains "$(cat "$SPY_LOG")" 'initializer-cwd=/'
assert_contains "$(cat "$SPY_LOG")" 'validator-cwd=/'
[[ -f "$conflict_target/.forsetum-backups/forsetum-harness-preview/AGENTS.md" ]] \
  || fail 'approved replacement did not create the exact AGENTS.md backup'
[[ -f "$conflict_target/.forsetum-backups/forsetum-harness-preview/docs/existing.md" ]] \
  || fail 'approved replacement did not create the exact docs/ backup mapping'
cmp -s "$conflict_target/AGENTS.md" "$conflict_target/.forsetum-backups/forsetum-harness-preview/AGENTS.md" \
  || fail 'AGENTS.md backup hash/content does not match before initializer'
cmp -s "$conflict_target/docs/existing.md" "$conflict_target/.forsetum-backups/forsetum-harness-preview/docs/existing.md" \
  || fail 'docs/ backup hash/content does not match before initializer'
[[ "$(source_inventory_tree "$conflict_target")" == "$(printf '%s\n' 'AGENTS.md f' 'docs d' 'docs/existing.md f' | sort)" ]] \
  || fail 'approved handoff changed the approved source inventory'
[[ "$(source_hash_tree "$conflict_target")" == "$(printf '%s\n' "$before_hashes" | grep -v '  \.forsetum-backups/' || true)" ]] \
  || fail 'approved handoff changed the approved source hashes'

runtime_target="$TMP_DIR/runtime-target"
mkdir -p "$runtime_target"
# The canonical initializer accepts a project name but intentionally leaves
# other required template variables for the consuming project to define. Use a
# package-local wrapper to model that completed instantiation phase before the
# canonical instantiated validator runs.
runtime_initializer="$TMP_DIR/runtime-initializer"
cat >"$runtime_initializer" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

"$RUNTIME_ROOT/scripts/init.sh" "$@"

target=''
while (($# > 0)); do
  if [[ "$1" == --target && $# -ge 2 ]]; then
    target="$2"
    shift 2
  else
    shift
  fi
done
[[ -n "$target" ]] || { printf 'runtime fixture target missing\n' >&2; exit 2; }

while IFS= read -r file; do
  awk '
    { gsub(/\{\{PROJECT_MISSION\}\}/, "Configured mission")
      gsub(/\{\{DECISION_OWNER\}\}/, "Configured owner")
      gsub(/\{\{DATE\}\}/, "2026-09-17")
      gsub(/\{\{PRIMARY_LANGUAGE\}\}/, "TypeScript")
      gsub(/\{\{FRAMEWORK_OR_PLATFORM\}\}/, "Next.js")
      gsub(/\{\{PERSISTENCE_STRATEGY\}\}/, "PostgreSQL")
      gsub(/\{\{PROJECT_NAME\}\}/, "runtime-target")
      print }
  ' "$file" >"$file.tmp" && mv "$file.tmp" "$file"
done < <(find "$target" -type f -name '*.md')
EOF
chmod +x "$runtime_initializer"
export RUNTIME_ROOT
runtime_preview="$(cd / && bash "$INSPECTOR" --target "$runtime_target" --lang en --module web-starter --template-root "$RUNTIME_ROOT")"
runtime_fingerprint="$(printf '%s\n' "$runtime_preview" | awk -F= '$1 == "PREVIEW_FINGERPRINT" { print $2; exit }')"
[[ "$runtime_fingerprint" =~ ^[0-9a-fA-F]{64}$ ]] || fail 'installed runtime inspection did not emit a preview fingerprint'
runtime_output="$(cd / && bash "$DECISION_HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$runtime_target" \
  --lang en \
  --module web-starter \
  --initializer "$runtime_initializer" \
  --validator "$RUNTIME_ROOT/scripts/validate-harness.sh" \
  --preview-fingerprint "$runtime_fingerprint" \
  --gitignore-decision NO)" \
  || fail 'installed runtime handoff should execute canonical initializer and validator'
assert_contains "$runtime_output" 'State: BOOTSTRAP_APPROVED'
[[ -f "$runtime_target/AGENTS.md" ]] || fail 'installed runtime initializer did not create AGENTS.md'
[[ -f "$runtime_target/docs/00-overview/architecture.md" ]] || fail 'installed runtime initializer did not create canonical docs'
assert_contains "$runtime_output" 'Target: '
if [[ ! -f "$runtime_target/docs/00-overview/architecture.md" ]]; then
  fail 'installed runtime validator did not run against the generated target'
fi

: >"$SPY_LOG"
set +e
incomplete_conflicts_output="$(bash "$DECISION_HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$failure_target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer_spy" \
  --validator "$validator_spy" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-path '.forsetum-backups/forsetum-harness-preview/AGENTS.md' \
  --rollback-command 'restore --from .forsetum-backups/forsetum-harness-preview/AGENTS.md --to AGENTS.md' \
  --gitignore-decision NO 2>&1)"
incomplete_conflicts_status=$?
set -e
assert_status 2 "$incomplete_conflicts_status" 'incomplete per-path conflict approval'
assert_contains "$incomplete_conflicts_output" 'conflict decision set must exactly match target conflicts'
[[ ! -s "$SPY_LOG" ]] || fail 'incomplete conflict approval invoked initializer or validator'
[[ ! -e "$failure_target/.forsetum-backups" ]] || fail 'incomplete conflict approval created a backup root'

: >"$SPY_LOG"
set +e
invalid_mapping_output="$(bash "$DECISION_HANDOFF" \
  --decision APPROVE_REPLACE_WITH_BACKUP \
  --target "$failure_target" \
  --lang id \
  --module app-maintenance \
  --initializer "$initializer_spy" \
  --validator "$validator_spy" \
  --conflict 'AGENTS.md=APPROVE_REPLACE_WITH_BACKUP' \
  --conflict 'docs/=APPROVE_REPLACE_WITH_BACKUP' \
  --backup-path '../outside/AGENTS.md' \
  --backup-mapping 'docs/=../outside/docs' \
  --rollback-command 'restore --from ../outside/AGENTS.md --to AGENTS.md' \
  --gitignore-decision NO 2>&1)"
invalid_mapping_status=$?
set -e
assert_status 2 "$invalid_mapping_status" 'unapproved backup mapping'
assert_contains "$invalid_mapping_output" 'backup mapping must remain within target'
[[ ! -s "$SPY_LOG" ]] || fail 'invalid backup mapping invoked initializer or validator'

failure_before_inventory="$(inventory_tree "$failure_target")"
failure_before_hashes="$(hash_tree "$failure_target")"

: >"$SPY_LOG"
cancel_output="$(bash "$DECISION_HANDOFF" \
  --decision CANCEL \
  --target "$failure_target" \
  --lang en \
  --module web-starter \
  --initializer "$initializer_spy" \
  --validator "$validator_spy")" \
  || fail 'cancel handoff should return successfully'
assert_contains "$cancel_output" 'State: CANCELLED'
assert_contains "$cancel_output" 'Mutation: none'
assert_contains "$cancel_output" 'Target: unchanged'
[[ ! -s "$SPY_LOG" ]] || fail 'cancellation invoked initializer or validator'
[[ "$(inventory_tree "$failure_target")" == "$failure_before_inventory" ]] || fail 'cancellation changed target inventory'
[[ "$(hash_tree "$failure_target")" == "$failure_before_hashes" ]] || fail 'cancellation changed target hashes'

deferred_output="$(bash "$DECISION_HANDOFF" \
  --decision DEFER \
  --target "$failure_target" \
  --lang en \
  --module web-starter \
  --initializer "$initializer_spy" \
  --validator "$validator_spy")" \
  || fail 'defer handoff should return successfully'
assert_contains "$deferred_output" 'State: DEFERRED'
assert_contains "$deferred_output" 'Mutation: none'
assert_contains "$deferred_output" 'Target: unchanged'
[[ ! -s "$SPY_LOG" ]] || fail 'deferral invoked initializer or validator'
[[ "$(inventory_tree "$failure_target")" == "$failure_before_inventory" ]] || fail 'deferral changed target inventory'
[[ "$(hash_tree "$failure_target")" == "$failure_before_hashes" ]] || fail 'deferral changed target hashes'

: >"$SPY_LOG"
preserve_output="$(bash "$DECISION_HANDOFF" \
  --decision PRESERVE \
  --target "$failure_target" \
  --lang en \
  --module web-starter \
  --initializer "$initializer_spy" \
  --validator "$validator_spy")" \
  || fail 'preserve handoff should return successfully'
assert_contains "$preserve_output" 'State: DEFERRED'
assert_contains "$preserve_output" 'Mutation: none'
assert_contains "$preserve_output" 'Target: unchanged'
[[ ! -s "$SPY_LOG" ]] || fail 'preserve invoked initializer or validator'
[[ "$(inventory_tree "$failure_target")" == "$failure_before_inventory" ]] || fail 'preserve changed target inventory'
[[ "$(hash_tree "$failure_target")" == "$failure_before_hashes" ]] || fail 'preserve changed target hashes'

: >"$SPY_LOG"
skip_output="$(bash "$DECISION_HANDOFF" \
  --decision SKIP \
  --target "$failure_target" \
  --lang en \
  --module web-starter \
  --initializer "$initializer_spy" \
  --validator "$validator_spy")" \
  || fail 'skip handoff should return successfully'
assert_contains "$skip_output" 'State: DEFERRED'
assert_contains "$skip_output" 'Mutation: none'
assert_contains "$skip_output" 'Target: unchanged'
[[ ! -s "$SPY_LOG" ]] || fail 'skip invoked initializer or validator'
[[ "$(inventory_tree "$failure_target")" == "$failure_before_inventory" ]] || fail 'skip changed target inventory'
[[ "$(hash_tree "$failure_target")" == "$failure_before_hashes" ]] || fail 'skip changed target hashes'

set +e
bash "$INSPECTOR" --target "$empty_target" --lang en --module invented --template-root "$RUNTIME_ROOT" >"$TMP_DIR/invalid.out" 2>&1
invalid_status=$?
set -e
assert_status 2 "$invalid_status" 'invalid module inspection'

if grep -nE '(^|[[:space:]])(rm|cp|mv|mkdir|touch|sed[[:space:]]+-i|init\.(sh|ps1)|validate-(template|harness)\.(sh|ps1))([[:space:]]|$)' "$INSPECTOR" >/dev/null; then
  fail 'installed inspector contains a write, initializer, or validator command'
fi
gate_line=$(grep -nF '## Hard Safety Gate' "$INSTALLED_SKILL/SKILL.md" | cut -d: -f1)
approval_line=$(grep -nF 'After the user explicitly approves' "$INSTALLED_SKILL/SKILL.md" | cut -d: -f1)
operation_line=$(grep -nF 'Operation: <PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP>' "$INSTALLED_SKILL/SKILL.md" | head -n1 | cut -d: -f1 || true)
handoff_line=$(grep -nF '<skill-dir>/scripts/decision-handoff.sh --decision' "$INSTALLED_SKILL/SKILL.md" | head -n1 | cut -d: -f1 || true)
[[ -n "$gate_line" && -n "$approval_line" && "$gate_line" -lt "$approval_line" ]] \
  || fail 'skill does not place the hard safety gate before mutation handoff'
[[ -n "$operation_line" && "$operation_line" -lt "$approval_line" ]] \
  || fail 'installed skill does not present a per-path operation before mutation handoff'
[[ -n "$handoff_line" && "$handoff_line" -lt "$approval_line" ]] \
  || fail 'installed skill does not route adoption decisions through package-local handoff'
grep -Fq 'Replacement metadata: backup_path, rollback_command, gitignore_decision' "$INSTALLED_SKILL/SKILL.md" \
  || fail 'installed skill does not require replacement recovery metadata'
grep -Fq 'PRESERVE/SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged' "$INSTALLED_SKILL/SKILL.md" \
  || fail 'installed skill does not defer preserve or skip without mutation'
grep -Fq 'Next action: manual handling | CHANGE_TARGET' "$INSTALLED_SKILL/SKILL.md" \
  || fail 'installed skill does not route preserve or skip away from bootstrap'
if grep -Fq 'Normalized operations:' "$INSTALLED_SKILL/SKILL.md"; then
  fail 'installed skill presents a global operation list instead of per-path records'
fi
if grep -Fq 'APPROVE_OVERWRITE' "$INSTALLED_SKILL/SKILL.md"; then
  fail 'installed skill teaches legacy overwrite approval'
fi
if grep -Fq -- '--force' "$INSTALLED_SKILL/SKILL.md"; then
  fail 'installed skill offers a force flag'
fi
grep -Fq '`Mutation: none`' "$INSTALLED_SKILL/SKILL.md" \
  || fail 'skill does not document no mutation for cancellation or deferral'
grep -Fq '`Target: unchanged`' "$INSTALLED_SKILL/SKILL.md" \
  || fail 'skill does not document unchanged target for cancellation or deferral'

printf 'PASS: installed package fixtures\n'
