#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: validate-template.sh [OPTIONS]

Options:
  --all                 Validate template/id, template/en, parity, and root repo (default).
  --template <id|en>    Validate a specific template directory (template/id or template/en).
  --root                Validate root repository documentation and links.
  --target <path>       Validate a target repository (instantiated project or custom template).
  --mode <source|instantiated>
                        Validation mode when --target is specified (default: source).
  -h, --help            Show this help message.

Examples:
  ./scripts/validate-template.sh --all
  ./scripts/validate-template.sh --template id
  ./scripts/validate-template.sh --template en
  ./scripts/validate-template.sh --target /path/to/my-project --mode instantiated
USAGE
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

TARGET_ACTION="all"
SPECIFIC_TEMPLATE=""
TARGET_DIR=""
MODE="source"

while (($# > 0)); do
  case "$1" in
    --all)
      TARGET_ACTION="all"
      shift
      ;;
    --template)
      (($# >= 2)) || { printf 'ERROR: --template requires id or en\n' >&2; exit 2; }
      TARGET_ACTION="template"
      SPECIFIC_TEMPLATE="$2"
      shift 2
      ;;
    --root)
      TARGET_ACTION="root"
      shift
      ;;
    --target)
      (($# >= 2)) || { printf 'ERROR: --target requires a directory path\n' >&2; exit 2; }
      TARGET_ACTION="target"
      TARGET_DIR="$2"
      shift 2
      ;;
    --mode)
      (($# >= 2)) || { printf 'ERROR: --mode requires source or instantiated\n' >&2; exit 2; }
      MODE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'ERROR: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

REQUIRED_TEMPLATE_FILES=(
  "AGENTS.md"
  "README.md"
  "backlog.md"
  "docs/INDEX.md"
  "docs/00-overview/prd.md"
  "docs/00-overview/business-flow.md"
  "docs/00-overview/architecture.md"
  "docs/01-server/provisioning-specs.md"
  "docs/02-application/application-guide.md"
  "docs/02-application/backend-api-guide.md"
  "docs/03-security/security-model.md"
  "docs/04-operations/deployment-checklist.md"
  "docs/05-monitoring/monitoring-guide.md"
  "docs/06-troubleshooting/troubleshooting-guide.md"
  "docs/07-disaster-recovery/disaster-recovery.md"
  "docs/08-reference/configuration-reference.md"
  "docs/08-reference/decision-register.md"
  "docs/08-reference/glossary.md"
  "docs/08-reference/template-variables.md"
  "docs/09-governance/acceptance-criteria.md"
  "docs/09-governance/docs-maintenance-guide.md"
  "docs/09-governance/implementation-readiness.md"
  "docs/09-governance/template-quality-checklist.md"
  "docs/09-governance/testing-strategy.md"
)

CORE_PROJECT_FILES=(
  "AGENTS.md"
  "README.md"
  "QUICKSTART.md"
  "backlog.md"
  "docs/INDEX.md"
  "docs/08-reference/decision-register.md"
  "docs/08-reference/template-variables.md"
  "docs/09-governance/implementation-readiness.md"
)

# 1. Validate file presence
validate_files() {
  local dir="$1"
  local missing=0
  printf '==> Checking required files in: %s\n' "${dir}"

  # If this is a monolithic template (e.g. template/id), check 24 files
  if [[ -f "${dir}/docs/00-overview/prd.md" ]]; then
    for rel in "${REQUIRED_TEMPLATE_FILES[@]}"; do
      local f="${dir}/${rel}"
      if [[ ! -s "${f}" ]]; then
        printf '  [FAIL] Missing or empty: %s\n' "${rel}" >&2
        missing=$((missing + 1))
      fi
    done
    if (( missing > 0 )); then
      printf 'ERROR: %d required file(s) missing in %s\n' "${missing}" "${dir}" >&2
      return 1
    fi
    printf '  [PASS] All %d required template files present and non-empty.\n' "${#REQUIRED_TEMPLATE_FILES[@]}"
    return 0
  fi

  # Otherwise check core project files
  for rel in "${CORE_PROJECT_FILES[@]}"; do
    local f="${dir}/${rel}"
    if [[ ! -s "${f}" ]]; then
      printf '  [FAIL] Missing or empty: %s\n' "${rel}" >&2
      missing=$((missing + 1))
    fi
  done
  if (( missing > 0 )); then
    printf 'ERROR: %d required core file(s) missing in %s\n' "${missing}" "${dir}" >&2
    return 1
  fi
  printf '  [PASS] All required core files present and non-empty.\n'
  return 0
}

# Normalize an absolute lexical path without requiring GNU realpath.
normalize_path() {
  local path="$1" component normalized='/'
  local -a components=()
  while IFS= read -r component; do
    case "$component" in
      ''|.) ;;
      ..)
        ((${#components[@]} > 0)) && unset 'components[${#components[@]}-1]'
        ;;
      *) components+=("$component") ;;
    esac
  done < <(printf '%s\n' "$path" | tr '/' '\n')
  for component in "${components[@]}"; do
    normalized+="$component/"
  done
  [[ "$normalized" == / ]] || normalized=${normalized%/}
  printf '%s\n' "$normalized"
}

# 2. Validate internal relative markdown links
validate_links() {
  local dir="$1"
  printf '==> Validating markdown links in: %s\n' "${dir}"
  local bad_links=0

  while IFS= read -r md_file; do
    [[ -z "${md_file}" ]] && continue
    local md_dir
    md_dir="$(dirname "${md_file}")"

    while IFS= read -r target; do
      case "${target}" in
        ''|http://*|https://*|mailto:*|file://*|\#*) continue ;;
      esac

      local target_file="${target%%#*}"
      [[ -z "${target_file}" ]] && continue

      local resolved="${md_dir}/${target_file}"
      if [[ ! -f "${resolved}" && ! -d "${resolved}" ]]; then
        local root_resolved="${REPO_ROOT}/${target_file}"
        local core_resolved core_norm
        core_resolved="$(echo "${resolved}" | sed -E 's#/modules/[^/]+/#/core/#')"
        core_norm="$(normalize_path "${core_resolved}")"
        if [[ ! -f "${root_resolved}" && ! -d "${root_resolved}" && ! -f "${core_norm}" && ! -d "${core_norm}" ]]; then
          printf '  [FAIL] Broken link in %s: "%s"\n' "${md_file#${REPO_ROOT}/}" "${target}" >&2
          bad_links=$((bad_links + 1))
        fi
      fi
    done < <(grep -oE '\]\([^)]+\)' "${md_file}" | sed -E 's/^\]\(([^)]+)\)/\1/' || true)
  done < <(find "${dir}" -type f -name "*.md")

  if (( bad_links > 0 )); then
    printf 'ERROR: Found %d broken markdown link(s) in %s\n' "${bad_links}" "${dir}" >&2
    return 1
  fi
  printf '  [PASS] All markdown links are valid.\n'
  return 0
}

# 3. Validate placeholder registration
validate_placeholders() {
  local dir="$1"
  local registry="${dir}/docs/08-reference/template-variables.md"
  local core_registry="${dir}/core/docs/08-reference/template-variables.md"
  local manifest_file="${dir}/manifest.json"

  printf '==> Validating placeholder registrations in: %s\n' "${dir}"

  local unreg=0
  local placeholders
  placeholders="$(grep -rhoE '\{\{[A-Z0-9_]+\}\}' "${dir}" | sed -E 's/\{\{([A-Z0-9_]+)\}\}/\1/' | sort -u || true)"

  while IFS= read -r var_name; do
    [[ -z "${var_name}" ]] && continue
    case "${var_name}" in
      YEAR|TIMESTAMP|HASH|RELEVANT_TOPIC|DATE) continue ;;
    esac

    # Check primary project registry if present
    if [[ -f "${registry}" ]] && grep -q -w "${var_name}" "${registry}" 2>/dev/null; then
      continue
    fi

    # Check core registry if validating modular template library
    if [[ -f "${core_registry}" ]] && grep -q -w "${var_name}" "${core_registry}" 2>/dev/null; then
      continue
    fi

    # Check local manifest.json
    if [[ -f "${manifest_file}" ]] && grep -q -w "${var_name}" "${manifest_file}" 2>/dev/null; then
      continue
    fi

    # Check any module registries in dir/modules/
    if grep -rq -w "${var_name}" "${dir}"/modules/*/docs/08-reference/template-variables.md 2>/dev/null; then
      continue
    fi

    printf '  [FAIL] Unregistered placeholder used: {{%s}}\n' "${var_name}" >&2
    unreg=$((unreg + 1))
  done <<< "${placeholders}"

  if (( unreg > 0 )); then
    printf 'ERROR: Found %d unregistered placeholder(s) in %s\n' "${unreg}" "${dir}" >&2
    return 1
  fi
  printf '  [PASS] All placeholders are registered in template-variables.md.\n'
  return 0
}

# 4. Validate modular template library
validate_modular_template() {
  local lang_dir="$1"
  local manifest_file="${lang_dir}/manifest.json"
  local core_dir="${lang_dir}/core"
  local modules_dir="${lang_dir}/modules"
  local err=0

  printf '==> Validating modular template library in: %s\n' "${lang_dir}"
  if [[ ! -s "${manifest_file}" ]]; then
    printf '  [FAIL] Missing or empty manifest.json in %s\n' "${lang_dir}" >&2
    return 1
  fi
  printf '  [PASS] manifest.json present and readable.\n'

  # Validate core files
  local CORE_FILES=(
    "AGENTS.md"
    "README.md"
    "backlog.md"
    "docs/INDEX.md"
    "docs/00-overview/mission.md"
    "docs/08-reference/decision-register.md"
    "docs/08-reference/template-variables.md"
    "docs/08-reference/glossary.md"
    "docs/09-governance/acceptance-criteria.md"
    "docs/09-governance/implementation-readiness.md"
    "docs/09-governance/docs-maintenance-guide.md"
  )

  for rel in "${CORE_FILES[@]}"; do
    if [[ ! -s "${core_dir}/${rel}" ]]; then
      printf '  [FAIL] Missing or empty core file: %s\n' "${rel}" >&2
      err=$((err + 1))
    fi
  done
  printf '  [PASS] All %d core documentation files present.\n' "${#CORE_FILES[@]}"

  # Validate declared modules
  for mod in "web-fullstack" "landing-page" "sales-outreach" "general-office" "mobile-app" "cli-automation" "content-marketing" "research-analysis" "web-starter" "it-infra-ops" "app-maintenance"; do
    if [[ ! -d "${modules_dir}/${mod}" ]]; then
      printf '  [FAIL] Missing module directory: %s\n' "${mod}" >&2
      err=$((err + 1))
    else
      local mod_count
      mod_count="$(find "${modules_dir}/${mod}" -type f -name "*.md" | wc -l)"
      if (( mod_count == 0 )); then
        printf '  [FAIL] Module has no documentation files: %s\n' "${mod}" >&2
        err=$((err + 1))
      fi
    fi
  done
  printf '  [PASS] All 11 domain modules present in modules/ directory.\n'

  validate_links "${core_dir}" || err=$((err + 1))
  for mod in "web-fullstack" "landing-page" "sales-outreach" "general-office" "mobile-app" "cli-automation" "content-marketing" "research-analysis" "web-starter" "it-infra-ops" "app-maintenance"; do
    if [[ -d "${modules_dir}/${mod}" ]]; then
      validate_links "${modules_dir}/${mod}" || err=$((err + 1))
    fi
  done

  validate_placeholders "${lang_dir}" || err=$((err + 1))

  if (( err > 0 )); then
    printf 'ERROR: Modular template validation failed with %d error(s)\n' "${err}" >&2
    return 1
  fi
  printf '  [PASS] Modular template (%s) is complete and valid.\n' "$(basename "${lang_dir}")"
  return 0
}

# 5. Validate root repo harness
validate_root() {
  printf '==> Validating root repository harness...\n'
  local root_err=0

  validate_links "${REPO_ROOT}/docs" || root_err=$((root_err + 1))

  for single in "${REPO_ROOT}/AGENTS.md" "${REPO_ROOT}/README.md" "${REPO_ROOT}/backlog.md"; do
    if [[ -f "${single}" ]]; then
      while IFS= read -r target; do
        case "${target}" in
          ''|http://*|https://*|mailto:*|file://*|\#*) continue ;;
        esac
        local target_file="${target%%#*}"
        [[ -z "${target_file}" ]] && continue
        local resolved="${REPO_ROOT}/${target_file}"
        if [[ ! -f "${resolved}" && ! -d "${resolved}" ]]; then
          printf '  [FAIL] Broken link in %s: "%s"\n' "$(basename "${single}")" "${target}" >&2
          root_err=$((root_err + 1))
        fi
      done < <(grep -oE '\]\([^)]+\)' "${single}" | sed -E 's/^\]\(([^)]+)\)/\1/' || true)
    fi
  done

  local readiness_file="${REPO_ROOT}/docs/09-governance/implementation-readiness.md"
  if [[ -f "${readiness_file}" ]]; then
    if ! grep -q "READY_FOR_IMPLEMENTATION" "${readiness_file}"; then
      printf '  [FAIL] Root implementation-readiness.md is not set to READY_FOR_IMPLEMENTATION\n' >&2
      root_err=$((root_err + 1))
    fi
  fi

  if (( root_err > 0 )); then
    printf 'ERROR: Root harness validation failed with %d error(s)\n' "${root_err}" >&2
    return 1
  fi
  printf '  [PASS] Root repository harness is valid and ready.\n'
  return 0
}

# 6. Validate instantiated consumer repository
validate_instantiated() {
  local target="$1"
  printf '==> Validating instantiated repository in: %s\n' "${target}"
  local err=0

  for rel in "${CORE_PROJECT_FILES[@]}"; do
    if [[ ! -s "${target}/${rel}" ]]; then
      printf '  [FAIL] Missing or empty in instantiated repo: %s\n' "${rel}" >&2
      err=$((err + 1))
    fi
  done

  local remaining
  remaining="$(grep -rnE '\{\{[A-Z0-9_]+\}\}' "${target}/AGENTS.md" "${target}/README.md" "${target}/docs" 2>/dev/null || true)"
  if [[ -n "${remaining}" ]]; then
    printf '  [FAIL] Unreplaced placeholder(s) found in instantiated project:\n%s\n' "${remaining}" >&2
    err=$((err + 1))
  fi

  validate_links "${target}" || err=$((err + 1))

  if (( err > 0 )); then
    printf 'ERROR: Instantiated project validation failed with %d error(s)\n' "${err}" >&2
    return 1
  fi
  printf '  [PASS] Instantiated project is clean, complete, and valid.\n'
  return 0
}

# Execution Router
case "${TARGET_ACTION}" in
  all)
    if [[ ! -d "${REPO_ROOT}/template" && -f "${REPO_ROOT}/AGENTS.md" ]]; then
      printf '==================================================\n'
      printf '  AI Harness Project Validation                   \n'
      printf '==================================================\n'
      validate_files "${REPO_ROOT}"
      validate_placeholders "${REPO_ROOT}"
      validate_links "${REPO_ROOT}"
      printf '==================================================\n'
      printf '  SUCCESS: Project harness checks passed!         \n'
      printf '==================================================\n'
    else
      printf '==================================================\n'
      printf '  AI Harness Template Suite Validation (All)\n'
      printf '==================================================\n'
      validate_modular_template "${REPO_ROOT}/template/id"
      printf '\n'
      validate_modular_template "${REPO_ROOT}/template/en"
      printf '\n'
      validate_root
      printf '==================================================\n'
      printf '  SUCCESS: All template and root checks passed!\n'
      printf '==================================================\n'
    fi
    ;;
  template)
    case "${SPECIFIC_TEMPLATE}" in
      en)
        validate_modular_template "${REPO_ROOT}/template/en"
        printf 'SUCCESS: Template en is valid!\n'
        ;;
      id)
        validate_modular_template "${REPO_ROOT}/template/id"
        printf 'SUCCESS: Template id is valid!\n'
        ;;
      *)
        printf 'ERROR: Invalid template: %s (choose id or en)\n' "${SPECIFIC_TEMPLATE}" >&2
        exit 2
        ;;
    esac
    ;;
  root)
    validate_root
    printf 'SUCCESS: Root harness is valid!\n'
    ;;
  target)
    if [[ ! -d "${TARGET_DIR}" ]]; then
      printf 'ERROR: Target directory does not exist: %s\n' "${TARGET_DIR}" >&2
      exit 1
    fi
    if [[ "${MODE}" == "instantiated" ]]; then
      validate_instantiated "${TARGET_DIR}"
    else
      validate_files "${TARGET_DIR}"
      validate_placeholders "${TARGET_DIR}"
      validate_links "${TARGET_DIR}"
    fi
    printf 'SUCCESS: Target directory validated!\n'
    ;;
esac
