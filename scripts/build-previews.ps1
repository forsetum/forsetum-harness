<#
.SYNOPSIS
    Builds static AI Harness preview packages (.zip) for free download tiers.

.DESCRIPTION
    Compiles web-starter template modules in both English and Indonesian,
    packaging them into dist/previews/ ready to be served or distributed.
#>
[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$OutputDir = Join-Path $RepoRoot "dist\previews"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Building Static AI Harness Preview Bundles      " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$BundleScript = Join-Path $ScriptDir "bundle.ps1"

# 1. English Web Starter
Write-Host "==> Building English Web Starter preview..." -ForegroundColor Yellow
$enZip = Join-Path $OutputDir "web-starter-en.zip"
& $BundleScript -Lang "en" -Module "web-starter" -Output $enZip

# 2. Indonesian Web Starter
Write-Host ""
Write-Host "==> Building Indonesian Web Starter preview..." -ForegroundColor Yellow
$idZip = Join-Path $OutputDir "web-starter-id.zip"
& $BundleScript -Lang "id" -Module "web-starter" -Output $idZip

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "  Preview Bundles Built Successfully!             " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Get-ChildItem -Path $OutputDir -Filter "*.zip" | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
