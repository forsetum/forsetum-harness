#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: init.sh [OPTIONS]

Scaffold an AI Agent Harness for a new or existing project.

Options:
  -l, --lang <id|en>        Template language ('id' for Indonesian, 'en' for English). Default: en
  -m, --module <module_id>  Domain module declared by template/<lang>/manifest.json. Default: web-fullstack
  -t, --target <dir>        Target project directory. Default: .
  -n, --name <name>         Project name (interpolates {{PROJECT_NAME}}).
  -f, --force               Overwrite existing files in target directory.
  -h, --help                Show this help message.

Examples:
  ./scripts/init.sh
  ./scripts/init.sh --lang en --module landing-page --target ~/projects/my-lp --name "My Cool Landing Page"
  ./scripts/init.sh --lang id --target ./backend --name "Layanan Pembayaran"
USAGE
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

LANG_VAL="en"
MODULE_ID="web-fullstack"
TARGET_DIR="."
PROJECT_NAME=""
FORCE=0
INTERACTIVE=0

if (( $# == 0 )) && [[ -t 0 ]]; then
  INTERACTIVE=1
fi

while (($# > 0)); do
  case "$1" in
    -l|--lang)
      (($# >= 2)) || { printf 'ERROR: --lang requires id or en\n' >&2; exit 2; }
      LANG_VAL="$2"
      shift 2
      ;;
    -m|--module)
      (($# >= 2)) || { printf 'ERROR: --module requires a module ID\n' >&2; exit 2; }
      MODULE_ID="$2"
      shift 2
      ;;
    -t|--target)
      (($# >= 2)) || { printf 'ERROR: --target requires a directory path\n' >&2; exit 2; }
      TARGET_DIR="$2"
      shift 2
      ;;
    -n|--name)
      (($# >= 2)) || { printf 'ERROR: --name requires a project name\n' >&2; exit 2; }
      PROJECT_NAME="$2"
      shift 2
      ;;
    -f|--force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'ERROR: Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if (( INTERACTIVE == 1 )); then
  printf '==================================================\n'
  printf '  AI Harness Scaffolding Wizard                   \n'
  printf '==================================================\n\n'

  printf 'Select template language:\n'
  printf '  1) English (en) [default]\n'
  printf '  2) Bahasa Indonesia (id)\n'
  read -r -p 'Choose [1/2, default: 1]: ' lang_choice
  case "${lang_choice}" in
    2|id|ID) LANG_VAL="id" ;;
    *) LANG_VAL="en" ;;
  esac

  if [[ -d "${REPO_ROOT}/template/${LANG_VAL}/core" ]]; then
    mapfile -t CATALOG_MODULE_IDS < <(awk '
      /^  "modules": \{/ { in_modules=1; next }
      in_modules && /^  \},?$/ { exit }
      in_modules && /^    "[^"]+": \{/ {
        id=$0; sub(/^    "/, "", id); sub(/".*$/, "", id); print id
      }
    ' "${REPO_ROOT}/template/${LANG_VAL}/manifest.json")
    printf '\nSelect domain module:\n'
    for index in "${!CATALOG_MODULE_IDS[@]}"; do
      number=$((index + 1))
      suffix=""
      (( index == 0 )) && suffix=" [default]"
      printf ' %2d) %s%s\n' "${number}" "${CATALOG_MODULE_IDS[index]}" "${suffix}"
    done
    read -r -p "Choose [1-${#CATALOG_MODULE_IDS[@]}, default: 1]: " mod_choice
    if [[ "${mod_choice}" =~ ^[0-9]+$ ]] && (( mod_choice >= 1 && mod_choice <= ${#CATALOG_MODULE_IDS[@]} )); then
      MODULE_ID="${CATALOG_MODULE_IDS[mod_choice-1]}"
    elif printf '%s\n' "${CATALOG_MODULE_IDS[@]}" | grep -Fxq -- "${mod_choice}"; then
      MODULE_ID="${mod_choice}"
    else
      MODULE_ID="${CATALOG_MODULE_IDS[0]}"
    fi
  fi

  read -r -p 'Target directory [default: .]: ' target_choice
  if [[ -n "${target_choice}" ]]; then
    TARGET_DIR="${target_choice}"
  fi

  read -r -p 'Project name (optional, e.g. "My Project"): ' name_choice
  if [[ -n "${name_choice}" ]]; then
    PROJECT_NAME="${name_choice}"
  fi

  printf '\nConfiguration Summary:\n'
  printf '  Language:     %s\n' "${LANG_VAL}"
  printf '  Module:       %s\n' "${MODULE_ID}"
  printf '  Target Dir:   %s\n' "${TARGET_DIR}"
  printf '  Project Name: %s\n' "${PROJECT_NAME:-<not set>}"
  read -r -p 'Proceed with scaffolding? [Y/n]: ' confirm
  case "${confirm}" in
    n*|N*)
      printf 'Operation aborted by user.\n'
      exit 0
      ;;
  esac
fi

case "${LANG_VAL}" in
  id|en) ;;
  *)
    printf 'ERROR: Invalid language: %s (choose id or en)\n' "${LANG_VAL}" >&2
    exit 2
    ;;
esac

TEMPLATE_DIR="${REPO_ROOT}/template/${LANG_VAL}"
if [[ ! -d "${TEMPLATE_DIR}" ]]; then
  printf 'ERROR: Template directory not found: %s\n' "${TEMPLATE_DIR}" >&2
  exit 1
fi

if ! awk -v wanted="${MODULE_ID}" '
  /^  "modules": \{/ { in_modules=1; next }
  in_modules && /^  \},?$/ { exit }
  in_modules && $0 ~ "^    \"" wanted "\": \\{" { found=1 }
  END { exit(found ? 0 : 1) }
' "${TEMPLATE_DIR}/manifest.json"; then
  printf 'ERROR: Module is not declared in %s/manifest.json: %s\n' "${LANG_VAL}" "${MODULE_ID}" >&2
  exit 2
fi

mkdir -p "${TARGET_DIR}"
ABS_TARGET="$(cd -- "${TARGET_DIR}" && pwd)"

# Check if target already has harness files
if (( FORCE == 0 )); then
  if [[ -f "${ABS_TARGET}/AGENTS.md" || -d "${ABS_TARGET}/docs" ]]; then
    printf 'ERROR: Target directory already contains AI Harness files (%s)\n' "${ABS_TARGET}" >&2
    printf 'Use --force to overwrite existing files.\n' >&2
    exit 1
  fi
fi

if [[ -d "${TEMPLATE_DIR}/core" ]]; then
  printf '==> Bundling modular AI Harness (%s / %s) into: %s\n' "${LANG_VAL}" "${MODULE_ID}" "${ABS_TARGET}"
  "${SCRIPT_DIR}/bundle.sh" --lang "${LANG_VAL}" --module "${MODULE_ID}" ${PROJECT_NAME:+--name "${PROJECT_NAME}"} --dir "${ABS_TARGET}"
else
  printf '==> Scaffolding legacy AI Harness (%s) into: %s\n' "${LANG_VAL}" "${ABS_TARGET}"
  cp -R "${TEMPLATE_DIR}/." "${ABS_TARGET}/"
  mkdir -p "${ABS_TARGET}/scripts"
  cp "${REPO_ROOT}/scripts/validate-harness.sh" "${ABS_TARGET}/scripts/validate-harness.sh"
  cp "${REPO_ROOT}/scripts/validate-harness.ps1" "${ABS_TARGET}/scripts/validate-harness.ps1"
  cp "${REPO_ROOT}/scripts/validate-template.sh" "${ABS_TARGET}/scripts/validate-template.sh"
  cp "${REPO_ROOT}/scripts/validate-template.ps1" "${ABS_TARGET}/scripts/validate-template.ps1"
  chmod +x "${ABS_TARGET}/scripts/validate-harness.sh" "${ABS_TARGET}/scripts/validate-template.sh"

  if [[ -n "${PROJECT_NAME}" ]]; then
    while IFS= read -r file; do
      if grep -q '{{PROJECT_NAME}}' "${file}" 2>/dev/null; then
        awk -v name="${PROJECT_NAME}" '{gsub(/\{\{PROJECT_NAME\}\}/, name)} 1' "${file}" > "${file}.tmp" && mv "${file}.tmp" "${file}"
      fi
    done < <(find "${ABS_TARGET}" -type f -name "*.md")
  fi
fi

printf '\n'
if [[ "${LANG_VAL}" == "id" ]]; then
  cat <<SUCCESS_MSG
==================================================
  Inisialisasi AI Harness Berhasil!
==================================================
Direktori tujuan: ${ABS_TARGET}
Bahasa template:  Bahasa Indonesia (id)
Modul domain:     ${MODULE_ID}

Langkah Selanjutnya (Next Steps):
  1. Buka dan pelajari AGENTS.md dan README.md di direktori proyek.
  2. Jalankan validasi struktur template:
     ./scripts/validate-harness.sh
  3. Mulai fase Instantiation and Discovery bersama Agen AI:
     - Lengkapi docs/08-reference/template-variables.md
     - Catat keputusan arsitektur di docs/08-reference/decision-register.md
     - Jalankan ./scripts/validate-harness.sh secara berkala untuk memantau kesiapan.
==================================================
SUCCESS_MSG
else
  cat <<SUCCESS_MSG
==================================================
  AI Harness Initialization Succeeded!
==================================================
Target directory:  ${ABS_TARGET}
Template language: English (en)
Domain module:     ${MODULE_ID}

Next Steps:
  1. Review AGENTS.md and README.md in your project directory.
  2. Run the template harness validation:
     ./scripts/validate-harness.sh
  3. Begin the Instantiation and Discovery phase with your AI agent:
     - Define project requirements and fill out docs/08-reference/template-variables.md
     - Record architectural decisions in docs/08-reference/decision-register.md
     - Run ./scripts/validate-harness.sh regularly to track implementation readiness.
==================================================
SUCCESS_MSG
fi
