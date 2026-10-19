#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="${SCRIPT_DIR}/run-conformance.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-conformance-test.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[[ -f "${RUNNER}" ]] || fail 'conformance runner is missing'

cat >"${TMP_DIR}/pass.sh" <<'EOF'
#!/usr/bin/env bash
printf 'PASS: synthetic adapter\n'
EOF
cat >"${TMP_DIR}/fail.sh" <<'EOF'
#!/usr/bin/env bash
printf 'FAIL: synthetic adapter\n' >&2
exit 7
EOF
chmod +x "${TMP_DIR}/pass.sh" "${TMP_DIR}/fail.sh"

pass_output="${TMP_DIR}/pass-output"
bash "${RUNNER}" "${TMP_DIR}/pass.sh" >"${pass_output}"
grep -Fq 'PASS: conformance gate' "${pass_output}" \
  || fail 'runner must report a passing conformance gate'

fail_output="${TMP_DIR}/fail-output"
if bash "${RUNNER}" "${TMP_DIR}/pass.sh" "${TMP_DIR}/fail.sh" >"${fail_output}" 2>&1; then
  fail 'runner must fail when an adapter test fails'
fi
grep -Fq 'FAIL: conformance gate' "${fail_output}" \
  || fail 'runner must report a failing conformance gate'

printf 'PASS: conformance runner regression fixtures\n'
