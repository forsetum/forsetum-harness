<#
.SYNOPSIS
    Cross-platform AI Harness Bundler for Windows PowerShell and PowerShell Core.

.DESCRIPTION
    Combines Core template and a selected Domain Module, stitches module documents into
    the master index and readiness gate, and exports an assembled project or ready-to-run .zip archive.

.PARAMETER Lang
    Template language ('en' or 'id'). Default: en.

.PARAMETER Module
    Domain module to bundle (web-fullstack, landing-page, sales-outreach, general-office, mobile-app, cli-automation, content-marketing, research-analysis, web-starter, it-infra-ops, app-maintenance).

.PARAMETER Name
    Project name (interpolates {{PROJECT_NAME}} across markdown files).

.PARAMETER Output
    Output .zip archive path.

.PARAMETER Dir
    Output directory path.

.EXAMPLE
    .\scripts\bundle.ps1 -Module landing-page -Name "Klinik Cantik" -Output .\dist\klinik.zip
    .\scripts\bundle.ps1 -Module web-fullstack -Name "E-Commerce API" -Dir C:\Projects\ecommerce
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet('en', 'id')]
    [string]$Lang = 'en',

    [Parameter(Mandatory = $true)]
    [ValidateSet('web-fullstack', 'landing-page', 'sales-outreach', 'general-office', 'mobile-app', 'cli-automation', 'content-marketing', 'research-analysis', 'web-starter', 'it-infra-ops', 'app-maintenance')]
    [string]$Module,

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [string]$Output,

    [Parameter()]
    [string]$Dir
)

$ErrorActionPreference = 'Stop'

