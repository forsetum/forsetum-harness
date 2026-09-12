#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: bundle.sh [OPTIONS]

Bundle an AI Harness project by combining Core and a Domain Module.

Options:
  -l, --lang <en|id>        Template language (default: en)
  -m, --module <module_id>  Domain module to bundle (web-fullstack, landing-page, sales-outreach, general-office, mobile-app, cli-automation, content-marketing, research-analysis, web-starter, it-infra-ops, app-maintenance)
  -n, --name <name>         Project name (interpolates {{PROJECT_NAME}})
  -o, --output <file.zip>   Output zip archive destination (e.g. ./dist/my-project.zip)
  -d, --dir <directory>     Output uncompressed directory instead of zip
  -h, --help                Show this help message

Examples:
  ./scripts/bundle.sh --lang en --module landing-page --name "Klinik Cantik" --output ./dist/klinik.zip
  ./scripts/bundle.sh --lang en --module web-fullstack --name "E-Commerce API" --dir /tmp/ecommerce
USAGE
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

LANG_VAL="en"
MODULE_ID=""
PROJECT_NAME=""
OUTPUT_ZIP=""
OUTPUT_DIR=""

while (($# > 0)); do
  case "$1" in
    -l|--lang)
      (($# >= 2)) || { printf 'ERROR: --lang requires en or id\n' >&2; exit 2; }
      LANG_VAL="$2"
      shift 2
      ;;
    -m|--module)
      (($# >= 2)) || { printf 'ERROR: --module requires a module ID\n' >&2; exit 2; }
      MODULE_ID="$2"
      shift 2
      ;;
    -n|--name)
      (($# >= 2)) || { printf 'ERROR: --name requires a project name\n' >&2; exit 2; }
      PROJECT_NAME="$2"
      shift 2
      ;;
    -o|--output)
      (($# >= 2)) || { printf 'ERROR: --output requires a file path (.zip)\n' >&2; exit 2; }
      OUTPUT_ZIP="$2"
      shift 2
      ;;
    -d|--dir)
      (($# >= 2)) || { printf 'ERROR: --dir requires a directory path\n' >&2; exit 2; }
      OUTPUT_DIR="$2"
      shift 2
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

if [[ -z "${MODULE_ID}" ]]; then
  printf 'ERROR: --module is required. Choose one from: web-fullstack, landing-page, sales-outreach, general-office, mobile-app, cli-automation, content-marketing, research-analysis, web-starter, it-infra-ops, app-maintenance\n' >&2
  exit 2
fi

if [[ -z "${OUTPUT_ZIP}" && -z "${OUTPUT_DIR}" ]]; then
  printf 'ERROR: Either --output <file.zip> or --dir <directory> must be specified.\n' >&2
  exit 2
fi

TEMPLATE_DIR="${REPO_ROOT}/template/${LANG_VAL}"
CORE_DIR="${TEMPLATE_DIR}/core"
MODULE_DIR="${TEMPLATE_DIR}/modules/${MODULE_ID}"

if [[ ! -d "${CORE_DIR}" ]]; then
  printf 'ERROR: Core directory not found: %s\n' "${CORE_DIR}" >&2
  exit 1
fi

if [[ ! -d "${MODULE_DIR}" ]]; then
  printf 'ERROR: Module directory not found: %s\n' "${MODULE_DIR}" >&2
  printf 'Available modules:\n' >&2
  if [[ -d "${TEMPLATE_DIR}/modules" ]]; then
    ls -1 "${TEMPLATE_DIR}/modules" >&2
  fi
  exit 1
fi

# Create staging directory
STAGING_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${STAGING_DIR}"
}
trap cleanup EXIT

printf '==> Staging core harness from: %s\n' "${CORE_DIR}"
cp -R "${CORE_DIR}/." "${STAGING_DIR}/"

printf '==> Applying overlay module: %s\n' "${MODULE_ID}"
cp -R "${MODULE_DIR}/." "${STAGING_DIR}/"

# Inject validator scripts
mkdir -p "${STAGING_DIR}/scripts"
cp "${REPO_ROOT}/scripts/validate-template.sh" "${STAGING_DIR}/scripts/validate-template.sh"
cp "${REPO_ROOT}/scripts/validate-template.ps1" "${STAGING_DIR}/scripts/validate-template.ps1"
chmod +x "${STAGING_DIR}/scripts/validate-template.sh"

# Module-specific stitching definitions
INDEX_TABLE=""
VARS_TABLE=""
READINESS_TABLE=""

case "${MODULE_ID}" in
  web-fullstack)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **00-overview** | [`00-overview/architecture.md`](00-overview/architecture.md) | Technical architecture, data flows, and subsystem diagram |
| **01-server** | [`01-server/provisioning-specs.md`](01-server/provisioning-specs.md) | Infrastructure, runtime, and server specifications |
| **02-application** | [`02-application/backend-api-guide.md`](02-application/backend-api-guide.md) | Backend API endpoints and interface contracts |
| **03-security** | [`03-security/security-model.md`](03-security/security-model.md) | Security controls, authentication, and permission matrix |
| **04-operations** | [`04-operations/deployment-checklist.md`](04-operations/deployment-checklist.md) | CI/CD, production release, and deployment checklist |
| **05-monitoring** | [`05-monitoring/monitoring-guide.md`](05-monitoring/monitoring-guide.md) | Observability, metrics, and structured logging standards |
| **06-troubleshooting** | [`06-troubleshooting/troubleshooting-guide.md`](06-troubleshooting/troubleshooting-guide.md) | Incident mitigation matrix and troubleshooting playbooks |
| **07-disaster-recovery** | [`07-disaster-recovery/disaster-recovery.md`](07-disaster-recovery/disaster-recovery.md) | RPO, RTO, backups, and disaster recovery plan |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{PRIMARY_LANGUAGE}}` | web-fullstack | Required | Core programming language | `{{PRIMARY_LANGUAGE}}` |
| `{{FRAMEWORK_OR_PLATFORM}}` | web-fullstack | Required | Backend / frontend framework | `{{FRAMEWORK_OR_PLATFORM}}` |
| `{{PERSISTENCE_STRATEGY}}` | web-fullstack | Required | Database or persistent storage | `{{PERSISTENCE_STRATEGY}}` |
| `{{DEPLOYMENT_PLATFORM}}` | web-fullstack | Required | Target hosting or cloud provider | `{{DEPLOYMENT_PLATFORM}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Database & Persistence | web-fullstack | Persistence strategy and schema defined | [ ] | In provisioning-specs.md |
| API & Auth Boundaries | web-fullstack | API interface contract and authentication model ready | [ ] | In backend-api-guide.md |
| Operations & DR Plan | web-fullstack | Deployment checklist and disaster recovery plan documented | [ ] | In operations/ and dr/ |
EOF
)
    ;;

  landing-page)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-copywriting** | [`01-copywriting/value-proposition-and-copy.md`](01-copywriting/value-proposition-and-copy.md) | Headline, messaging hierarchy, benefits, and CTA copy |
| **02-layout** | [`02-layout/wireframe-and-sections.md`](02-layout/wireframe-and-sections.md) | Visual hierarchy, responsive breakpoints, and section order |
| **03-assets** | [`03-assets/style-and-branding.md`](03-assets/style-and-branding.md) | Typography, color design tokens, and media specifications |
| **04-hosting** | [`04-hosting/deployment-and-analytics.md`](04-hosting/deployment-and-analytics.md) | Static hosting, custom domain, SEO tags, and analytics |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{TARGET_AUDIENCE}}` | landing-page | Required | Ideal visitor or customer persona | `{{TARGET_AUDIENCE}}` |
| `{{PRIMARY_CTA}}` | landing-page | Required | Main conversion action label | `{{PRIMARY_CTA}}` |
| `{{HOSTING_TARGET}}` | landing-page | Required | Static web host (e.g. Vercel, Cloudflare, Netlify) | `{{HOSTING_TARGET}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Copywriting Approved | landing-page | Headline, value proposition, and CTA copy reviewed | [ ] | In value-proposition-and-copy.md |
| Responsive Layout Set | landing-page | Wireframe section order and mobile breakpoints confirmed | [ ] | In wireframe-and-sections.md |
| Static Host & SEO Ready | landing-page | Target host and OpenGraph SEO meta tags specified | [ ] | In deployment-and-analytics.md |
EOF
)
    ;;

  sales-outreach)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-sales-playbook** | [`01-sales-playbook/icp-and-targets.md`](01-sales-playbook/icp-and-targets.md) | Ideal Customer Profile criteria, revenue quotas, and ROI anchors |
| **02-pipeline** | [`02-pipeline/lead-qualification-and-stages.md`](02-pipeline/lead-qualification-and-stages.md) | Deal progression stages, BANT qualification, and SLAs |
| **03-messaging** | [`03-messaging/pitch-scripts-and-templates.md`](03-messaging/pitch-scripts-and-templates.md) | Multi-channel outreach templates and objection handling scripts |
| **04-crm** | [`04-crm/tracking-and-reporting.md`](04-crm/tracking-and-reporting.md) | CRM lead schema, pipeline review cadence, and conversion KPIs |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{SALES_TARGET}}` | sales-outreach | Required | Target revenue milestone or quota | `{{SALES_TARGET}}` |
| `{{ICP_PROFILE}}` | sales-outreach | Required | Criteria for ideal customer organizations | `{{ICP_PROFILE}}` |
| `{{OUTREACH_CHANNELS}}` | sales-outreach | Required | Outreach touchpoints (Email, LinkedIn, Phone) | `{{OUTREACH_CHANNELS}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| ICP & Lead List Prepared | sales-outreach | Target customer profile and prospect sources verified | [ ] | In icp-and-targets.md |
| Pitch Templates Approved | sales-outreach | Touchpoint sequences and objection scripts reviewed | [ ] | In pitch-scripts-and-templates.md |
| Pipeline SLA Defined | sales-outreach | Deal stages, qualification rules, and follow-up SLAs set | [ ] | In lead-qualification-and-stages.md |
EOF
)
    ;;

  general-office)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-procedures** | [`01-procedures/sop-and-workflow.md`](01-procedures/sop-and-workflow.md) | Operating procedures, step-by-step workflow, and RACI matrix |
