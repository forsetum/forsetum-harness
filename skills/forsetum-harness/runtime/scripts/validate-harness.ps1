<#
.SYNOPSIS
    Cross-platform AI Harness Template Validator for Windows PowerShell and PowerShell Core.

.DESCRIPTION
    Validates template file presence, internal relative markdown links,
    placeholder registrations in template-variables.md, modular manifest integrity,
    and root repository harness readiness.

.PARAMETER All
    Validates template/id, template/en (modular), and root repository harness (default).

.PARAMETER Template
    Validates a specific template directory ('id' or 'en').

.PARAMETER Root
    Validates the root repository documentation and links.

.PARAMETER Target
    Validates an external project directory.

.PARAMETER Mode
    Validation mode for target directory ('source' or 'instantiated'). Default is 'source'.

.EXAMPLE
    .\scripts\validate-harness.ps1 -All
    .\scripts\validate-harness.ps1 -Template id
    .\scripts\validate-harness.ps1 -Template en
    .\scripts\validate-harness.ps1 -Root
#>

[CmdletBinding(DefaultParameterSetName = 'All')]
param (
    [Parameter(ParameterSetName = 'All')]
    [switch]$All,

    [Parameter(ParameterSetName = 'Template')]
    [ValidateSet('id', 'en')]
    [string]$Template,

    [Parameter(ParameterSetName = 'Root')]
    [switch]$Root,

    [Parameter(ParameterSetName = 'Target')]
    [string]$Target,

    [Parameter(ParameterSetName = 'Target')]
    [ValidateSet('source', 'instantiated')]
    [string]$Mode = 'source'
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$RequiredFiles = @(
    "AGENTS.md",
    "README.md",
    "backlog.md",
    "docs/INDEX.md",
    "docs/00-overview/prd.md",
    "docs/00-overview/business-flow.md",
    "docs/00-overview/architecture.md",
    "docs/01-server/provisioning-specs.md",
    "docs/02-application/application-guide.md",
    "docs/02-application/backend-api-guide.md",
    "docs/03-security/security-model.md",
    "docs/04-operations/deployment-checklist.md",
    "docs/05-monitoring/monitoring-guide.md",
    "docs/06-troubleshooting/troubleshooting-guide.md",
    "docs/07-disaster-recovery/disaster-recovery.md",
    "docs/08-reference/configuration-reference.md",
    "docs/08-reference/decision-register.md",
    "docs/08-reference/glossary.md",
    "docs/08-reference/template-variables.md",
    "docs/09-governance/acceptance-criteria.md",
    "docs/09-governance/docs-maintenance-guide.md",
    "docs/09-governance/implementation-readiness.md",
    "docs/09-governance/template-quality-checklist.md",
    "docs/09-governance/testing-strategy.md"
)

$CoreProjectFiles = @(
    "AGENTS.md",
    "README.md",
    "QUICKSTART.md",
    "backlog.md",
    "docs/INDEX.md",
    "docs/08-reference/decision-register.md",
    "docs/08-reference/template-variables.md",
    "docs/09-governance/implementation-readiness.md"
)

function Test-TemplateFiles {
    param ([string]$Dir)
    Write-Host "==> Checking required files in: $Dir" -ForegroundColor Cyan
    $missing = 0

    $isMonolithic = Test-Path (Join-Path $Dir "docs/00-overview/prd.md")
    $fileList = if ($isMonolithic) { $RequiredFiles } else { $CoreProjectFiles }

    foreach ($rel in $fileList) {
        $p = Join-Path $Dir $rel
        if (-not (Test-Path $p) -or (Get-Item $p).Length -eq 0) {
            Write-Host "  [FAIL] Missing or empty: $rel" -ForegroundColor Red
            $missing++
        }
    }
    if ($missing -gt 0) {
        Write-Error "$missing required file(s) missing in $Dir"
        return $false
    }
    Write-Host "  [PASS] All required files present and non-empty." -ForegroundColor Green
    return $true
}

function Test-TemplateLinks {
    param ([string]$Dir)
    Write-Host "==> Validating markdown links in: $Dir" -ForegroundColor Cyan
    $bad = 0
    $mdFiles = Get-ChildItem -Path $Dir -Filter "*.md" -Recurse

    foreach ($file in $mdFiles) {
        $content = Get-Content -Path $file.FullName -Raw
        $matches = [System.Text.RegularExpressions.Regex]::Matches($content, '\]\(([^)]+)\)')

        foreach ($m in $matches) {
            $rawTarget = $m.Groups[1].Value.Trim()
            if ([string]::IsNullOrWhiteSpace($rawTarget) -or
                $rawTarget.StartsWith("http://") -or
                $rawTarget.StartsWith("https://") -or
                $rawTarget.StartsWith("mailto:") -or
                $rawTarget.StartsWith("file://") -or
                $rawTarget.StartsWith("#")) {
                continue
            }

            $targetPath = $rawTarget.Split('#')[0]
            if ([string]::IsNullOrWhiteSpace($targetPath)) { continue }

            $resolved = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $file.FullName) $targetPath))
            if (-not (Test-Path $resolved)) {
                $rootResolved = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $targetPath))
                $coreResolved = $resolved -replace '([\\/]+)modules[\\/]+[^\\/]+([\\/]+)', '$1core$2'
                if (-not (Test-Path $rootResolved) -and -not (Test-Path $coreResolved)) {
                    Write-Host "  [FAIL] Broken link in $($file.Name): `"$rawTarget`"" -ForegroundColor Red
                    $bad++
                }
            }
        }
    }

    if ($bad -gt 0) {
        Write-Error "Found $bad broken link(s) in $Dir"
        return $false
    }
    Write-Host "  [PASS] All markdown links are valid." -ForegroundColor Green
    return $true
}

function Test-TemplatePlaceholders {
    param ([string]$Dir)
    Write-Host "==> Validating placeholder registrations in: $Dir" -ForegroundColor Cyan

    $regFile = Join-Path $Dir "docs/08-reference/template-variables.md"
    $coreRegFile = Join-Path $Dir "core/docs/08-reference/template-variables.md"
    $manifestPath = Join-Path $Dir "manifest.json"

    $regContent = if (Test-Path $regFile) { Get-Content -Path $regFile -Raw } else { "" }
    $coreRegContent = if (Test-Path $coreRegFile) { Get-Content -Path $coreRegFile -Raw } else { "" }
    $manifestContent = if (Test-Path $manifestPath) { Get-Content -Path $manifestPath -Raw } else { "" }

    $moduleRegContent = ""
    $modulesDir = Join-Path $Dir "modules"
    if (Test-Path $modulesDir) {
        $moduleRegs = Get-ChildItem -Path $modulesDir -Filter "template-variables.md" -Recurse -File
        foreach ($m in $moduleRegs) {
            $moduleRegContent += "`n" + (Get-Content -Path $m.FullName -Raw)
        }
    }

    $unregistered = 0
    $mdFiles = Get-ChildItem -Path $Dir -Filter "*.md" -Recurse

    $placeholders = @{}
    foreach ($f in $mdFiles) {
        $text = Get-Content -Path $f.FullName -Raw
        $found = [System.Text.RegularExpressions.Regex]::Matches($text, '\{\{[A-Z0-9_]+\}\}')
        foreach ($item in $found) {
            $val = $item.Value
            if ($val -in @('{{YEAR}}', '{{TIMESTAMP}}', '{{HASH}}', '{{RELEVANT_TOPIC}}', '{{DATE}}')) { continue }
            $placeholders[$val] = $true
        }
    }

    foreach ($ph in $placeholders.Keys) {
        $variableName = $ph -replace '^\{\{|\}\}$', ''
        $found = ($regContent.Contains($variableName)) -or ($coreRegContent.Contains($variableName)) -or ($manifestContent.Contains($variableName)) -or ($moduleRegContent.Contains($variableName))
        if (-not $found) {
            Write-Host "  [FAIL] Unregistered placeholder: $ph in $Dir" -ForegroundColor Red
            $unregistered++
        }
    }

    if ($unregistered -gt 0) {
        Write-Error "$unregistered unregistered placeholder(s) found in $Dir"
        return $false
    }
    Write-Host "  [PASS] All placeholders are registered." -ForegroundColor Green
    return $true
}

