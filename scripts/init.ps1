<#
.SYNOPSIS
    Cross-platform AI Harness Scaffolding CLI for Windows PowerShell and PowerShell Core.

.DESCRIPTION
    Scaffolds an AI Agent Harness for a new or existing project by copying documentation
    templates (id or en), setting up validation scripts, and optionally interpolating {{PROJECT_NAME}}.

.PARAMETER Lang
    Template language ('id' for Indonesian, 'en' for English). Default: en.

.PARAMETER Module
    Domain module declared by template/<lang>/manifest.json. Default: web-fullstack.

.PARAMETER Target
    Target project directory. Default: . (current directory).

.PARAMETER Name
    Project name (interpolates {{PROJECT_NAME}} across scaffolded files).

.PARAMETER Force
    Overwrites existing harness files in the target directory.

.EXAMPLE
    .\scripts\init.ps1
    .\scripts\init.ps1 -Lang en -Module landing-page -Target C:\Projects\my-lp -Name "My Landing Page"
    .\scripts\init.ps1 -Lang id -Target .\backend -Name "Layanan Pembayaran"
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet('id', 'en')]
    [string]$Lang = 'en',

    [Parameter()]
    [string]$Module = 'web-fullstack',

    [Parameter()]
    [string]$Target = '.',

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

# Interactive wizard when invoked without explicit arguments in an interactive host
if ($PSBoundParameters.Count -eq 0 -and [Environment]::UserInteractive) {
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  AI Harness Scaffolding Wizard                   " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select template language:"
    Write-Host "  1) English (en) [default]"
    Write-Host "  2) Bahasa Indonesia (id)"
    $langChoice = Read-Host "Choose [1/2, default: 1]"
    if ($langChoice -eq '2' -or $langChoice -eq 'id' -or $langChoice -eq 'ID') {
        $Lang = 'id'
    } else {
        $Lang = 'en'
    }

    $coreCheck = Join-Path $RepoRoot "template\$Lang\core"
    if (Test-Path $coreCheck) {
        $interactiveManifestPath = Join-Path $RepoRoot "template\$Lang\manifest.json"
        $interactiveManifest = Get-Content -LiteralPath $interactiveManifestPath -Raw | ConvertFrom-Json
        $CatalogModuleIds = @($interactiveManifest.modules.PSObject.Properties | ForEach-Object { $_.Name })
        Write-Host ""
        Write-Host "Select domain module:"
        for ($catalogIndex = 0; $catalogIndex -lt $CatalogModuleIds.Count; $catalogIndex++) {
            $suffix = if ($catalogIndex -eq 0) { ' [default]' } else { '' }
            Write-Host (" {0,2}) {1}{2}" -f ($catalogIndex + 1), $CatalogModuleIds[$catalogIndex], $suffix)
        }
        $modChoice = Read-Host "Choose [1-$($CatalogModuleIds.Count), default: 1]"
        $parsedIndex = 0
        $selectedIndex = 0
        if ([int]::TryParse($modChoice, [ref]$parsedIndex) -and $parsedIndex -ge 1 -and $parsedIndex -le $CatalogModuleIds.Count) {
            $selectedIndex = $parsedIndex - 1
        } elseif ($CatalogModuleIds -contains $modChoice) {
            $selectedIndex = [Array]::IndexOf([string[]]$CatalogModuleIds, [string]$modChoice)
        }
        $Module = $CatalogModuleIds[$selectedIndex]
    }

    $targetChoice = Read-Host "Target directory [default: .]"
    if (-not [string]::IsNullOrWhiteSpace($targetChoice)) {
        $Target = $targetChoice
    }

    $nameChoice = Read-Host 'Project name (optional, e.g. "My Project")'
    if (-not [string]::IsNullOrWhiteSpace($nameChoice)) {
        $Name = $nameChoice
    }

    Write-Host ""
    Write-Host "Configuration Summary:" -ForegroundColor Yellow
    Write-Host "  Language:     $Lang"
    Write-Host "  Module:       $Module"
    Write-Host "  Target Dir:   $Target"
    Write-Host "  Project Name: $(if ($Name) { $Name } else { '<not set>' })"
    $confirm = Read-Host "Proceed with scaffolding? [Y/n]"
    if ($confirm -match '^(n|N)') {
        Write-Host "Operation aborted by user." -ForegroundColor Yellow
        exit 0
    }
}

$TemplateDir = Join-Path $RepoRoot "template\$Lang"
if (-not (Test-Path $TemplateDir)) {
    Write-Error "Template directory not found: $TemplateDir"
    exit 1
}

