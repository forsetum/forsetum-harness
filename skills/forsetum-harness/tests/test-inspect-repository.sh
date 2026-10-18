#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSPECT_SCRIPT="${SCRIPT_DIR}/../scripts/inspect-repository.sh"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/forsetum-inspect-test.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "${haystack}" == *"${needle}"* ]] || fail "expected output to contain: ${needle}"
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "${haystack}" != *"${needle}"* ]] || fail "expected output not to contain: ${needle}"
}

hash_tree() {
  local root="$1" file relative
  while IFS= read -r file; do
    [[ -n "${file}" ]] || continue
    relative="${file#"${root}/"}"
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "${file}" | awk -v path="${relative}" '{ print $1 "  " path }'
    else
      shasum -a 256 "${file}" | awk -v path="${relative}" '{ print $1 "  " path }'
    fi
  done < <(find "${root}" -type f -print | LC_ALL=C sort)
}

inventory_tree() {
  local root="$1" path relative type
  find "${root}" -mindepth 1 -print | while IFS= read -r path; do
    relative="${path#"${root}/"}"
    if [[ -d "${path}" ]]; then type=d; else type=f; fi
    printf '%s %s\n' "${relative}" "${type}"
  done | LC_ALL=C sort
}

decision_handoff() {
  local decision="$1" preview="$2" target="$3" result="$4"
  [[ -s "${preview}" ]] || fail 'decision handoff requires a completed preview'
  [[ -d "${target}" ]] || fail 'decision handoff target does not exist'
  case "${decision}" in
    cancel)
      printf 'State: CANCELLED\nMutation: none\nTarget: unchanged\n' >"${result}"
      ;;
    defer)
      printf 'State: DEFERRED\nMutation: none\nTarget: unchanged\n' >"${result}"
      ;;
    *)
      fail "unsupported decision handoff: ${decision}"
      ;;
  esac
}

empty_target="${TMP_DIR}/empty"
mkdir -p "${empty_target}"
empty_output="$(bash "${INSPECT_SCRIPT}" --target "${empty_target}" --lang en --module web-starter --template-root "${REPO_ROOT}")" \
  || fail 'empty target inspection should succeed'
assert_contains "${empty_output}" 'STATE=PROCEED_PENDING_APPROVAL'
assert_contains "${empty_output}" 'MODULE=web-starter'
assert_contains "${empty_output}" 'CONFLICTS=none'
assert_contains "${empty_output}" 'PREVIEW_FINGERPRINT='
assert_contains "${empty_output}" 'PREVIEW_PATH=AGENTS.md'
assert_contains "${empty_output}" 'OPERATION=CREATE'
assert_contains "${empty_output}" 'CREATE_PATH=AGENTS.md'

non_governance_target="${TMP_DIR}/non-governance"
mkdir -p "${non_governance_target}/src"
printf 'source\n' >"${non_governance_target}/src/app.txt"
non_governance_before_inventory="$(inventory_tree "${non_governance_target}")"
non_governance_before_hashes="$(hash_tree "${non_governance_target}")"
set +e
non_governance_output="$(bash "${INSPECT_SCRIPT}" --target "${non_governance_target}" --lang en --module web-starter --template-root "${REPO_ROOT}")"
non_governance_status=$?
set -e
[[ "${non_governance_status}" -eq 0 ]] || fail 'non-governance target inspection should return status 0'
assert_contains "${non_governance_output}" 'STATE=PROCEED_PENDING_APPROVAL'
assert_contains "${non_governance_output}" 'CREATE_PATH=AGENTS.md'
assert_not_contains "${non_governance_output}" 'CONFLICT=src/app.txt'
[[ "$(inventory_tree "${non_governance_target}")" == "${non_governance_before_inventory}" ]] \
  || fail 'non-governance inspection changed target inventory'
[[ "$(hash_tree "${non_governance_target}")" == "${non_governance_before_hashes}" ]] \
  || fail 'non-governance inspection changed target hashes'

conflict_target="${TMP_DIR}/conflict"
mkdir -p "${conflict_target}/docs"
touch "${conflict_target}/AGENTS.md"
before_inventory="$(inventory_tree "${conflict_target}")"
before_hashes="$(hash_tree "${conflict_target}")"
conflict_output="$(bash "${INSPECT_SCRIPT}" --target "${conflict_target}" --lang id --module app-maintenance --template-root "${REPO_ROOT}")" \
  || [[ "$?" -eq 3 ]] || fail 'conflict target should return conflict status 3'