if (-not $Output -and -not $Dir) {
    Write-Error "Either -Output <file.zip> or -Dir <directory> must be specified."
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$TemplateDir = Join-Path $RepoRoot "template\$Lang"
$CoreDir = Join-Path $TemplateDir "core"
$ModuleDir = Join-Path $TemplateDir "modules\$Module"

if (-not (Test-Path $CoreDir)) {
    Write-Error "Core directory not found: $CoreDir"
    exit 1
}

if (-not (Test-Path $ModuleDir)) {
    Write-Error "Module directory not found: $ModuleDir"
    exit 1
}

$StagingDir = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-staging-" + [System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $StagingDir -Force | Out-Null

try {
    Write-Host "==> Staging core harness from: $CoreDir" -ForegroundColor Cyan
    Copy-Item -Path "$CoreDir\*" -Destination $StagingDir -Recurse -Force

    Write-Host "==> Applying overlay module: $Module" -ForegroundColor Cyan
    Copy-Item -Path "$ModuleDir\*" -Destination $StagingDir -Recurse -Force

    # Inject validator scripts
    $stagingScripts = Join-Path $StagingDir "scripts"
    if (-not (Test-Path $stagingScripts)) {
        New-Item -ItemType Directory -Path $stagingScripts -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $RepoRoot "scripts\validate-template.sh") -Destination (Join-Path $stagingScripts "validate-template.sh") -Force
    Copy-Item -Path (Join-Path $RepoRoot "scripts\validate-template.ps1") -Destination (Join-Path $stagingScripts "validate-template.ps1") -Force

    # Stitching logic
    $IndexTable = ""
    $VarsTable = ""
    $ReadinessTable = ""

    switch ($Module) {
        'web-fullstack' {
            $IndexTable = @"
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
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{PRIMARY_LANGUAGE}}` | web-fullstack | Required | Core programming language | `{{PRIMARY_LANGUAGE}}` |
| `{{FRAMEWORK_OR_PLATFORM}}` | web-fullstack | Required | Backend / frontend framework | `{{FRAMEWORK_OR_PLATFORM}}` |
| `{{PERSISTENCE_STRATEGY}}` | web-fullstack | Required | Database or persistent storage | `{{PERSISTENCE_STRATEGY}}` |
| `{{DEPLOYMENT_PLATFORM}}` | web-fullstack | Required | Target hosting or cloud provider | `{{DEPLOYMENT_PLATFORM}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Database & Persistence | web-fullstack | Persistence strategy and schema defined | [ ] | In provisioning-specs.md |
| API & Auth Boundaries | web-fullstack | API interface contract and authentication model ready | [ ] | In backend-api-guide.md |
| Operations & DR Plan | web-fullstack | Deployment checklist and disaster recovery plan documented | [ ] | In operations/ and dr/ |
"@
        }
        'landing-page' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-copywriting** | [`01-copywriting/value-proposition-and-copy.md`](01-copywriting/value-proposition-and-copy.md) | Headline, messaging hierarchy, benefits, and CTA copy |
| **02-layout** | [`02-layout/wireframe-and-sections.md`](02-layout/wireframe-and-sections.md) | Visual hierarchy, responsive breakpoints, and section order |
| **03-assets** | [`03-assets/style-and-branding.md`](03-assets/style-and-branding.md) | Typography, color design tokens, and media specifications |
| **04-hosting** | [`04-hosting/deployment-and-analytics.md`](04-hosting/deployment-and-analytics.md) | Static hosting, custom domain, SEO tags, and analytics |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{TARGET_AUDIENCE}}` | landing-page | Required | Ideal visitor or customer persona | `{{TARGET_AUDIENCE}}` |
| `{{PRIMARY_CTA}}` | landing-page | Required | Main conversion action label | `{{PRIMARY_CTA}}` |
| `{{HOSTING_TARGET}}` | landing-page | Required | Static web host (e.g. Vercel, Cloudflare, Netlify) | `{{HOSTING_TARGET}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Copywriting Approved | landing-page | Headline, value proposition, and CTA copy reviewed | [ ] | In value-proposition-and-copy.md |
| Responsive Layout Set | landing-page | Wireframe section order and mobile breakpoints confirmed | [ ] | In wireframe-and-sections.md |
| Static Host & SEO Ready | landing-page | Target host and OpenGraph SEO meta tags specified | [ ] | In deployment-and-analytics.md |
"@
        }
        'sales-outreach' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-sales-playbook** | [`01-sales-playbook/icp-and-targets.md`](01-sales-playbook/icp-and-targets.md) | Ideal Customer Profile criteria, revenue quotas, and ROI anchors |
| **02-pipeline** | [`02-pipeline/lead-qualification-and-stages.md`](02-pipeline/lead-qualification-and-stages.md) | Deal progression stages, BANT qualification, and SLAs |
| **03-messaging** | [`03-messaging/pitch-scripts-and-templates.md`](03-messaging/pitch-scripts-and-templates.md) | Multi-channel outreach templates and objection handling scripts |
| **04-crm** | [`04-crm/tracking-and-reporting.md`](04-crm/tracking-and-reporting.md) | CRM lead schema, pipeline review cadence, and conversion KPIs |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{SALES_TARGET}}` | sales-outreach | Required | Target revenue milestone or quota | `{{SALES_TARGET}}` |
| `{{ICP_PROFILE}}` | sales-outreach | Required | Criteria for ideal customer organizations | `{{ICP_PROFILE}}` |
| `{{OUTREACH_CHANNELS}}` | sales-outreach | Required | Outreach touchpoints (Email, LinkedIn, Phone) | `{{OUTREACH_CHANNELS}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| ICP & Lead List Prepared | sales-outreach | Target customer profile and prospect sources verified | [ ] | In icp-and-targets.md |
| Pitch Templates Approved | sales-outreach | Touchpoint sequences and objection scripts reviewed | [ ] | In pitch-scripts-and-templates.md |
| Pipeline SLA Defined | sales-outreach | Deal stages, qualification rules, and follow-up SLAs set | [ ] | In lead-qualification-and-stages.md |
"@
        }
        'general-office' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-procedures** | [`01-procedures/sop-and-workflow.md`](01-procedures/sop-and-workflow.md) | Operating procedures, step-by-step workflow, and RACI matrix |
| **02-deliverables** | [`02-deliverables/milestone-artifacts-spec.md`](02-deliverables/milestone-artifacts-spec.md) | Deliverable formats, document templates, and style rules |
| **03-resources** | [`03-resources/tools-and-data-sources.md`](03-resources/tools-and-data-sources.md) | Authoritative data sources, shared drives, and confidentiality |
| **04-reporting** | [`04-reporting/status-reporting-schedule.md`](04-reporting/status-reporting-schedule.md) | Recurring reporting cadence, status templates, and minutes rules |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{OPERATION_SCOPE}}` | general-office | Required | Scope of work and department boundaries | `{{OPERATION_SCOPE}}` |
| `{{PRIMARY_DELIVERABLE}}` | general-office | Required | Main deliverable format and title | `{{PRIMARY_DELIVERABLE}}` |
| `{{REPORTING_SCHEDULE}}` | general-office | Required | Rhythm of recurring updates (e.g. Weekly) | `{{REPORTING_SCHEDULE}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| SOP & Approval Defined | general-office | Operating procedure steps and RACI matrix approved | [ ] | In sop-and-workflow.md |
| Deliverables Format Confirmed | general-office | Document templates and quality criteria agreed | [ ] | In milestone-artifacts-spec.md |
| Resources & Cadence Set | general-office | Data source access verified and reporting schedule set | [ ] | In resources/ and reporting/ |
"@
        }
        'mobile-app' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-platform** | [`01-platform/mobile-spec-and-permissions.md`](01-platform/mobile-spec-and-permissions.md) | OS targets, runtime framework, and hardware permission justifications |