| **02-deliverables** | [`02-deliverables/milestone-artifacts-spec.md`](02-deliverables/milestone-artifacts-spec.md) | Deliverable formats, document templates, and style rules |
| **03-resources** | [`03-resources/tools-and-data-sources.md`](03-resources/tools-and-data-sources.md) | Authoritative data sources, shared drives, and confidentiality |
| **04-reporting** | [`04-reporting/status-reporting-schedule.md`](04-reporting/status-reporting-schedule.md) | Recurring reporting cadence, status templates, and minutes rules |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{OPERATION_SCOPE}}` | general-office | Required | Scope of work and department boundaries | `{{OPERATION_SCOPE}}` |
| `{{PRIMARY_DELIVERABLE}}` | general-office | Required | Main deliverable format and title | `{{PRIMARY_DELIVERABLE}}` |
| `{{REPORTING_SCHEDULE}}` | general-office | Required | Rhythm of recurring updates (e.g. Weekly) | `{{REPORTING_SCHEDULE}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| SOP & Approval Defined | general-office | Operating procedure steps and RACI matrix approved | [ ] | In sop-and-workflow.md |
| Deliverables Format Confirmed | general-office | Document templates and quality criteria agreed | [ ] | In milestone-artifacts-spec.md |
| Resources & Cadence Set | general-office | Data source access verified and reporting schedule set | [ ] | In resources/ and reporting/ |
EOF
)
    ;;

  mobile-app)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-platform** | [`01-platform/mobile-spec-and-permissions.md`](01-platform/mobile-spec-and-permissions.md) | OS targets, runtime framework, and hardware permission justifications |
