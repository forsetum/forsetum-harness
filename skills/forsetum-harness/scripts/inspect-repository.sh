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
TARGET_DIR="$(cd -- "${TARGET_DIR}" && pwd -P)"
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
PREVIEW_BACKUP_ROOT='.forsetum-backups/forsetum-harness-preview'

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

path_snapshot() {
  local path="$1" file relative
  if [[ -f "$path" && ! -d "$path" ]]; then
    printf 'file %s\n' "$(hash_file "$path")"
    return
  fi
  printf 'directory\n'
  while IFS= read -r file; do
    relative="${file#"${path}/"}"
    printf '%s %s\n' "$relative" "$(hash_file "$file")"
  done < <(find "$path" -type f -print | LC_ALL=C sort)
}

preview_fingerprint() {
  local governance_path
  {
    printf 'target=%s\nlang=%s\nmodule=%s\n' "$TARGET_DIR" "$LANG_VAL" "$MODULE_ID"
    for governance_path in AGENTS.md README.md backlog.md mission.md governance.md docs/; do
      if [[ -e "${TARGET_DIR}/${governance_path}" ]]; then
        printf 'path=%s\n' "$governance_path"
        path_snapshot "${TARGET_DIR}/${governance_path%/}"
      else
        printf 'path=%s absent\n' "$governance_path"
      fi
    done
  } | if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

printf 'PREVIEW_FINGERPRINT=%s\n' "$(preview_fingerprint)"

report_governance_path() {
  local relative_path="$1"
  if [[ -e "${TARGET_DIR}/${relative_path}" ]]; then
    printf 'CONFLICT=%s\n' "${relative_path}"
    printf 'PREVIEW_PATH=%s\n' "${relative_path}"
    printf 'PATH=%s\n' "${relative_path}"
    printf 'OPERATION=REVIEW_REQUIRED\n'
    printf 'IMPACT=existing content remains untouched unless explicitly approved\n'
    printf 'BACKUP_BEHAVIOR=preview only; backup required before replacement\n'
    printf 'BACKUP_PATH=%s/%s\n' "${PREVIEW_BACKUP_ROOT}" "${relative_path}"
    printf 'AVAILABLE_OPERATIONS=PRESERVE|MERGE|REPLACE_WITH_BACKUP|SKIP\n'
    printf 'PREVIEW_BACKUP_ROOT=%s\n' "${PREVIEW_BACKUP_ROOT}"
    printf 'BACKUP_OLD_PATH=%s\n' "${relative_path}"
    printf 'BACKUP_NEW_PATH=%s/%s\n' "${PREVIEW_BACKUP_ROOT}" "${relative_path}"
    printf 'BACKUP_MAPPING=%s -> %s/%s\n' "${relative_path}" "${PREVIEW_BACKUP_ROOT}" "${relative_path}"
    printf 'ROLLBACK_COMMAND=restore --from %s/%s --to %s\n' "${PREVIEW_BACKUP_ROOT}" "${relative_path}" "${relative_path}"
    printf 'GITIGNORE_DECISION=REQUIRED_YES_OR_NO\n'
    printf 'APPROVAL_DECISION=REQUIRED_FOR_THIS_PATH\n'
    printf 'NEXT_STATE=CONFLICT_REVIEW\n'
    conflict_count=$((conflict_count + 1))
  else
    printf 'PREVIEW_PATH=%s\n' "${relative_path}"
    printf 'CREATE_PATH=%s\n' "${relative_path}"
    printf 'PATH=%s\n' "${relative_path}"
    printf 'OPERATION=CREATE\n'
  fi
}

for governance_path in AGENTS.md README.md backlog.md mission.md governance.md; do
  report_governance_path "${governance_path}"
done
report_governance_path 'docs/'

if (( conflict_count > 0 )); then
  printf 'CONFLICT_COUNT=%s\n' "${conflict_count}"
  printf 'CONFLICT_ACTION=STOP_AND_REQUEST_USER_DECISION\n'
  printf 'STATE=%s\n' 'CONFLICT_REVIEW'
  exit 3
fi

printf 'CONFLICTS=none\n'
printf 'CONFLICT_COUNT=0\n'
printf 'STATE=%s\n' 'PROCEED_PENDING_APPROVAL'