| **02-architecture** | [`02-architecture/state-and-offline-sync.md`](02-architecture/state-and-offline-sync.md) | Client state management, local database, and offline sync queue |
| **03-store-guidelines** | [`03-store-guidelines/app-store-and-play-store.md`](03-store-guidelines/app-store-and-play-store.md) | App Store and Google Play compliance and review rejection checklist |
| **04-distribution** | [`04-distribution/build-and-signing.md`](04-distribution/build-and-signing.md) | Code signing, CI/CD pipeline, TestFlight, and release versioning |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{MOBILE_FRAMEWORK}}` | mobile-app | Required | Mobile framework or runtime | `{{MOBILE_FRAMEWORK}}` |
| `{{TARGET_OS}}` | mobile-app | Required | Target mobile operating systems | `{{TARGET_OS}}` |
| `{{MIN_OS_VERSION}}` | mobile-app | Required | Minimum supported mobile OS version | `{{MIN_OS_VERSION}}` |
| `{{APP_BUNDLE_ID}}` | mobile-app | Required | Application package or bundle ID | `{{APP_BUNDLE_ID}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Platform & Permissions Defined | mobile-app | Target OS, min version, and camera/location permissions documented | [ ] | In mobile-spec-and-permissions.md |
| Architecture & Offline Caching | mobile-app | State container, local database, and sync queue established | [ ] | In state-and-offline-sync.md |
| Store Compliance & Signing Keys | mobile-app | App Store guidelines met and signing keystores configured | [ ] | In store-guidelines/ and distribution/ |
"@
        }
        'cli-automation' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-interface** | [`01-interface/cli-args-and-options.md`](01-interface/cli-args-and-options.md) | Command syntax, POSIX flags, subcommands, and config hierarchy |
| **02-runtime** | [`02-runtime/execution-and-exit-codes.md`](02-runtime/execution-and-exit-codes.md) | Standard streams, deterministic exit codes, and signal handling |
| **03-pipeline** | [`03-pipeline/data-ingestion-and-batch.md`](03-pipeline/data-ingestion-and-batch.md) | Batch chunking, memory limits, and dead-letter quarantine |
| **04-daemon** | [`04-daemon/cron-and-background-tasks.md`](04-daemon/cron-and-background-tasks.md) | Systemd daemon service, crontab schedule, and log rotation |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{CLI_LANGUAGE}}` | cli-automation | Required | Scripting or programming language | `{{CLI_LANGUAGE}}` |
| `{{COMMAND_NAME}}` | cli-automation | Required | Primary command binary or alias | `{{COMMAND_NAME}}` |
| `{{RUN_MODE}}` | cli-automation | Required | Execution model (Interactive, Cron, Daemon) | `{{RUN_MODE}}` |
| `{{LOG_OUTPUT_TARGET}}` | cli-automation | Required | Log output destination | `{{LOG_OUTPUT_TARGET}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| CLI Interface & Flags Defined | cli-automation | Command arguments, options, and help text approved | [ ] | In cli-args-and-options.md |
| Runtime & Exit Codes Mapped | cli-automation | POSIX exit codes, standard streams, and signals established | [ ] | In execution-and-exit-codes.md |
| Pipeline & Supervisor Setup | cli-automation | Batch chunking and systemd/cron schedule verified | [ ] | In pipeline/ and daemon/ |
"@
        }
        'content-marketing' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-editorial** | [`01-editorial/content-calendar-and-themes.md`](01-editorial/content-calendar-and-themes.md) | Content pillars, funnel stages, and editorial publishing cadence |
