#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if (( $# > 0 )); then
  tests=("$@")
else
  tests=(
    "${SCRIPT_DIR}/test-codex-conformance.sh"
    "${SCRIPT_DIR}/test-claude-code-conformance.sh"
  )
fi

failed=0

for test_path in "${tests[@]}"; do
  if [[ ! -f "${test_path}" ]]; then
    printf 'FAIL: missing conformance test: %s\n' "${test_path}" >&2
    failed=1
    continue
  fi

  printf '==> Running conformance test: %s\n' "${test_path}"
  if bash "${test_path}"; then
    printf 'PASS: %s\n' "${test_path}"
  else
    printf 'FAIL: %s\n' "${test_path}" >&2
    failed=1
  fi
done

if (( failed != 0 )); then
  printf 'FAIL: conformance gate\n' >&2
  exit 1
fi

printf 'PASS: conformance gate\n'
