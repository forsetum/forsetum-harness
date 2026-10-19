#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
CANONICAL="${REPO_ROOT}/scripts/validate-harness.sh"
LEGACY="${REPO_ROOT}/scripts/validate-template.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[[ -x "${CANONICAL}" ]] || fail 'canonical validate-harness.sh is missing or not executable'
[[ -f "${REPO_ROOT}/scripts/validate-harness.ps1" ]] || fail 'canonical validate-harness.ps1 is missing'
[[ -x "${LEGACY}" ]] || fail 'legacy validate-template.sh wrapper is missing or not executable'
[[ -f "${REPO_ROOT}/scripts/validate-template.ps1" ]] || fail 'legacy validate-template.ps1 wrapper is missing'

canonical_help="$("$CANONICAL" --help)"
legacy_help="$("$LEGACY" --help 2>/dev/null)"
grep -Fq 'Usage: validate-harness.sh' <<<"${canonical_help}" || fail 'canonical help uses the old command name'
grep -Fq 'Usage: validate-harness.sh' <<<"${legacy_help}" || fail 'legacy wrapper did not delegate to canonical help'

canonical_output="$(cd "${REPO_ROOT}" && "${CANONICAL}" --template en)"
legacy_output="$(cd "${REPO_ROOT}" && "${LEGACY}" --template en 2>/dev/null)"
grep -Fq 'SUCCESS: Template en is valid!' <<<"${canonical_output}" || fail 'canonical template validation did not pass'
grep -Fq 'SUCCESS: Template en is valid!' <<<"${legacy_output}" || fail 'legacy template validation did not delegate successfully'

printf 'PASS: canonical and legacy validator entry points\n'
