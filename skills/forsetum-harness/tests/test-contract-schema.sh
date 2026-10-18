#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACT="$SKILL_DIR/references/adoption-contract.md"
SCHEMA="$SKILL_DIR/references/contract-schema.md"
FIXTURES="$SKILL_DIR/references/conflict-fixtures.md"
ENTRYPOINT="$SKILL_DIR/SKILL.md"

failures=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

require_file() {
  local path=$1
  if [[ ! -f "$path" ]]; then
    fail "required reference file is missing: ${path#$SKILL_DIR/}"
  fi
}

require_literal() {
  local path=$1
  local value=$2
  if [[ ! -f "$path" ]] || ! grep -Fqx -- "$value" "$path"; then
    fail "expected exact line '$value' in ${path#$SKILL_DIR/}"
  fi
}

require_fragment() {
  local path=$1
  local value=$2
  if [[ ! -f "$path" ]] || ! grep -Fq -- "$value" "$path"; then
    fail "expected fragment '$value' in ${path#$SKILL_DIR/}"
  fi
}

forbid_fragment() {
  local path=$1
  local value=$2
  if [[ -f "$path" ]] && grep -Fq -- "$value" "$path"; then
    fail "forbidden legacy fragment '$value' found in ${path#$SKILL_DIR/}"
  fi
}

require_adjacent_literals() {
  local path=$1
  local first=$2
  local second=$3
  local first_line next_line
  first_line=$(grep -nF -- "$first" "$path" | head -n1 | cut -d: -f1 || true)
  next_line=''
  if [[ -n "$first_line" ]]; then
    next_line=$(sed -n "$((first_line + 1))p" "$path")
  fi
  if [[ "$next_line" != "$second" ]]; then
    fail "expected '$second' immediately after '$first' in ${path#$SKILL_DIR/}"
  fi
}

require_file "$CONTRACT"
require_file "$SCHEMA"
require_file "$FIXTURES"
require_file "$ENTRYPOINT"

if [[ -f "$SCHEMA" ]]; then
  for state in \
    INSPECTION \
    PROCEED_PENDING_APPROVAL \
    CONFLICT_REVIEW \
    BOOTSTRAP_APPROVED \
    VALIDATED \
    CANCELLED \
    DEFERRED \
    BLOCKED; do
    if ! grep -Fq -- "$state" "$SCHEMA"; then
      fail "schema does not document allowed state: $state"
    fi
  done

  # The schema must enumerate the state set exactly once as a JSON-like array.
  require_literal "$SCHEMA" 'allowed_states: [INSPECTION, PROCEED_PENDING_APPROVAL, CONFLICT_REVIEW, BOOTSTRAP_APPROVED, VALIDATED, CANCELLED, DEFERRED, BLOCKED]'

  # Synthetic conflict previews must retain exact paths, not vague labels.
  require_literal "$SCHEMA" 'conflict_paths: [AGENTS.md, docs/]'
  require_literal "$SCHEMA" 'conflict_path_mode: exact'

  # Cancellation is a safety invariant and must explicitly guarantee no write.
  require_literal "$SCHEMA" 'cancelled_result: {State: CANCELLED, Mutation: none, Target: unchanged}'
  require_literal "$SCHEMA" 'deferred_result: {State: DEFERRED, Mutation: none, Target: unchanged}'

  # Every brownfield conflict must use one normalized operation and retain a
  # complete per-path safety record through approval.
  require_literal "$SCHEMA" 'allowed_operations: [PRESERVE, MERGE, REPLACE_WITH_BACKUP, SKIP]'
  require_literal "$SCHEMA" 'conflict_preview_fields: [path, operation, impact, backup_behavior, approval_decision, next_state]'
  require_literal "$SCHEMA" 'replace_with_backup_requirements: [backup_path, rollback_command, gitignore_decision]'
  require_literal "$SCHEMA" 'gitignore_decision: explicit YES or NO when a backup directory is created'
  require_literal "$SCHEMA" 'handoff_arguments: [target, language, module, preview_fingerprint, initializer, validator]'
  require_literal "$SCHEMA" 'handoff_preview_fingerprint: required SHA-256 of the exact current inspector preview; changed previews invalidate approval'
  require_literal "$SCHEMA" 'handoff_conflict_set: exact current conflicts; missing or extra paths invalid'
  require_literal "$SCHEMA" 'handoff_backup_mapping: exact approved old path to backup path mapping'
  require_literal "$SCHEMA" 'handoff_backup_inventory: generated pre/post inventory and SHA-256 equality for every approved replacement path'
  require_literal "$SCHEMA" 'handoff_backup_order: verify inventory/hash and create backup before initializer'
  require_literal "$SCHEMA" 'handoff_shell_contract: Bash arrays on Unix; native PowerShell parameters on Windows; no bash -x'
  require_literal "$SCHEMA" 'preserve_skip_result: {State: DEFERRED, Mutation: none, Target: unchanged}'
  require_literal "$SCHEMA" 'preserve_skip_next_action: manual handling | CHANGE_TARGET'
  forbid_fragment "$SCHEMA" 'APPROVE_OVERWRITE'

  # The cancellation example is a complete conflict preview, so it cannot
  # retain the deprecated path/action-only shape.
  require_literal "$SCHEMA" '      "path": "AGENTS.md",'
  require_literal "$SCHEMA" '      "operation": "REPLACE_WITH_BACKUP",'
  require_literal "$SCHEMA" '      "backup_behavior": "backup pending before replacement",'
  require_literal "$SCHEMA" '      "approval_decision": "CANCEL",'
  require_literal "$SCHEMA" '      "next_state": "CANCELLED"'
