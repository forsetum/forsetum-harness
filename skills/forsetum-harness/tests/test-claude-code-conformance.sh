#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd -- "${SKILL_DIR}/../.." && pwd)"
MATRIX="${REPO_ROOT}/docs/agent-platform-compatibility.md"
ADAPTER="${SKILL_DIR}/adapters/claude-code/README.md"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_adjacent_preview_fields() {
  local path_line operation_line
  path_line=$(grep -nF 'Path: <exact existing path>' "${ADAPTER}" | head -n1 | cut -d: -f1 || true)
  operation_line=''
  if [[ -n "$path_line" ]]; then
    operation_line=$(sed -n "$((path_line + 1))p" "${ADAPTER}")
  fi
  [[ "$operation_line" == '   Operation: PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP' ]] \
    || fail 'adapter must place the operation directly after its exact path'
}

[[ -f "${MATRIX}" ]] || fail 'compatibility matrix is missing'
[[ -f "${ADAPTER}" ]] || fail 'Claude Code adapter documentation is missing'

for state in INSPECTION PROCEED_PENDING_APPROVAL CONFLICT_REVIEW BOOTSTRAP_APPROVED VALIDATED CANCELLED DEFERRED BLOCKED; do
  grep -Fq "\`${state}\`" "${ADAPTER}" || fail "Claude Code adapter omits state ${state}"
done

grep -Fq 'code.claude.com/docs/en/skills' "${ADAPTER}" || fail 'adapter must cite official skill format documentation'
grep -Fq '.claude/skills/forsetum-harness/SKILL.md' "${ADAPTER}" || fail 'adapter must document project skill installation path'
grep -Fq '/forsetum-harness' "${ADAPTER}" || fail 'adapter must document slash-command invocation'
grep -Fq 'inspect-repository.sh' "${ADAPTER}" || fail 'adapter must delegate to canonical inspector'
grep -Fq 'scripts/init.sh' "${ADAPTER}" || fail 'adapter must delegate bootstrap to canonical initializer'
grep -Fq 'validate-harness.sh' "${ADAPTER}" || fail 'adapter must delegate validation to canonical validator'
grep -Fq 'decision-handoff.ps1' "${ADAPTER}" || fail 'adapter must document native PowerShell handoff'
grep -Fq 'inventory/hash' "${ADAPTER}" || fail 'adapter must document backup verification before delegation'
grep -Fq 'Mutation: none' "${ADAPTER}" || fail 'adapter must document cancellation safety'
grep -Fq 'Claude Code' "${MATRIX}" || fail 'matrix must include Claude Code'
grep -Fq 'Operation: PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP' "${ADAPTER}" \
  || fail 'adapter must document normalized operations'
grep -Fq 'Backup path:' "${ADAPTER}" || fail 'adapter must document backup path metadata'
grep -Fq 'Rollback command:' "${ADAPTER}" || fail 'adapter must document rollback command metadata'
grep -Fq 'Gitignore decision:' "${ADAPTER}" || fail 'adapter must document explicit gitignore decision'
grep -Fq 'Path: <exact existing path>' "${ADAPTER}" || fail 'adapter must bind operations to exact paths'
require_adjacent_preview_fields
grep -Fq 'PRESERVE/SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged' "${ADAPTER}" \
  || fail 'adapter must defer preserve or skip without mutation'
grep -Fq 'Next action: manual handling | CHANGE_TARGET' "${ADAPTER}" \
  || fail 'adapter must route preserve or skip away from bootstrap'
if grep -Fq 'APPROVE_OVERWRITE' "${ADAPTER}"; then
  fail 'adapter must not teach legacy overwrite approval'
fi
if grep -Fq -- '--force' "${ADAPTER}"; then
  fail 'adapter must not offer a force flag'
fi

printf 'PASS: Claude Code conformance contract\n'