| **02-architecture** | [`02-architecture/state-and-offline-sync.md`](02-architecture/state-and-offline-sync.md) | Client state management, local database, and offline sync queue |
| **03-store-guidelines** | [`03-store-guidelines/app-store-and-play-store.md`](03-store-guidelines/app-store-and-play-store.md) | App Store and Google Play compliance and review rejection checklist |
| **04-distribution** | [`04-distribution/build-and-signing.md`](04-distribution/build-and-signing.md) | Code signing, CI/CD pipeline, TestFlight, and release versioning |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{MOBILE_FRAMEWORK}}` | mobile-app | Required | Mobile framework or runtime | `{{MOBILE_FRAMEWORK}}` |
| `{{TARGET_OS}}` | mobile-app | Required | Target mobile operating systems | `{{TARGET_OS}}` |
| `{{MIN_OS_VERSION}}` | mobile-app | Required | Minimum supported mobile OS version | `{{MIN_OS_VERSION}}` |
| `{{APP_BUNDLE_ID}}` | mobile-app | Required | Application package or bundle ID | `{{APP_BUNDLE_ID}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Platform & Permissions Defined | mobile-app | Target OS, min version, and camera/location permissions documented | [ ] | In mobile-spec-and-permissions.md |
| Architecture & Offline Caching | mobile-app | State container, local database, and sync queue established | [ ] | In state-and-offline-sync.md |
| Store Compliance & Signing Keys | mobile-app | App Store guidelines met and signing keystores configured | [ ] | In store-guidelines/ and distribution/ |
EOF
)
    ;;

  cli-automation)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-interface** | [`01-interface/cli-args-and-options.md`](01-interface/cli-args-and-options.md) | Command syntax, POSIX flags, subcommands, and config hierarchy |