| **02-seo** | [`02-seo/keyword-research-and-clusters.md`](02-seo/keyword-research-and-clusters.md) | Target keywords, topic cluster architecture, and on-page checklist |
| **03-brand-voice** | [`03-brand-voice/style-and-tone-guide.md`](03-brand-voice/style-and-tone-guide.md) | Brand tone of voice, vocabulary rules, and formatting standards |
| **04-distribution** | [`04-distribution/repurposing-and-channels.md`](04-distribution/repurposing-and-channels.md) | Content atomization, channel matrix, and performance metrics |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{CONTENT_PILLARS}}` | content-marketing | Required | Core themes for editorial production | `{{CONTENT_PILLARS}}` |
| `{{TARGET_KEYWORDS}}` | content-marketing | Required | Primary SEO keywords and search intent | `{{TARGET_KEYWORDS}}` |
| `{{BRAND_TONE}}` | content-marketing | Required | Brand persona and tone of voice | `{{BRAND_TONE}}` |
| `{{PRIMARY_CHANNELS}}` | content-marketing | Required | Publishing and distribution channels | `{{PRIMARY_CHANNELS}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Editorial Pillars Established | content-marketing | Core themes, funnel stages, and publishing cadence agreed | [ ] | In content-calendar-and-themes.md |
| SEO Clusters & Intent Mapped | content-marketing | Keywords, topic clusters, and on-page checklist confirmed | [ ] | In keyword-research-and-clusters.md |
| Brand Voice & Distribution Set | content-marketing | Tone guidelines and repurposing workflow ready | [ ] | In brand-voice/ and distribution/ |
"@
        }
        'research-analysis' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-methodology** | [`01-methodology/research-framework-and-scope.md`](01-methodology/research-framework-and-scope.md) | Research topic, hypotheses, methodology, and scoping boundaries |
| **02-data-gathering** | [`02-data-gathering/sources-and-verification.md`](02-data-gathering/sources-and-verification.md) | Source credibility tiers, triangulation, and citation standards |
| **03-analysis** | [`03-analysis/synthesis-and-benchmarking.md`](03-analysis/synthesis-and-benchmarking.md) | Competitive feature matrix, qualitative coding, and finding synthesis |
| **04-executive-summary** | [`04-executive-summary/decision-memo-template.md`](04-executive-summary/decision-memo-template.md) | 1-page executive brief, options trade-offs, and approval block |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{RESEARCH_TOPIC}}` | research-analysis | Required | Core research question or problem statement | `{{RESEARCH_TOPIC}}` |
| `{{RESEARCH_METHODOLOGY}}` | research-analysis | Required | Research methodology approach | `{{RESEARCH_METHODOLOGY}}` |
| `{{PRIMARY_SOURCES}}` | research-analysis | Required | Authoritative data sources | `{{PRIMARY_SOURCES}}` |
| `{{EXECUTIVE_AUDIENCE}}` | research-analysis | Required | Target leadership stakeholders | `{{EXECUTIVE_AUDIENCE}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Research Scope & Hypotheses Set | research-analysis | Core problem, hypotheses, and scope boundaries confirmed | [ ] | In research-framework-and-scope.md |
| Sources & Triangulation Ready | research-analysis | Source credibility tiers and fact-checking rules defined | [ ] | In sources-and-verification.md |
| Decision Memo Format Approved | research-analysis | Feature benchmarking and trade-off matrix template established | [ ] | In synthesis/ and executive-summary/ |
"@
        }
        'web-starter' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **00-overview** | [`00-overview/architecture.md`](00-overview/architecture.md) | High-level system architecture, client flow, and stack overview |