function Get-ManifestShape {
    param ([object]$Value)

    if ($null -eq $Value) { return 'null' }
    if ($Value -is [string] -or $Value -is [ValueType]) { return 'scalar' }
    if ($Value -is [System.Array]) {
        $items = @($Value | ForEach-Object { Get-ManifestShape -Value $_ })
        return "array[$($items -join ',')]"
    }

    $properties = @($Value.PSObject.Properties | Sort-Object Name)
    $parts = @($properties | ForEach-Object {
        "$($_.Name)=$(Get-ManifestShape -Value $_.Value)"
    })
    return "object{$($parts -join ',')}"
}

function Test-ManifestModule {
    param (
        [object]$Manifest,
        [string]$Language,
        [string]$ModuleId
    )

    $entryProperty = $Manifest.modules.PSObject.Properties[$ModuleId]
    if ($null -eq $entryProperty) {
        Write-Host "  [FAIL] Module is missing from $Language manifest: $ModuleId" -ForegroundColor Red
        return $false
    }

    $entry = $entryProperty.Value
    $required = @('category', 'variables', 'persona', 'interview_phases', 'domain_guardrails', 'readiness_checks', 'directory')
    $ok = $true
    foreach ($field in $required) {
        if ($null -eq $entry.PSObject.Properties[$field]) {
            Write-Host "  [FAIL] Module $ModuleId is missing manifest field: $field" -ForegroundColor Red
            $ok = $false
        }
    }

    if ($null -ne $entry.PSObject.Properties['tier']) {
        Write-Host "  [FAIL] Module $ModuleId contains unsupported commercial tier metadata" -ForegroundColor Red
        $ok = $false
    }

    foreach ($field in @('variables', 'interview_phases', 'domain_guardrails', 'readiness_checks')) {
        $property = $entry.PSObject.Properties[$field]
        if ($null -ne $property -and $property.Value -isnot [System.Array]) {
            Write-Host "  [FAIL] Module $ModuleId field is not an array: $field" -ForegroundColor Red
            $ok = $false
        }
    }

    $persona = $entry.PSObject.Properties['persona']
    if ($null -ne $persona -and ($persona.Value -is [string] -or $persona.Value -is [ValueType] -or $persona.Value -is [System.Array])) {
        Write-Host "  [FAIL] Module $ModuleId field is not an object: persona" -ForegroundColor Red
        $ok = $false
    }

    $directory = $entry.PSObject.Properties['directory']
    $expectedDirectory = "modules/$ModuleId"
    if ($null -ne $directory -and $directory.Value -ne $expectedDirectory) {
        Write-Host "  [FAIL] Module $ModuleId directory does not match $expectedDirectory" -ForegroundColor Red
        $ok = $false
    }
    return $ok
}

