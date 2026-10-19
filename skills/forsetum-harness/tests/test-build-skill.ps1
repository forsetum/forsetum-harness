[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$work = Join-Path ([IO.Path]::GetTempPath()) ('forsetum builder ' + [guid]::NewGuid().ToString('N'))
function Assert([bool]$Condition, [string]$Message) { if (-not $Condition) { throw "FAIL: $Message" } }
function Reject([string]$Path) {
    $rejected = $false
    try { & (Join-Path $root 'scripts/build-skill.ps1') -Output $Path | Out-Null } catch { $rejected = $true }
    Assert $rejected "unsafe output accepted: $Path"
}
try {
    New-Item -ItemType Directory -Path $work | Out-Null
    $installed = Join-Path $work 'installed skill'
    Push-Location ([IO.Path]::GetTempPath())
    try { & (Join-Path $root 'scripts/build-skill.ps1') -Output $installed } finally { Pop-Location }
    Assert (@(Get-ChildItem -LiteralPath $installed -Recurse -File -Filter SKILL.md).Count -eq 1) 'one discoverable entrypoint required'
    foreach ($name in @('init','bundle','validate-harness','validate-template')) {
        foreach ($ext in @('sh','ps1')) {
            Assert ((Get-FileHash -LiteralPath (Join-Path $root "scripts/$name.$ext")).Hash -eq (Get-FileHash -LiteralPath (Join-Path $installed "runtime/scripts/$name.$ext")).Hash) "runtime drift: $name.$ext"
        }
    }
    Push-Location $work
    try { & (Join-Path $root 'scripts/build-skill.ps1') -Output 'relative skill' } finally { Pop-Location }
    Assert (Test-Path -LiteralPath (Join-Path $work 'relative skill/SKILL.md')) 'relative output ignored caller location'
    Set-Content -LiteralPath (Join-Path $installed 'sentinel') -Value 'sentinel'
    Reject $installed
    Assert ((Get-Content -LiteralPath (Join-Path $installed 'sentinel') -Raw).Trim() -eq 'sentinel') 'existing output changed'
    Reject $root
    Reject ([IO.Path]::GetPathRoot($root))
    Reject (Join-Path $root 'template/new-package')
    Reject (Join-Path $root 'skills/forsetum-harness/new-package')
    Reject (Join-Path $work 'missing/child')
    Reject (Join-Path $work 'unused/..')
    # Windows junctions do not need the symbolic-link privilege.
    if ($env:OS -eq 'Windows_NT') {
        $real = Join-Path $work 'real'
        New-Item -ItemType Directory -Path $real | Out-Null
        $link = Join-Path $work 'link'
        New-Item -ItemType Junction -Path $link -Target $real | Out-Null
        try {
            Reject (Join-Path $link 'package')
            Assert (-not (Test-Path -LiteralPath (Join-Path $real 'package'))) 'junction output mutated destination'
        } finally { [IO.Directory]::Delete($link) }
    }
    Write-Output 'PASS: native PowerShell create-only package build and path safety'
} finally { if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force } }