| **01-app** | [`01-app/app-guide.md`](01-app/app-guide.md) | Directory layout, core views, components, and data fetching flow |
| **02-database** | [`02-database/schema-and-persistence.md`](02-database/schema-and-persistence.md) | MVP data entities, schema definition, and persistence strategy |
| **03-testing** | [`03-testing/acceptance-criteria.md`](03-testing/acceptance-criteria.md) | Functional acceptance criteria and code quality verification gates |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{PRIMARY_LANGUAGE}}` | web-starter | Required | Core programming language | `{{PRIMARY_LANGUAGE}}` |
| `{{FRAMEWORK_OR_PLATFORM}}` | web-starter | Required | Web framework or UI library | `{{FRAMEWORK_OR_PLATFORM}}` |
| `{{PERSISTENCE_STRATEGY}}` | web-starter | Required | Database or storage mechanism | `{{PERSISTENCE_STRATEGY}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Core User Flow Defined | web-starter | User journey, MVP views, and component hierarchy outlined | [ ] | In architecture.md and app-guide.md |
| Tech Stack & Persistence Confirmed | web-starter | Framework, styling approach, and storage engine selected | [ ] | In architecture.md and schema-and-persistence.md |
| Acceptance Criteria Established | web-starter | Functional checklist and quality verification gates documented | [ ] | In acceptance-criteria.md |
"@
        }
        'it-infra-ops' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **01-server** | [`01-server/server-inventory.md`](01-server/server-inventory.md) | Physical & virtual node inventory, LAN IPs, and server roles |