function Test-ManifestCatalog {
    $enPath = Join-Path $RepoRoot 'template/en/manifest.json'
    $idPath = Join-Path $RepoRoot 'template/id/manifest.json'
    if (-not (Test-Path $enPath) -or -not (Test-Path $idPath)) {
        Write-Error 'Both EN and ID manifests are required for canonical catalog validation.'
        return $false
    }

    try {
        $enManifest = Get-Content -Path $enPath -Raw | ConvertFrom-Json
        $idManifest = Get-Content -Path $idPath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Error "Manifest JSON parsing failed: $_"
        return $false
    }

    $enIds = @($enManifest.modules.PSObject.Properties.Name | Sort-Object)
    $idIds = @($idManifest.modules.PSObject.Properties.Name | Sort-Object)
    $ok = $true
    $parity = Compare-Object -ReferenceObject $enIds -DifferenceObject $idIds
    if ($null -ne $parity) {
        Write-Host '  [FAIL] EN and ID manifest module keys differ:' -ForegroundColor Red
        $parity | ForEach-Object { Write-Host "    $($_.SideIndicator) $($_.InputObject)" -ForegroundColor Red }
        $ok = $false
    }

    foreach ($moduleId in $enIds) {
        if (-not (Test-ManifestModule -Manifest $enManifest -Language 'en' -ModuleId $moduleId)) { $ok = $false }
        if (-not (Test-ManifestModule -Manifest $idManifest -Language 'id' -ModuleId $moduleId)) { $ok = $false }

        $enEntry = $enManifest.modules.PSObject.Properties[$moduleId].Value
        $idEntry = $idManifest.modules.PSObject.Properties[$moduleId].Value
        if ((Get-ManifestShape -Value $enEntry) -ne (Get-ManifestShape -Value $idEntry)) {
            Write-Host "  [FAIL] EN and ID manifest structural shapes differ: $moduleId" -ForegroundColor Red
            $ok = $false
        }
    }

    foreach ($language in @('en', 'id')) {
        $modulesPath = Join-Path $RepoRoot "template/$language/modules"
        $directoryIds = @((Get-ChildItem -Path $modulesPath -Directory | Select-Object -ExpandProperty Name | Sort-Object))
        if ($language -eq 'en') {
            $manifestDirectories = @($enIds | Sort-Object)
        } else {
            $manifestDirectories = @($idIds | Sort-Object)
        }
        $directoryParity = Compare-Object -ReferenceObject $manifestDirectories -DifferenceObject $directoryIds
        if ($null -ne $directoryParity) {
            Write-Host "  [FAIL] Manifest-to-directory parity failed for template/$language" -ForegroundColor Red
            $directoryParity | ForEach-Object { Write-Host "    $($_.SideIndicator) $($_.InputObject)" -ForegroundColor Red }
            $ok = $false
        }
    }

    if (-not $ok) {
        Write-Error 'Canonical manifest catalog validation failed.'
        return $false
    }
    Write-Host "  [PASS] EN/ID manifests and module directories contain $($enIds.Count) canonical modules with equal structural shapes." -ForegroundColor Green
    return $true
}