| **02-runtime** | [`02-runtime/execution-and-exit-codes.md`](02-runtime/execution-and-exit-codes.md) | Standard streams, deterministic exit codes, and signal handling |
| **03-pipeline** | [`03-pipeline/data-ingestion-and-batch.md`](03-pipeline/data-ingestion-and-batch.md) | Batch chunking, memory limits, and dead-letter quarantine |
| **04-daemon** | [`04-daemon/cron-and-background-tasks.md`](04-daemon/cron-and-background-tasks.md) | Systemd daemon service, crontab schedule, and log rotation |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{CLI_LANGUAGE}}` | cli-automation | Required | Scripting or programming language | `{{CLI_LANGUAGE}}` |
| `{{COMMAND_NAME}}` | cli-automation | Required | Primary command binary or alias | `{{COMMAND_NAME}}` |
| `{{RUN_MODE}}` | cli-automation | Required | Execution model (Interactive, Cron, Daemon) | `{{RUN_MODE}}` |
| `{{LOG_OUTPUT_TARGET}}` | cli-automation | Required | Log output destination | `{{LOG_OUTPUT_TARGET}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| CLI Interface & Flags Defined | cli-automation | Command arguments, options, and help text approved | [ ] | In cli-args-and-options.md |
| Runtime & Exit Codes Mapped | cli-automation | POSIX exit codes, standard streams, and signals established | [ ] | In execution-and-exit-codes.md |
| Pipeline & Supervisor Setup | cli-automation | Batch chunking and systemd/cron schedule verified | [ ] | In pipeline/ and daemon/ |
EOF
)
    ;;

  content-marketing)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-editorial** | [`01-editorial/content-calendar-and-themes.md`](01-editorial/content-calendar-and-themes.md) | Content pillars, funnel stages, and editorial publishing cadence |