assert_contains "${conflict_output}" 'STATE=CONFLICT_REVIEW'
assert_contains "${conflict_output}" 'PREVIEW_FINGERPRINT='
assert_contains "${conflict_output}" 'CONFLICT=AGENTS.md'
assert_contains "${conflict_output}" 'CONFLICT=docs/'
assert_contains "${conflict_output}" 'PREVIEW_PATH=AGENTS.md'
assert_contains "${conflict_output}" 'OPERATION=REVIEW_REQUIRED'
assert_contains "${conflict_output}" 'PATH=AGENTS.md'
assert_contains "${conflict_output}" 'IMPACT=existing content remains untouched unless explicitly approved'
assert_contains "${conflict_output}" 'BACKUP_BEHAVIOR=preview only; backup required before replacement'
assert_contains "${conflict_output}" 'BACKUP_PATH=.forsetum-backups/forsetum-harness-preview/AGENTS.md'
assert_contains "${conflict_output}" 'APPROVAL_DECISION=REQUIRED_FOR_THIS_PATH'
assert_contains "${conflict_output}" 'NEXT_STATE=CONFLICT_REVIEW'
assert_contains "${conflict_output}" 'AVAILABLE_OPERATIONS=PRESERVE|MERGE|REPLACE_WITH_BACKUP|SKIP'
assert_contains "${conflict_output}" 'PREVIEW_BACKUP_ROOT=.forsetum-backups/forsetum-harness-preview'
assert_contains "${conflict_output}" 'BACKUP_MAPPING=AGENTS.md -> .forsetum-backups/forsetum-harness-preview/AGENTS.md'
assert_contains "${conflict_output}" 'ROLLBACK_COMMAND=restore --from .forsetum-backups/forsetum-harness-preview/AGENTS.md --to AGENTS.md'
assert_contains "${conflict_output}" 'GITIGNORE_DECISION=REQUIRED_YES_OR_NO'
after_inventory="$(inventory_tree "${conflict_target}")"
[[ "${before_inventory}" == "${after_inventory}" ]] || fail 'conflict inspection must not mutate the target'
[[ "$(hash_tree "${conflict_target}")" == "${before_hashes}" ]] || fail 'conflict inspection changed target hashes'
[[ ! -e "${conflict_target}/.forsetum-backups" ]] || fail 'conflict inspection must not create a backup root'

dangling_symlink_target="${TMP_DIR}/dangling-symlink"
mkdir -p "${dangling_symlink_target}"
ln -s missing-readme-target "${dangling_symlink_target}/README.md"
dangling_symlink_output="$(bash "${INSPECT_SCRIPT}" --target "${dangling_symlink_target}" --lang en --module web-starter --template-root "${REPO_ROOT}")" \
  || [[ "$?" -eq 3 ]] || fail 'dangling governance symlink should return conflict status 3'
assert_contains "${dangling_symlink_output}" 'STATE=CONFLICT_REVIEW'
assert_contains "${dangling_symlink_output}" 'CONFLICT=README.md'
assert_contains "${dangling_symlink_output}" 'OPERATION=REVIEW_REQUIRED'
[[ -L "${dangling_symlink_target}/README.md" ]] || fail 'dangling governance symlink was changed'
[[ ! -e "${dangling_symlink_target}/.forsetum-backups" ]] || fail 'dangling symlink inspection created a backup root'

cancel_result="${TMP_DIR}/cancel.result"
conflict_preview="${TMP_DIR}/conflict.preview"
printf '%s\n' "${conflict_output}" >"${conflict_preview}"
decision_handoff cancel "${conflict_preview}" "${conflict_target}" "${cancel_result}"
assert_contains "$(<"${cancel_result}")" 'State: CANCELLED'
assert_contains "$(<"${cancel_result}")" 'Mutation: none'
assert_contains "$(<"${cancel_result}")" 'Target: unchanged'
[[ "$(inventory_tree "${conflict_target}")" == "${before_inventory}" ]] \
  || fail 'cancellation changed target inventory'
[[ "$(hash_tree "${conflict_target}")" == "${before_hashes}" ]] \
  || fail 'cancellation changed target hashes'

defer_result="${TMP_DIR}/defer.result"
decision_handoff defer "${conflict_preview}" "${conflict_target}" "${defer_result}"
assert_contains "$(<"${defer_result}")" 'State: DEFERRED'
assert_contains "$(<"${defer_result}")" 'Mutation: none'
assert_contains "$(<"${defer_result}")" 'Target: unchanged'
[[ "$(inventory_tree "${conflict_target}")" == "${before_inventory}" ]] \
  || fail 'deferral changed target inventory'
[[ "$(hash_tree "${conflict_target}")" == "${before_hashes}" ]] \
  || fail 'deferral changed target hashes'

set +e
bash "${INSPECT_SCRIPT}" --lang en --module web-starter --template-root "${REPO_ROOT}" >/dev/null 2>&1
invalid_input_status=$?
set -e
[[ "${invalid_input_status}" -eq 2 ]] || fail "missing target returned ${invalid_input_status}, expected 2"

set +e
bash "${INSPECT_SCRIPT}" --target "${empty_target}" --lang en --module invented --template-root "${REPO_ROOT}" >/dev/null 2>&1
invalid_module_status=$?
set -e
[[ "${invalid_module_status}" -eq 2 ]] || fail "unknown module returned ${invalid_module_status}, expected 2"

invalid_manifest_root="${TMP_DIR}/invalid-manifest"
mkdir -p "${invalid_manifest_root}"
set +e
bash "${INSPECT_SCRIPT}" --target "${empty_target}" --lang en --module web-starter --template-root "${invalid_manifest_root}" >/dev/null 2>&1
invalid_manifest_status=$?
set -e
[[ "${invalid_manifest_status}" -eq 2 ]] || fail "missing manifest returned ${invalid_manifest_status}, expected 2"

printf 'PASS: inspect repository fixtures\n'