function Test-ModularTemplate {
    param ([string]$Dir)
    Write-Host "==> Validating modular template library in: $Dir" -ForegroundColor Cyan
    $manifestPath = Join-Path $Dir "manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-Error "Missing manifest.json in $Dir"
        return $false
    }
    Write-Host "  [PASS] manifest.json present and readable." -ForegroundColor Green

    $coreDir = Join-Path $Dir "core"
    $modulesDir = Join-Path $Dir "modules"

    $coreOk = (Test-TemplateFiles -Dir $coreDir)
    $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $mods = @($manifest.modules.PSObject.Properties.Name | Sort-Object)
    $modsOk = $true
    foreach ($m in $mods) {
        $mp = Join-Path $modulesDir $m
        if (-not (Test-Path $mp)) {
            Write-Host "  [FAIL] Missing module directory: $m" -ForegroundColor Red
            $modsOk = $false
        } elseif (@(Get-ChildItem -Path $mp -Filter '*.md' -Recurse -File).Count -eq 0) {
            Write-Host "  [FAIL] Module has no documentation files: $m" -ForegroundColor Red
            $modsOk = $false
        }
    }

    $linksOk = (Test-TemplateLinks -Dir $coreDir)
    foreach ($m in $mods) {
        $mp = Join-Path $modulesDir $m
        if (Test-Path $mp) {
            $l = (Test-TemplateLinks -Dir $mp)
            if (-not $l) { $linksOk = $false }
        }
    }

    $phOk = (Test-TemplatePlaceholders -Dir $Dir)

    return ($coreOk -and $modsOk -and $linksOk -and $phOk)
}