| **02-seo** | [`02-seo/keyword-research-and-clusters.md`](02-seo/keyword-research-and-clusters.md) | Target keywords, topic cluster architecture, and on-page checklist |
| **03-brand-voice** | [`03-brand-voice/style-and-tone-guide.md`](03-brand-voice/style-and-tone-guide.md) | Brand tone of voice, vocabulary rules, and formatting standards |
| **04-distribution** | [`04-distribution/repurposing-and-channels.md`](04-distribution/repurposing-and-channels.md) | Content atomization, channel matrix, and performance metrics |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{CONTENT_PILLARS}}` | content-marketing | Required | Core themes for editorial production | `{{CONTENT_PILLARS}}` |
| `{{TARGET_KEYWORDS}}` | content-marketing | Required | Primary SEO keywords and search intent | `{{TARGET_KEYWORDS}}` |
| `{{BRAND_TONE}}` | content-marketing | Required | Brand persona and tone of voice | `{{BRAND_TONE}}` |
| `{{PRIMARY_CHANNELS}}` | content-marketing | Required | Publishing and distribution channels | `{{PRIMARY_CHANNELS}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Editorial Pillars Established | content-marketing | Core themes, funnel stages, and publishing cadence agreed | [ ] | In content-calendar-and-themes.md |
| SEO Clusters & Intent Mapped | content-marketing | Keywords, topic clusters, and on-page checklist confirmed | [ ] | In keyword-research-and-clusters.md |
| Brand Voice & Distribution Set | content-marketing | Tone guidelines and repurposing workflow ready | [ ] | In brand-voice/ and distribution/ |
EOF
)
    ;;

  research-analysis)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-methodology** | [`01-methodology/research-framework-and-scope.md`](01-methodology/research-framework-and-scope.md) | Research topic, hypotheses, methodology, and scoping boundaries |
| **02-data-gathering** | [`02-data-gathering/sources-and-verification.md`](02-data-gathering/sources-and-verification.md) | Source credibility tiers, triangulation, and citation standards |
| **03-analysis** | [`03-analysis/synthesis-and-benchmarking.md`](03-analysis/synthesis-and-benchmarking.md) | Competitive feature matrix, qualitative coding, and finding synthesis |
| **04-executive-summary** | [`04-executive-summary/decision-memo-template.md`](04-executive-summary/decision-memo-template.md) | 1-page executive brief, options trade-offs, and approval block |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{RESEARCH_TOPIC}}` | research-analysis | Required | Core research question or problem statement | `{{RESEARCH_TOPIC}}` |
| `{{RESEARCH_METHODOLOGY}}` | research-analysis | Required | Research methodology approach | `{{RESEARCH_METHODOLOGY}}` |
| `{{PRIMARY_SOURCES}}` | research-analysis | Required | Authoritative data sources | `{{PRIMARY_SOURCES}}` |
| `{{EXECUTIVE_AUDIENCE}}` | research-analysis | Required | Target leadership stakeholders | `{{EXECUTIVE_AUDIENCE}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Research Scope & Hypotheses Set | research-analysis | Core problem, hypotheses, and scope boundaries confirmed | [ ] | In research-framework-and-scope.md |
| Sources & Triangulation Ready | research-analysis | Source credibility tiers and fact-checking rules defined | [ ] | In sources-and-verification.md |
| Decision Memo Format Approved | research-analysis | Feature benchmarking and trade-off matrix template established | [ ] | In synthesis/ and executive-summary/ |
EOF
)
    ;;

  web-starter)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **00-overview** | [`00-overview/architecture.md`](00-overview/architecture.md) | High-level system architecture, client flow, and stack overview |
| **01-app** | [`01-app/app-guide.md`](01-app/app-guide.md) | Directory layout, core views, components, and data fetching flow |
| **02-database** | [`02-database/schema-and-persistence.md`](02-database/schema-and-persistence.md) | MVP data entities, schema definition, and persistence strategy |
| **03-testing** | [`03-testing/acceptance-criteria.md`](03-testing/acceptance-criteria.md) | Functional acceptance criteria and code quality verification gates |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{PRIMARY_LANGUAGE}}` | web-starter | Required | Core programming language | `{{PRIMARY_LANGUAGE}}` |
| `{{FRAMEWORK_OR_PLATFORM}}` | web-starter | Required | Web framework or UI library | `{{FRAMEWORK_OR_PLATFORM}}` |
| `{{PERSISTENCE_STRATEGY}}` | web-starter | Required | Database or storage mechanism | `{{PERSISTENCE_STRATEGY}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Core User Flow Defined | web-starter | User journey, MVP views, and component hierarchy outlined | [ ] | In architecture.md and app-guide.md |
| Tech Stack & Persistence Confirmed | web-starter | Framework, styling approach, and storage engine selected | [ ] | In architecture.md and schema-and-persistence.md |
| Acceptance Criteria Established | web-starter | Functional checklist and quality verification gates documented | [ ] | In acceptance-criteria.md |
EOF
)
    ;;

  it-infra-ops)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **01-server** | [`01-server/server-inventory.md`](01-server/server-inventory.md) | Physical & virtual node inventory, LAN IPs, and server roles |
