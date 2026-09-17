#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: inspect-repository.sh --target <dir> [OPTIONS]

Inspect a target repository and print an adoption preview without writing files.

Options:
  --target <dir>          Existing target repository directory (required).
  --lang <id|en>          Template language. Default: en.
  --module <module_id>    Canonical module/profile ID. Default: web-fullstack.
  --template-root <dir>   Repository containing template/<lang>/manifest.json.
                          Default: repository root inferred from this script.
  -h, --help              Show this help message.
USAGE
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_RUNTIME_ROOT="$(cd -- "${SCRIPT_DIR}/../runtime" 2>/dev/null && pwd -P || true)"
DEFAULT_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
TARGET_DIR=""
LANG_VAL="en"
MODULE_ID="web-fullstack"
TEMPLATE_ROOT="${PACKAGE_RUNTIME_ROOT:-${DEFAULT_ROOT}}"

while (($# > 0)); do
  case "$1" in
    --target)
      (($# >= 2)) || { printf 'ERROR: --target requires a directory path\n' >&2; exit 2; }
      TARGET_DIR="$2"
      shift 2
      ;;
    --lang)
      (($# >= 2)) || { printf 'ERROR: --lang requires id or en\n' >&2; exit 2; }
      LANG_VAL="$2"
      shift 2
      ;;
    --module)
      (($# >= 2)) || { printf 'ERROR: --module requires a module ID\n' >&2; exit 2; }
      MODULE_ID="$2"
      shift 2
      ;;
    --template-root)
      (($# >= 2)) || { printf 'ERROR: --template-root requires a directory path\n' >&2; exit 2; }
      TEMPLATE_ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'ERROR: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -n "${TARGET_DIR}" ]] || { printf 'ERROR: --target is required\n' >&2; exit 2; }
[[ -d "${TARGET_DIR}" ]] || { printf 'ERROR: target directory does not exist: %s\n' "${TARGET_DIR}" >&2; exit 2; }
[[ "${LANG_VAL}" == "id" || "${LANG_VAL}" == "en" ]] || { printf 'ERROR: invalid language: %s\n' "${LANG_VAL}" >&2; exit 2; }
[[ "${MODULE_ID}" =~ ^[a-z0-9-]+$ ]] || { printf 'ERROR: invalid module ID: %s\n' "${MODULE_ID}" >&2; exit 2; }
[[ -d "${TEMPLATE_ROOT}" ]] || { printf 'ERROR: template root does not exist: %s\n' "${TEMPLATE_ROOT}" >&2; exit 2; }
TEMPLATE_ROOT="$(cd -- "${TEMPLATE_ROOT}" && pwd -P)"

MANIFEST="${TEMPLATE_ROOT}/template/${LANG_VAL}/manifest.json"
[[ -r "${MANIFEST}" ]] || { printf 'ERROR: manifest is not readable: %s\n' "${MANIFEST}" >&2; exit 2; }

declare -A parity_keys
for manifest_language in id en; do
  parity_manifest="${TEMPLATE_ROOT}/template/${manifest_language}/manifest.json"
  [[ -r "${parity_manifest}" ]] || { printf 'ERROR: manifest is not readable: %s\n' "${parity_manifest}" >&2; exit 2; }
  parity_keys["${manifest_language}"]="$(grep -E '^[[:space:]]{4}\"[a-z0-9-]+\"[[:space:]]*:[[:space:]]*\{' "${parity_manifest}" | sed -E 's/^[[:space:]]*\"([^\"]+)\".*/\1/' | sort | tr '\n' ' ')"
done
[[ "${parity_keys[id]}" == "${parity_keys[en]}" ]] || {
  printf 'ERROR: manifest module parity failure\n' >&2
  exit 2
}

if ! grep -Eq "^[[:space:]]+\"${MODULE_ID}\"[[:space:]]*:[[:space:]]*\\{" "${MANIFEST}"; then
  printf 'ERROR: module is not registered in %s: %s\n' "${MANIFEST}" "${MODULE_ID}" >&2
  exit 2
fi

printf 'TARGET=%s\n' "${TARGET_DIR}"
printf 'LANGUAGE=%s\n' "${LANG_VAL}"
printf 'MODULE=%s\n' "${MODULE_ID}"
printf 'MANIFEST=%s\n' "${MANIFEST}"
printf 'INITIALIZER=init.%s\n' "$([[ "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == cygwin* ]] && printf 'ps1' || printf 'sh')"
printf 'VALIDATOR=validate-template.%s\n' "$([[ "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == cygwin* ]] && printf 'ps1' || printf 'sh')"

conflict_count=0
report_conflict() {
  local relative_path="$1"
  if [[ -e "${TARGET_DIR}/${relative_path}" ]]; then
    printf 'CONFLICT=%s\n' "${relative_path}"
    conflict_count=$((conflict_count + 1))
  fi
}

for governance_path in AGENTS.md README.md backlog.md mission.md governance.md; do
  report_conflict "${governance_path}"
done
report_conflict 'docs/'

if (( conflict_count > 0 )); then
  printf 'CONFLICT_COUNT=%s\n' "${conflict_count}"
  printf 'CONFLICT_ACTION=STOP_AND_REQUEST_USER_DECISION\n'
  printf 'STATE=%s\n' 'CONFLICT_REVIEW'
  exit 3
fi

printf 'CONFLICTS=none\n'
printf 'CONFLICT_COUNT=0\n'
printf 'STATE=%s\n' 'PROCEED_PENDING_APPROVAL'
