#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd -- "${SKILL_DIR}/../.." && pwd)"
MATRIX="${REPO_ROOT}/docs/agent-platform-compatibility.md"
CODEX_ADAPTER="${SKILL_DIR}/adapters/codex/README.md"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_adjacent_preview_fields() {
  local path_line operation_line
  path_line=$(grep -nF 'Path: <exact existing path>' "${CODEX_ADAPTER}" | head -n1 | cut -d: -f1 || true)
  operation_line=''
  if [[ -n "$path_line" ]]; then
    operation_line=$(sed -n "$((path_line + 1))p" "${CODEX_ADAPTER}")
  fi
  [[ "$operation_line" == 'Operation: PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP' ]] \
    || fail 'Codex adapter must place the operation directly after its exact path'
}

[[ -f "${MATRIX}" ]] || fail 'compatibility matrix is missing'
[[ -f "${CODEX_ADAPTER}" ]] || fail 'Codex adapter documentation is missing'

for state in INSPECTION PROCEED_PENDING_APPROVAL CONFLICT_REVIEW BOOTSTRAP_APPROVED VALIDATED CANCELLED DEFERRED BLOCKED; do
  grep -Fq "\`${state}\`" "${CODEX_ADAPTER}" || fail "Codex adapter omits state ${state}"
done

grep -Fq '| `Candidate` |' "${MATRIX}" || fail 'matrix must define Candidate status'
grep -Fq 'Codex' "${MATRIX}" || fail 'matrix must include Codex'
grep -Fq 'Claude Code' "${MATRIX}" || fail 'matrix must include Claude Code'
grep -Fq 'Skills API' "${CODEX_ADAPTER}" || fail 'Codex adapter must record official Skills API evidence'
grep -Fq 'inspect-repository.sh' "${CODEX_ADAPTER}" || fail 'Codex adapter must delegate inspection to canonical adapter'
grep -Fq 'init.sh' "${CODEX_ADAPTER}" || fail 'Codex adapter must delegate bootstrap to canonical initializer'
grep -Fq 'validate-harness.sh' "${CODEX_ADAPTER}" || fail 'Codex adapter must delegate validation to canonical validator'
grep -Fq 'decision-handoff.ps1' "${CODEX_ADAPTER}" || fail 'Codex adapter must document native PowerShell handoff'
grep -Fq 'inventory/hash' "${CODEX_ADAPTER}" || fail 'Codex adapter must document backup verification before delegation'
grep -Fq 'CONFLICT_REVIEW' "${CODEX_ADAPTER}" || fail 'Codex adapter must document conflict hard stop'
grep -Fq 'Mutation: none' "${CODEX_ADAPTER}" || fail 'Codex adapter must document cancellation safety'
grep -Fq 'Operation: PRESERVE | MERGE | REPLACE_WITH_BACKUP | SKIP' "${CODEX_ADAPTER}" \
  || fail 'Codex adapter must document normalized operations'
grep -Fq 'Backup path:' "${CODEX_ADAPTER}" || fail 'Codex adapter must document backup path metadata'
grep -Fq 'Rollback command:' "${CODEX_ADAPTER}" || fail 'Codex adapter must document rollback command metadata'
grep -Fq 'Gitignore decision:' "${CODEX_ADAPTER}" || fail 'Codex adapter must document explicit gitignore decision'
grep -Fq 'Path: <exact existing path>' "${CODEX_ADAPTER}" || fail 'Codex adapter must bind operations to exact paths'
require_adjacent_preview_fields
grep -Fq 'PRESERVE/SKIP outcome: State: DEFERRED, Mutation: none, Target: unchanged' "${CODEX_ADAPTER}" \
  || fail 'Codex adapter must defer preserve or skip without mutation'
grep -Fq 'Next action: manual handling | CHANGE_TARGET' "${CODEX_ADAPTER}" \
  || fail 'Codex adapter must route preserve or skip away from bootstrap'
if grep -Fq 'APPROVE_OVERWRITE' "${CODEX_ADAPTER}"; then
  fail 'Codex adapter must not teach legacy overwrite approval'
fi
if grep -Fq -- '--force' "${CODEX_ADAPTER}"; then
  fail 'Codex adapter must not offer a force flag'
fi

printf 'PASS: Codex conformance contract\n'