function Test-RootHarness {
    Write-Host "==> Validating root repository harness..." -ForegroundColor Cyan
    $docsDir = Join-Path $RepoRoot "docs"
    $ok = Test-TemplateLinks -Dir $docsDir

    $readinessFile = Join-Path $RepoRoot "docs/09-governance/implementation-readiness.md"
    if (Test-Path $readinessFile) {
        $content = Get-Content $readinessFile -Raw
        if ($content -notmatch "READY_FOR_IMPLEMENTATION") {
            Write-Host "  [FAIL] Root implementation-readiness.md is not set to READY_FOR_IMPLEMENTATION" -ForegroundColor Red
            $ok = $false
        }
    }

    if (-not $ok) {
        Write-Error "Root harness validation failed."
        return $false
    }
    Write-Host "  [PASS] Root repository harness is valid and ready." -ForegroundColor Green
    return $true
}

# Main routing logic
try {
    if ($All -or ($PSCmdlet.ParameterSetName -eq 'All')) {
        if (-not (Test-Path (Join-Path $RepoRoot "template")) -and (Test-Path (Join-Path $RepoRoot "AGENTS.md"))) {
            Write-Host "==================================================" -ForegroundColor Yellow
            Write-Host "  AI Harness Project Validation                   " -ForegroundColor Yellow
            Write-Host "==================================================" -ForegroundColor Yellow
            $pass = (Test-TemplateFiles -Dir $RepoRoot) -and (Test-TemplatePlaceholders -Dir $RepoRoot) -and (Test-TemplateLinks -Dir $RepoRoot)
            if (-not $pass) { exit 1 }
            Write-Host "==================================================" -ForegroundColor Green
            Write-Host "  SUCCESS: Project harness checks passed!         " -ForegroundColor Green
            Write-Host "==================================================" -ForegroundColor Green
        }
        else {
            Write-Host "==================================================" -ForegroundColor Yellow
            Write-Host "  AI Harness Template Suite Validation (All)     " -ForegroundColor Yellow
            Write-Host "==================================================" -ForegroundColor Yellow

            $idPath = Join-Path $RepoRoot "template/id"
            $enPath = Join-Path $RepoRoot "template/en"

            $catalogPass = Test-ManifestCatalog
            $pass1 = $catalogPass -and (Test-ModularTemplate -Dir $idPath)
            Write-Host ""
            $pass2 = $catalogPass -and (Test-ModularTemplate -Dir $enPath)
            Write-Host ""
            $pass3 = Test-RootHarness

            if (-not ($pass1 -and $pass2 -and $pass3)) {
                exit 1
            }
            Write-Host "==================================================" -ForegroundColor Green
            Write-Host "  SUCCESS: All template and root checks passed!   " -ForegroundColor Green
            Write-Host "==================================================" -ForegroundColor Green
        }
    }
    elseif ($Template) {
        if ($Template -eq 'en') {
            $pass = (Test-ManifestCatalog) -and (Test-ModularTemplate -Dir (Join-Path $RepoRoot "template/en"))
            if (-not $pass) { exit 1 }
            Write-Host "SUCCESS: Template en is valid!" -ForegroundColor Green
        } elseif ($Template -eq 'id') {
            $pass = (Test-ManifestCatalog) -and (Test-ModularTemplate -Dir (Join-Path $RepoRoot "template/id"))
            if (-not $pass) { exit 1 }
            Write-Host "SUCCESS: Template id is valid!" -ForegroundColor Green
        }
    }
    elseif ($Root) {
        if (-not (Test-RootHarness)) { exit 1 }
        Write-Host "SUCCESS: Root harness is valid!" -ForegroundColor Green
    }
    elseif ($Target) {
        if (-not (Test-Path $Target)) {
            Write-Error "Target directory does not exist: $Target"
            exit 1
        }
        $pass = (Test-TemplateFiles -Dir $Target) -and (Test-TemplateLinks -Dir $Target)
        if (-not $pass) { exit 1 }
        Write-Host "SUCCESS: Target directory validated!" -ForegroundColor Green
    }
}
catch {
    Write-Error $_
    exit 1
}
