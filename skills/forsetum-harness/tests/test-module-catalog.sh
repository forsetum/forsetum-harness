#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
VALIDATOR="${REPO_ROOT}/scripts/validate-harness.sh"
PS_VALIDATOR="${REPO_ROOT}/scripts/validate-harness.ps1"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-catalog-test.XXXXXX")"

cleanup() {
  rm -rf "${TMP_ROOT}"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[[ -x "${VALIDATOR}" ]] || fail 'canonical Bash validator is not executable'
[[ -f "${PS_VALIDATOR}" ]] || fail 'canonical PowerShell validator is missing'
grep -Fq 'All 11 domain modules present' "${VALIDATOR}" \
  && fail 'Bash validator still contains the legacy fixed 11-module report'
grep -Fq 'web-fullstack", "landing-page", "sales-outreach"' "${VALIDATOR}" \
  && fail 'Bash validator still contains the legacy fixed module list'
grep -Fq 'All 11 domain modules present' "${PS_VALIDATOR}" \
  && fail 'PowerShell validator still contains the legacy fixed 11-module report'
grep -Fq '"web-fullstack", "landing-page", "sales-outreach"' "${PS_VALIDATOR}" \
  && fail 'PowerShell validator still contains the legacy fixed module list'

make_fixture() {
  local fixture="$1"
  mkdir -p "${fixture}/scripts"
  cp -R "${REPO_ROOT}/template" "${fixture}/template"
  cp "${VALIDATOR}" "${fixture}/scripts/validate-harness.sh"
  chmod +x "${fixture}/scripts/validate-harness.sh"
}

replace_first() {
  local needle="$1"
  local replacement="$2"
  local file="$3"
  local temp_file="${file}.tmp.$$"
  awk -v needle="${needle}" -v replacement="${replacement}" '
    !done {
      position=index($0, needle)
      if (position > 0) {
        $0=substr($0, 1, position - 1) replacement substr($0, position + length(needle))
        done=1
      }
    }
    { print }
  ' "${file}" >"${temp_file}" && mv "${temp_file}" "${file}"
}

delete_matching_lines() {
  local pattern="$1"
  local file="$2"
  local temp_file="${file}.tmp.$$"
  awk -v pattern="${pattern}" '$0 !~ pattern { print }' "${file}" >"${temp_file}" \
    && mv "${temp_file}" "${file}"
}

assert_failure_contains() {
  local name="$1"
  local expected="$2"
  shift 2
  local fixture="${TMP_ROOT}/${name}"
  local output

  make_fixture "${fixture}"
  "$@" "${fixture}"
  if output="$(cd "${fixture}" && bash scripts/validate-harness.sh --template en 2>&1)"; then
    printf '%s\n' "${output}" >&2
    fail "${name}: validator unexpectedly passed"
  fi
  grep -Fq -- "${expected}" <<<"${output}" || {
    printf '%s\n' "${output}" >&2
    fail "${name}: expected failure containing '${expected}'"
  }
  printf 'PASS: %s\n' "${name}"
}

assert_success_with_fixture() {
  local name="$1"
  shift
  local fixture="${TMP_ROOT}/${name}"
  local output

  make_fixture "${fixture}"
  "$@" "${fixture}"
  if ! output="$(cd "${fixture}" && bash scripts/validate-harness.sh --template en 2>&1)"; then
    printf '%s\n' "${output}" >&2
    fail "${name}: validator unexpectedly failed"
  fi
  grep -Fq 'All 27 manifest-declared domain modules present in modules/ directory.' <<<"${output}" \
    || fail "${name}: validator did not report the 27-module catalog"
  printf 'PASS: %s\n' "${name}"
}

remove_module_directory() {
  local fixture="$1"
  rm -rf "${fixture}/template/en/modules/procurement-tender"
}

add_extra_module_directory() {
  local fixture="$1"
  mkdir -p "${fixture}/template/en/modules/undeclared-extra"
  printf '# Undeclared extra module\n' >"${fixture}/template/en/modules/undeclared-extra/README.md"
}

break_manifest_key_parity() {
  local fixture="$1"
  replace_first '"sme-business": {' '"sme-business-id-only": {' \
    "${fixture}/template/id/manifest.json"
}

remove_required_metadata_field() {
  local fixture="$1"
  delete_matching_lines '^      "category":' "${fixture}/template/en/manifest.json"
}

add_braces_inside_json_string() {
  local fixture="$1"
  replace_first 'Production-grade' '{Production-grade}' \
    "${fixture}/template/en/manifest.json"
}

assert_success_with_fixture \
  braces-inside-json-string \
  add_braces_inside_json_string

assert_failure_contains \
  missing-module-directory \
  'Manifest-to-directory parity failed for template/en' \
  remove_module_directory

assert_failure_contains \
  undeclared-extra-directory \
  'Manifest-to-directory parity failed for template/en' \
  add_extra_module_directory

assert_failure_contains \
  manifest-key-parity \
  'EN and ID manifest module keys differ' \
  break_manifest_key_parity

assert_failure_contains \
  missing-required-metadata \
  'Module web-fullstack is missing manifest field: category' \
  remove_required_metadata_field

baseline_output="$(bash "${VALIDATOR}" --template en 2>&1)" || {
  printf '%s\n' "${baseline_output}" >&2
  fail 'canonical English template validation failed'
}
grep -Fq 'All 27 manifest-declared domain modules present in modules/ directory.' <<<"${baseline_output}" \
  || fail 'validator did not report the manifest-derived 27-module catalog'

NEW_MODULE_IDS=(
  academic-education
  agribusiness-farming
  construction-civil
  content-creator
  culinary-fnb
  digital-advertising
  education-training
  event-project-mgmt
  health-medical
  hr-people-ops
  manufacturing-hse
  procurement-tender
  sme-business
  supply-chain-logistics
  ui-ux-design
)

ORIGINAL_MODULE_IDS=(
  web-fullstack
  landing-page
  sales-outreach
  general-office
  mobile-app
  cli-automation
  content-marketing
  research-analysis
  web-starter
  it-infra-ops
  app-maintenance
  business-growth
)

grep -Fq '](docs/$relative)' "${REPO_ROOT}/scripts/bundle.ps1" \
  && fail 'PowerShell generic INDEX still emits docs/docs/... links'
grep -Fq ']($relative)' "${REPO_ROOT}/scripts/bundle.ps1" \
  || fail 'PowerShell generic INDEX relative-link regression guard missing'

assert_bundle_case() {
  local lang="$1"
  local module_id="$2"
  local bundle_dir="${TMP_ROOT}/bundle-${lang}-${module_id}"
  local bundle_output module_source_dir module_file module_rel

  bundle_output="$(bash "${REPO_ROOT}/scripts/bundle.sh" \
    --lang "${lang}" --module "${module_id}" --name "Task 3 ${module_id}" \
    --dir "${bundle_dir}" 2>&1)" || {
    printf '%s\n' "${bundle_output}" >&2
    fail "bundle rejected canonical module ${lang}/${module_id}"
  }

  module_source_dir="${REPO_ROOT}/template/${lang}/modules/${module_id}/docs"
  module_file="$(find "${module_source_dir}" -type f -name '*.md' | sort | head -n 1)"
  [[ -n "${module_file}" ]] || fail "module ${lang}/${module_id} has no Markdown source"
  module_rel="${module_file#${module_source_dir}/}"
  [[ -s "${bundle_dir}/docs/${module_rel}" ]] \
    || fail "bundle ${lang}/${module_id} omitted docs/${module_rel}"
  grep -Fq "(${module_rel})" "${bundle_dir}/docs/INDEX.md" \
    || fail "bundle ${lang}/${module_id} INDEX omitted ${module_rel}"
  grep -Fq '](docs/docs/' "${bundle_dir}/docs/INDEX.md" \
    && fail "bundle ${lang}/${module_id} emitted docs/docs link"
  grep -Fq 'Domain Guardrails' "${bundle_dir}/docs/09-governance/implementation-readiness.md" \
    || fail "bundle ${lang}/${module_id} omitted manifest guardrail section"
  grep -Fq '### Module Persona' "${bundle_dir}/docs/08-reference/template-variables.md" \
    || fail "bundle ${lang}/${module_id} omitted manifest persona section"
  grep -Fq '### Interview Phases' "${bundle_dir}/docs/08-reference/template-variables.md" \
    || fail "bundle ${lang}/${module_id} omitted manifest interview phases"
  printf 'PASS: bundle %s/%s\n' "${lang}" "${module_id}"
}

for lang in en id; do
  for module_id in "${ORIGINAL_MODULE_IDS[@]}" "${NEW_MODULE_IDS[@]}"; do
    assert_bundle_case "${lang}" "${module_id}"
  done
done

printf 'PASS: 54 bundle cases remain isolated and canonical catalog reports 27 modules\n'
