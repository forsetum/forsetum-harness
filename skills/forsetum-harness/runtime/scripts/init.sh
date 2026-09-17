#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: init.sh [OPTIONS]

Scaffold an AI Agent Harness for a new or existing project.

Options:
  -l, --lang <id|en>        Template language ('id' for Indonesian, 'en' for English). Default: en
  -m, --module <module_id>  Domain module (web-fullstack, landing-page, sales-outreach, general-office, mobile-app, cli-automation, content-marketing, research-analysis, web-starter, it-infra-ops, app-maintenance). Default: web-fullstack
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
    printf '\nSelect domain module:\n'
    printf '  1) Fullstack Web Application (web-fullstack) [default]\n'
    printf '  2) Landing Page / Static Web (landing-page)\n'
    printf '  3) Sales & B2B Outreach (sales-outreach)\n'
    printf '  4) General Operations & Office (general-office)\n'
    printf '  5) Mobile Application (mobile-app)\n'
    printf '  6) CLI Tool & Automation Script (cli-automation)\n'
    printf '  7) Content Marketing & Social Media (content-marketing)\n'
    printf '  8) Research & Market Analysis (research-analysis)\n'
    printf '  9) Web Application Starter (web-starter)\n'
    printf ' 10) IT Infrastructure Operations (it-infra-ops)\n'
    printf ' 11) Application Maintenance & Brownfield (app-maintenance)\n'
    read -r -p 'Choose [1-11, default: 1]: ' mod_choice
    case "${mod_choice}" in
      2|landing-page) MODULE_ID="landing-page" ;;
      3|sales-outreach) MODULE_ID="sales-outreach" ;;
      4|general-office) MODULE_ID="general-office" ;;
      5|mobile-app) MODULE_ID="mobile-app" ;;
      6|cli-automation) MODULE_ID="cli-automation" ;;
      7|content-marketing) MODULE_ID="content-marketing" ;;
      8|research-analysis) MODULE_ID="research-analysis" ;;
      9|web-starter) MODULE_ID="web-starter" ;;
      10|it-infra-ops) MODULE_ID="it-infra-ops" ;;
      11|app-maintenance) MODULE_ID="app-maintenance" ;;
      *) MODULE_ID="web-fullstack" ;;
    esac
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
  cp "${REPO_ROOT}/scripts/validate-template.sh" "${ABS_TARGET}/scripts/validate-template.sh"
  cp "${REPO_ROOT}/scripts/validate-template.ps1" "${ABS_TARGET}/scripts/validate-template.ps1"
  chmod +x "${ABS_TARGET}/scripts/validate-template.sh"

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
     ./scripts/validate-template.sh
  3. Mulai fase Instantiation and Discovery bersama Agen AI:
     - Lengkapi docs/08-reference/template-variables.md
     - Catat keputusan arsitektur di docs/08-reference/decision-register.md
     - Jalankan ./scripts/validate-template.sh secara berkala untuk memantau kesiapan.
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
     ./scripts/validate-template.sh
  3. Begin the Instantiation and Discovery phase with your AI agent:
     - Define project requirements and fill out docs/08-reference/template-variables.md
     - Record architectural decisions in docs/08-reference/decision-register.md
     - Run ./scripts/validate-template.sh regularly to track implementation readiness.
==================================================
SUCCESS_MSG
fi