| **04-operations** | [`04-operations/maintenance-sop.md`](04-operations/maintenance-sop.md) | Routine maintenance checklist, OS security patching, and log audit |
| **05-monitoring** | [`05-monitoring/incident-runbook.md`](05-monitoring/incident-runbook.md) | Severity matrix and emergency runbooks (disk full, CPU spike, DB lock) |
| **06-troubleshooting** | [`06-troubleshooting/change-management.md`](06-troubleshooting/change-management.md) | Maintenance window protocol, pre-flight checklist, and rollback procedures |
| **07-disaster-recovery** | [`07-disaster-recovery/backup-restore-sop.md`](07-disaster-recovery/backup-restore-sop.md) | 3-2-1 backup strategy, schedule, and quarterly restoration drills |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{INFRA_ENVIRONMENT}}` | it-infra-ops | Required | Infrastructure environment type | `{{INFRA_ENVIRONMENT}}` |
| `{{PRIMARY_OS}}` | it-infra-ops | Required | Primary server operating system | `{{PRIMARY_OS}}` |
| `{{MAINTENANCE_WINDOW}}` | it-infra-ops | Required | Official recurring maintenance window | `{{MAINTENANCE_WINDOW}}` |
| `{{BACKUP_DESTINATION}}` | it-infra-ops | Required | Target backup storage location | `{{BACKUP_DESTINATION}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Server Inventory Mapped | it-infra-ops | Node specs, LAN IP allocation, and roles documented | [ ] | In server-inventory.md |
| Maintenance SOP & Runbooks Approved | it-infra-ops | Daily/monthly routines and incident escalation defined | [ ] | In maintenance-sop.md and incident-runbook.md |
| Change Protocol & DR Drills Verified | it-infra-ops | Rollback triggers and backup restoration drills tested | [ ] | In change-management.md and backup-restore-sop.md |
EOF
)
    ;;

  app-maintenance)
    INDEX_TABLE=$(cat <<'EOF'
| Section | Document | Description |
|---|---|---|
| **00-overview** | [`00-overview/system-context-map.md`](00-overview/system-context-map.md) | Existing host system architecture, upstream boundaries, and code zoning |
| **02-application** | [`02-application/extension-guide.md`](02-application/extension-guide.md) | Custom module development standards, isolation rules, and schema extensions |
| **03-security** | [`03-security/upstream-compatibility.md`](03-security/upstream-compatibility.md) | Upstream compatibility policy, surgical patching, and dependency isolation |
| **06-troubleshooting** | [`06-troubleshooting/bug-triage-sop.md`](06-troubleshooting/bug-triage-sop.md) | 4-phase bug triage workflow, reproduction steps, and non-regression tests |
EOF
)
    VARS_TABLE=$(cat <<'EOF'
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{HOST_APPLICATION}}` | app-maintenance | Required | Host/upstream application name and version | `{{HOST_APPLICATION}}` |
| `{{SOURCE_MODEL}}` | app-maintenance | Required | Code source model (Open Source / Closed Source) | `{{SOURCE_MODEL}}` |
| `{{PRIMARY_LANGUAGE}}` | app-maintenance | Required | Core programming language of the application | `{{PRIMARY_LANGUAGE}}` |
| `{{EXTENSION_PATTERN}}` | app-maintenance | Required | Permitted extension or integration pattern | `{{EXTENSION_PATTERN}}` |
EOF
)
    READINESS_TABLE=$(cat <<'EOF'
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| System Context & Boundaries Mapped | app-maintenance | Host app version, no-touch core zones, and hooks identified | [ ] | In system-context-map.md |
| Extension Standards & Upstream Policy | app-maintenance | Module layout, schema rules, and patch strategies defined | [ ] | In extension-guide.md and upstream-compatibility.md |
| Bug Triage & Regression Checklist Ready | app-maintenance | 4-phase bug workflow and reproduction criteria established | [ ] | In bug-triage-sop.md |
EOF
)
    ;;
esac

# Stitch INDEX.md
INDEX_FILE="${STAGING_DIR}/docs/INDEX.md"
if [[ -f "${INDEX_FILE}" ]]; then
  awk -v tbl="${INDEX_TABLE}" '
    /<!-- MODULE_DOCS_START -->/ {
      print $0
      print tbl
      skip = 1
      next
    }
    /<!-- MODULE_DOCS_END -->/ {
      skip = 0
      print $0
      next
    }
    !skip { print }
  ' "${INDEX_FILE}" > "${INDEX_FILE}.tmp" && mv "${INDEX_FILE}.tmp" "${INDEX_FILE}"
fi

# Stitch template-variables.md
VARS_FILE="${STAGING_DIR}/docs/08-reference/template-variables.md"
if [[ -f "${VARS_FILE}" ]]; then
  awk -v tbl="${VARS_TABLE}" '
    /<!-- MODULE_VARS_START -->/ {
      print $0
      print tbl
      skip = 1
      next
    }
    /<!-- MODULE_VARS_END -->/ {
      skip = 0
      print $0
      next
    }
    !skip { print }
  ' "${VARS_FILE}" > "${VARS_FILE}.tmp" && mv "${VARS_FILE}.tmp" "${VARS_FILE}"
fi

# Stitch implementation-readiness.md
READINESS_FILE="${STAGING_DIR}/docs/09-governance/implementation-readiness.md"
if [[ -f "${READINESS_FILE}" ]]; then
  awk -v tbl="${READINESS_TABLE}" '
    /<!-- MODULE_READINESS_START -->/ {
      print $0
      print tbl
      skip = 1
      next
    }
    /<!-- MODULE_READINESS_END -->/ {
      skip = 0
      print $0
      next
    }
    !skip { print }
  ' "${READINESS_FILE}" > "${READINESS_FILE}.tmp" && mv "${READINESS_FILE}.tmp" "${READINESS_FILE}"
fi

# Interpolate PROJECT_NAME if specified
if [[ -n "${PROJECT_NAME}" ]]; then
  printf '==> Interpolating project name: "%s"\n' "${PROJECT_NAME}"
  while IFS= read -r file; do
    if grep -q '{{PROJECT_NAME}}' "${file}" 2>/dev/null; then
      awk -v name="${PROJECT_NAME}" '{gsub(/\{\{PROJECT_NAME\}\}/, name)} 1' "${file}" > "${file}.tmp" && mv "${file}.tmp" "${file}"
    fi
  done < <(find "${STAGING_DIR}" -type f -name "*.md")
fi

# Export destination
if [[ -n "${OUTPUT_DIR}" ]]; then
  mkdir -p "${OUTPUT_DIR}"
  ABS_OUT_DIR="$(cd -- "${OUTPUT_DIR}" && pwd)"
  cp -R "${STAGING_DIR}/." "${ABS_OUT_DIR}/"
  printf '==> Exported assembled project to directory: %s\n' "${ABS_OUT_DIR}"
fi

if [[ -n "${OUTPUT_ZIP}" ]]; then
  ZIP_DIR="$(dirname "${OUTPUT_ZIP}")"
  mkdir -p "${ZIP_DIR}"
  ABS_ZIP="$(cd -- "${ZIP_DIR}" && pwd)/$(basename "${OUTPUT_ZIP}")"
  rm -f "${ABS_ZIP}"
  (cd -- "${STAGING_DIR}" && zip -r -q "${ABS_ZIP}" .)
  printf '==> Exported project bundle archive: %s\n' "${ABS_ZIP}"
fi

printf '==================================================\n'
printf '  AI Harness Bundle Complete: %s (%s)\n' "${MODULE_ID}" "${LANG_VAL}"
printf '==================================================\n'