$ManifestPath = Join-Path $TemplateDir 'manifest.json'
if (-not (Test-Path $ManifestPath)) {
    Write-Error "Manifest not found: $ManifestPath"
    exit 1
}
$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$CatalogModuleIds = @($Manifest.modules.PSObject.Properties | ForEach-Object { $_.Name })
if ($CatalogModuleIds -notcontains $Module) {
    Write-Error "Module is not declared in ${ManifestPath}: $Module"
    exit 2
}

# Resolve and ensure target directory
if (-not (Test-Path $Target)) {
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
}
$ResolvedTarget = (Resolve-Path $Target).Path

# Check existing harness files
if (-not $Force) {
    $existingAgents = Join-Path $ResolvedTarget "AGENTS.md"
    $existingDocs = Join-Path $ResolvedTarget "docs"
    if ((Test-Path $existingAgents) -or (Test-Path $existingDocs)) {
        Write-Error "Target directory already contains AI Harness files ($ResolvedTarget). Use -Force to overwrite."
        exit 1
    }
}

$coreDir = Join-Path $TemplateDir "core"
if (Test-Path $coreDir) {
    Write-Host "==> Bundling modular AI Harness ($Lang / $Module) into: $ResolvedTarget" -ForegroundColor Cyan
    $bundleScript = Join-Path $ScriptDir "bundle.ps1"
    & $bundleScript -Lang $Lang -Module $Module -Name $Name -Dir $ResolvedTarget
} else {
    Write-Host "==> Scaffolding legacy AI Harness ($Lang) into: $ResolvedTarget" -ForegroundColor Cyan
    Copy-Item -Path "$TemplateDir\*" -Destination $ResolvedTarget -Recurse -Force

    $targetScriptsDir = Join-Path $ResolvedTarget "scripts"
    if (-not (Test-Path $targetScriptsDir)) {
        New-Item -ItemType Directory -Path $targetScriptsDir -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $RepoRoot "scripts\validate-harness.sh") -Destination (Join-Path $targetScriptsDir "validate-harness.sh") -Force
    Copy-Item -Path (Join-Path $RepoRoot "scripts\validate-harness.ps1") -Destination (Join-Path $targetScriptsDir "validate-harness.ps1") -Force
    Copy-Item -Path (Join-Path $RepoRoot "scripts\validate-template.sh") -Destination (Join-Path $targetScriptsDir "validate-template.sh") -Force
    Copy-Item -Path (Join-Path $RepoRoot "scripts\validate-template.ps1") -Destination (Join-Path $targetScriptsDir "validate-template.ps1") -Force

    if (-not [string]::IsNullOrWhiteSpace($Name)) {
        Get-ChildItem -Path $ResolvedTarget -Filter "*.md" -Recurse | ForEach-Object {
            $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
            if ($content.Contains("{{PROJECT_NAME}}")) {
                $updated = $content.Replace("{{PROJECT_NAME}}", $Name)
                [System.IO.File]::WriteAllText($_.FullName, $updated, [System.Text.Encoding]::UTF8)
            }
        }
    }
}

Write-Host ""
if ($Lang -eq 'id') {
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  Inisialisasi AI Harness Berhasil!               " -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "Direktori tujuan: $ResolvedTarget"
    Write-Host "Bahasa template:  Bahasa Indonesia (id)"
    Write-Host "Modul domain:     $Module"
    Write-Host ""
    Write-Host "Langkah Selanjutnya (Next Steps):" -ForegroundColor Yellow
    Write-Host "  1. Buka dan pelajari AGENTS.md dan README.md di direktori proyek."
    Write-Host "  2. Jalankan validasi struktur template:"
    Write-Host "     .\scripts\validate-harness.ps1"
    Write-Host "  3. Mulai fase Instantiation and Discovery bersama Agen AI:
     - Lengkapi docs/08-reference/template-variables.md
     - Catat keputusan arsitektur di docs/08-reference/decision-register.md
     - Jalankan .\scripts\validate-harness.ps1 secara berkala untuk memantau kesiapan."
    Write-Host "==================================================" -ForegroundColor Green
} else {
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  AI Harness Initialization Succeeded!            " -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "Target directory:  $ResolvedTarget"
    Write-Host "Template language: English (en)"
    Write-Host "Domain module:     $Module"
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Review AGENTS.md and README.md in your project directory."
    Write-Host "  2. Run the template harness validation:"
    Write-Host "     .\scripts\validate-harness.ps1"
    Write-Host "  3. Begin the Instantiation and Discovery phase with your AI agent:
     - Define project requirements and fill out docs/08-reference/template-variables.md
     - Record architectural decisions in docs/08-reference/decision-register.md
     - Run .\scripts\validate-harness.ps1 regularly to track implementation readiness."
    Write-Host "==================================================" -ForegroundColor Green
}