| **04-operations** | [`04-operations/maintenance-sop.md`](04-operations/maintenance-sop.md) | Routine maintenance checklist, OS security patching, and log audit |
| **05-monitoring** | [`05-monitoring/incident-runbook.md`](05-monitoring/incident-runbook.md) | Severity matrix and emergency runbooks (disk full, CPU spike, DB lock) |
| **06-troubleshooting** | [`06-troubleshooting/change-management.md`](06-troubleshooting/change-management.md) | Maintenance window protocol, pre-flight checklist, and rollback procedures |
| **07-disaster-recovery** | [`07-disaster-recovery/backup-restore-sop.md`](07-disaster-recovery/backup-restore-sop.md) | 3-2-1 backup strategy, schedule, and quarterly restoration drills |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{INFRA_ENVIRONMENT}}` | it-infra-ops | Required | Infrastructure environment type | `{{INFRA_ENVIRONMENT}}` |
| `{{PRIMARY_OS}}` | it-infra-ops | Required | Primary server operating system | `{{PRIMARY_OS}}` |
| `{{MAINTENANCE_WINDOW}}` | it-infra-ops | Required | Official recurring maintenance window | `{{MAINTENANCE_WINDOW}}` |
| `{{BACKUP_DESTINATION}}` | it-infra-ops | Required | Target backup storage location | `{{BACKUP_DESTINATION}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| Server Inventory Mapped | it-infra-ops | Node specs, LAN IP allocation, and roles documented | [ ] | In server-inventory.md |
| Maintenance SOP & Runbooks Approved | it-infra-ops | Daily/monthly routines and incident escalation defined | [ ] | In maintenance-sop.md and incident-runbook.md |
| Change Protocol & DR Drills Verified | it-infra-ops | Rollback triggers and backup restoration drills tested | [ ] | In change-management.md and backup-restore-sop.md |
"@
        }
        'app-maintenance' {
            $IndexTable = @"
| Section | Document | Description |
|---|---|---|
| **00-overview** | [`00-overview/system-context-map.md`](00-overview/system-context-map.md) | Existing host system architecture, upstream boundaries, and code zoning |
| **02-application** | [`02-application/extension-guide.md`](02-application/extension-guide.md) | Custom module development standards, isolation rules, and schema extensions |
| **03-security** | [`03-security/upstream-compatibility.md`](03-security/upstream-compatibility.md) | Upstream compatibility policy, surgical patching, and dependency isolation |
| **06-troubleshooting** | [`06-troubleshooting/bug-triage-sop.md`](06-troubleshooting/bug-triage-sop.md) | 4-phase bug triage workflow, reproduction steps, and non-regression tests |
"@
            $VarsTable = @"
| Variable Name | Module | Status | Description | Instantiation Value |
|---|---|---|---|---|
| `{{HOST_APPLICATION}}` | app-maintenance | Required | Host/upstream application name and version | `{{HOST_APPLICATION}}` |
| `{{SOURCE_MODEL}}` | app-maintenance | Required | Code source model (Open Source / Closed Source) | `{{SOURCE_MODEL}}` |
| `{{PRIMARY_LANGUAGE}}` | app-maintenance | Required | Core programming language of the application | `{{PRIMARY_LANGUAGE}}` |
| `{{EXTENSION_PATTERN}}` | app-maintenance | Required | Permitted extension or integration pattern | `{{EXTENSION_PATTERN}}` |
"@
            $ReadinessTable = @"
| Check Item | Module | Requirement | Status | Evidence / Notes |
|---|---|---|---|---|
| System Context & Boundaries Mapped | app-maintenance | Host app version, no-touch core zones, and hooks identified | [ ] | In system-context-map.md |
| Extension Standards & Upstream Policy | app-maintenance | Module layout, schema rules, and patch strategies defined | [ ] | In extension-guide.md and upstream-compatibility.md |
| Bug Triage & Regression Checklist Ready | app-maintenance | 4-phase bug workflow and reproduction criteria established | [ ] | In bug-triage-sop.md |
"@
        }
    }

    # Stitch INDEX.md
    $indexPath = Join-Path $StagingDir "docs\INDEX.md"
    if (Test-Path $indexPath) {
        $indexContent = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
        $pattern = '(?s)<!-- MODULE_DOCS_START -->.*?<!-- MODULE_DOCS_END -->'
        $replacement = "<!-- MODULE_DOCS_START -->`n$IndexTable`n<!-- MODULE_DOCS_END -->"
        $newIndex = [System.Text.RegularExpressions.Regex]::Replace($indexContent, $pattern, $replacement)
        [System.IO.File]::WriteAllText($indexPath, $newIndex, [System.Text.Encoding]::UTF8)
    }

    # Stitch template-variables.md
    $varsPath = Join-Path $StagingDir "docs\08-reference\template-variables.md"
    if (Test-Path $varsPath) {
        $varsContent = [System.IO.File]::ReadAllText($varsPath, [System.Text.Encoding]::UTF8)
        $pattern = '(?s)<!-- MODULE_VARS_START -->.*?<!-- MODULE_VARS_END -->'
        $replacement = "<!-- MODULE_VARS_START -->`n$VarsTable`n<!-- MODULE_VARS_END -->"
        $newVars = [System.Text.RegularExpressions.Regex]::Replace($varsContent, $pattern, $replacement)
        [System.IO.File]::WriteAllText($varsPath, $newVars, [System.Text.Encoding]::UTF8)
    }

    # Stitch implementation-readiness.md
    $readinessPath = Join-Path $StagingDir "docs\09-governance\implementation-readiness.md"
    if (Test-Path $readinessPath) {
        $readinessContent = [System.IO.File]::ReadAllText($readinessPath, [System.Text.Encoding]::UTF8)
        $pattern = '(?s)<!-- MODULE_READINESS_START -->.*?<!-- MODULE_READINESS_END -->'
        $replacement = "<!-- MODULE_READINESS_START -->`n$ReadinessTable`n<!-- MODULE_READINESS_END -->"
        $newReadiness = [System.Text.RegularExpressions.Regex]::Replace($readinessContent, $pattern, $replacement)
        [System.IO.File]::WriteAllText($readinessPath, $newReadiness, [System.Text.Encoding]::UTF8)
    }

    # Interpolate PROJECT_NAME
    if (-not [string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "==> Interpolating project name: `"$Name`"" -ForegroundColor Cyan
        Get-ChildItem -Path $StagingDir -Filter "*.md" -Recurse | ForEach-Object {
            $text = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
            if ($text.Contains("{{PROJECT_NAME}}")) {
                $text = $text.Replace("{{PROJECT_NAME}}", $Name)
                [System.IO.File]::WriteAllText($_.FullName, $text, [System.Text.Encoding]::UTF8)
            }
        }
    }

    # Export Directory
    if ($Dir) {
        if (-not (Test-Path $Dir)) {
            New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        }
        $resolvedDir = (Resolve-Path $Dir).Path
        Copy-Item -Path "$StagingDir\*" -Destination $resolvedDir -Recurse -Force
        Write-Host "==> Exported assembled project to directory: $resolvedDir" -ForegroundColor Green
    }

    # Export Zip
    if ($Output) {
        $outParent = Split-Path -Parent $Output
        if ($outParent -and -not (Test-Path $outParent)) {
            New-Item -ItemType Directory -Path $outParent -Force | Out-Null
        }
        if (Test-Path $Output) {
            Remove-Item -Path $Output -Force
        }
        Compress-Archive -Path "$StagingDir\*" -DestinationPath $Output -Force
        Write-Host "==> Exported project bundle archive: $Output" -ForegroundColor Green
    }

    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  AI Harness Bundle Complete: $Module ($Lang)     " -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
}
finally {
    if (Test-Path $StagingDir) {
        Remove-Item -Path $StagingDir -Recurse -Force
    }
}
