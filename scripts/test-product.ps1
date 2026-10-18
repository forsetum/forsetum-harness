[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $root 'scripts/validate-harness.ps1') -All
if (-not $?) { throw 'Template validation failed' }
foreach ($test in @('test-build-skill','test-decision-handoff')) {
    & (Join-Path $root "skills/forsetum-harness/tests/$test.ps1")
    if (-not $?) { throw "$test failed" }
}
& (Join-Path $root 'scripts/test-compatibility.ps1')
if (-not $?) { throw 'Compatibility gate failed' }
Write-Output 'PASS: standalone native PowerShell product suite'