fi

if [[ -f "$CONTRACT" ]]; then
  require_literal "$CONTRACT" 'Operation: PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP'
  require_literal "$CONTRACT" 'Backup path: <exact path | not_applicable>'
  require_literal "$CONTRACT" 'Rollback command: <exact command | not_applicable>'
  require_literal "$CONTRACT" 'Gitignore decision: YES | NO | not_applicable'
  require_literal "$CONTRACT" 'PRESERVE/SKIP result: {State: DEFERRED, Mutation: none, Target: unchanged}'
  require_literal "$CONTRACT" 'PRESERVE/SKIP next action: manual handling | CHANGE_TARGET'
fi

if [[ -f "$FIXTURES" ]]; then
  require_literal "$FIXTURES" 'Operation: PRESERVE'
  require_literal "$FIXTURES" 'Operation: MERGE'
  require_literal "$FIXTURES" 'Operation: REPLACE_WITH_BACKUP'
  require_literal "$FIXTURES" 'Operation: SKIP'
  require_literal "$FIXTURES" 'Gitignore decision: YES | NO'
  require_literal "$FIXTURES" '**Decision and outcome:** `APPROVE_PRESERVE` produces:'
  require_literal "$FIXTURES" 'Next state: DEFERRED after APPROVE_PRESERVE'
  require_literal "$FIXTURES" 'PRESERVE outcome: State: DEFERRED, Mutation: none, Target: unchanged'
  require_literal "$FIXTURES" 'Next state: DEFERRED after APPROVE_SKIP'
  require_literal "$FIXTURES" 'SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged'
fi

if [[ -f "$ENTRYPOINT" ]]; then
  require_literal "$ENTRYPOINT" 'Path: <exact existing path>'
  require_literal "$ENTRYPOINT" 'Operation: <PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP>'
  require_adjacent_literals "$ENTRYPOINT" 'Path: <exact existing path>' 'Operation: <PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP>'
  require_literal "$ENTRYPOINT" 'Replacement metadata: backup_path, rollback_command, gitignore_decision'
  require_literal "$ENTRYPOINT" 'Backup path: <exact path | not_applicable>'
  require_literal "$ENTRYPOINT" 'Rollback command: <exact command | not_applicable>'
  require_literal "$ENTRYPOINT" 'Gitignore decision: YES | NO | not_applicable'
  require_literal "$ENTRYPOINT" 'PRESERVE/SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged'
  require_literal "$ENTRYPOINT" 'Next action: manual handling | CHANGE_TARGET'
  require_fragment "$ENTRYPOINT" 'decision-handoff.ps1 -Decision <decision> -Target <dir> -Lang <id|en> -Module <module_id> -PreviewFingerprint <sha256>'
  forbid_fragment "$ENTRYPOINT" 'APPROVE_OVERWRITE'
  forbid_fragment "$ENTRYPOINT" 'Normalized operations:'
  forbid_fragment "$ENTRYPOINT" '--force'
  forbid_fragment "$ENTRYPOINT" '-Force'
fi

# A cancellation fixture is synthetic and must remain byte-for-byte unchanged.
fixture_dir=$(mktemp -d "${TMPDIR:-/tmp}/forsetum-contract-fixture.XXXXXX")
cleanup() {
  rm -rf "$fixture_dir"
}
trap cleanup EXIT

printf '%s\n' 'synthetic governance content' > "$fixture_dir/AGENTS.md"
mkdir "$fixture_dir/docs"
printf '%s\n' 'synthetic documentation' > "$fixture_dir/docs/README.md"
snapshot() { (cd "$fixture_dir"; find . -print | LC_ALL=C sort; find . -type f -exec cksum {} \; | LC_ALL=C sort); }
before="$(snapshot)"
result="$(bash "$SKILL_DIR/scripts/decision-handoff.sh" --decision CANCEL --target "$fixture_dir" --lang en --module web-starter --initializer "$SKILL_DIR/runtime/scripts/init.sh" --validator "$SKILL_DIR/runtime/scripts/validate-harness.sh")" || fail 'cancellation handoff failed'
[[ "$result" == *'State: CANCELLED'* && "$result" == *'Mutation: none'* && "$result" == *'Target: unchanged'* ]] || fail 'actual cancellation result violated contract'
[[ "$(snapshot)" == "$before" ]] || fail 'cancellation changed the target'

if (( failures > 0 )); then
  printf '%d contract schema test(s) failed\n' "$failures" >&2
  exit 1
fi

printf 'contract schema fixtures passed\n'
