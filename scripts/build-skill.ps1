<# Build one self-contained skill from canonical product sources. #>
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
if ([string]::IsNullOrWhiteSpace($Output) -or $Output -match '[\\/]$' -or (Split-Path -Leaf $Output) -in @('.','..')) { throw 'Output must name a new directory' }
$destination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Output)
$parent = Split-Path -Parent $destination
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw 'Output parent must already exist' }
if (Get-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue) { throw 'Output already exists; choose a new directory' }
$check = Get-Item -LiteralPath $parent -Force
while ($null -ne $check) {
    if (($check.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Output parent must not contain symlinks or junctions' }
    $check = $check.Parent
}
foreach ($protected in @('template','scripts','skills','.git')) {
    $prefix = (Join-Path $root $protected).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    if (($destination + [IO.Path]::DirectorySeparatorChar).StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Output must not be inside product sources' }
}
$skill = Join-Path $root 'skills/forsetum-harness'
foreach ($source in @((Join-Path $root 'template'),(Join-Path $skill 'scripts'),(Join-Path $skill 'adapters'),(Join-Path $skill 'references'),(Join-Path $skill 'agents'))) {
    if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw "Missing package source: $source" }
    foreach ($item in (@((Get-Item -LiteralPath $source -Force)) + @(Get-ChildItem -LiteralPath $source -Recurse -Force))) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Symlinks are not package sources: $($item.FullName)" }
    }
}
$entry = Get-Item -LiteralPath (Join-Path $skill 'SKILL.md') -Force
if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'SKILL.md must be a regular file' }
$work = Join-Path $parent ('.forsetum-build.' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $work | Out-Null
    Copy-Item -LiteralPath $entry.FullName -Destination (Join-Path $work 'SKILL.md')
    foreach ($dir in @('agents','adapters','references','scripts')) { Copy-Item -LiteralPath (Join-Path $skill $dir) -Destination (Join-Path $work $dir) -Recurse }
    New-Item -ItemType Directory -Path (Join-Path $work 'runtime/scripts') | Out-Null
    foreach ($name in @('init','bundle','validate-harness','validate-template')) {
        foreach ($ext in @('sh','ps1')) {
            $file = Get-Item -LiteralPath (Join-Path $root "scripts/$name.$ext") -Force
            if (($file.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Canonical scripts must be regular files' }
            Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $work 'runtime/scripts')
        }
    }
    Copy-Item -LiteralPath (Join-Path $root 'template') -Destination (Join-Path $work 'runtime/template') -Recurse
    if (@(Get-ChildItem -LiteralPath $work -Recurse -Force -File -Filter SKILL.md).Count -ne 1) { throw 'Package must contain exactly one SKILL.md' }
    New-Item -ItemType Directory -Path $destination | Out-Null
    Get-ChildItem -LiteralPath $work -Force | Copy-Item -Destination $destination -Recurse
    Write-Output "PASS: built installable skill: $destination"
} finally {
    if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force }
}
