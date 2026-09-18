<#!
.SYNOPSIS
    PowerShell-native adoption decision handoff.

.DESCRIPTION
    Enforces the same exact-target, per-conflict, and backup-before-mutation
    contract as decision-handoff.sh. It never invokes Bash.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('CANCEL', 'DEFER', 'PRESERVE', 'SKIP', 'APPROVE_REPLACE_WITH_BACKUP')]
    [string]$Decision,

    [Parameter(Mandatory = $true)]
    [string]$Target,

    [Parameter(Mandatory = $true)]
    [ValidateSet('id', 'en')]
    [string]$Lang,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9-]*$')]
    [string]$Module,

    [Parameter(Mandatory = $true)]
    [string]$Initializer,

    [Parameter(Mandatory = $true)]
    [string]$Validator,

    [string]$PreviewFingerprint,
    [string[]]$Conflict = @(),
    [string[]]$BackupMapping = @(),
    [string[]]$RollbackMapping = @(),
    [ValidateSet('YES', 'NO')]
    [string]$GitignoreDecision
)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    throw "ERROR: $Message"
}

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    Fail "target directory does not exist: $Target"
}
if (-not (Test-Path -LiteralPath $Initializer -PathType Leaf)) {
    Fail "initializer command is not available: $Initializer"
}
if (-not (Test-Path -LiteralPath $Validator -PathType Leaf)) {
    Fail "validator command is not available: $Validator"
}

$targetName = Split-Path -Leaf ((Resolve-Path -LiteralPath $Target).Path.TrimEnd('\', '/'))

if ($Decision -eq 'CANCEL') {
    Write-Output "State: CANCELLED"
    Write-Output 'Mutation: none'
    Write-Output 'Target: unchanged'
    exit 0
}
if ($Decision -in @('DEFER', 'PRESERVE', 'SKIP')) {
    Write-Output 'State: DEFERRED'
    Write-Output 'Mutation: none'
    Write-Output 'Target: unchanged'
    exit 0
}

function Is-SafeRelativePath([string]$Path) {
    return -not ([IO.Path]::IsPathRooted($Path) -or $Path -match '(^|[\/])\.\.([\/]|$)' -or $Path -match '[\\/]\\[\\/]')
}

function Parse-Pair([string]$Value, [string]$Option) {
    $index = $Value.IndexOf('=')
    if ($index -lt 1 -or $index -eq ($Value.Length - 1)) {
        Fail "$Option requires path=value"
    }
    return @($Value.Substring(0, $index), $Value.Substring($index + 1))
}

function Get-PathSnapshot([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return @('file', (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant())
    }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Fail "path is missing: $Path"
    }
    $root = (Resolve-Path -LiteralPath $Path).Path
    $lines = @('directory')
    Get-ChildItem -LiteralPath $root -Recurse -File | Sort-Object FullName | ForEach-Object {
        $relative = $_.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
        $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        $lines += "$relative $hash"
    }
    return $lines
}

function Get-PreviewFingerprint {
    $canonicalTarget = ((Resolve-Path -LiteralPath $Target).Path.TrimEnd('\', '/') -replace '\\', '/')
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add("target=$canonicalTarget")
    $lines.Add("lang=$Lang")
    $lines.Add("module=$Module")
    foreach ($governancePath in @('AGENTS.md', 'README.md', 'backlog.md', 'mission.md', 'governance.md', 'docs/')) {
        $fullPath = Join-Path $Target $governancePath.TrimEnd('/')
        if (Test-Path -LiteralPath $fullPath) {
            $lines.Add("path=$governancePath")
            foreach ($snapshotLine in @(Get-PathSnapshot $fullPath)) { $lines.Add($snapshotLine) }
        } else {
            $lines.Add("path=$governancePath absent")
        }
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes(($lines -join "`n") + "`n")
    $hash = [Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return (($hash | ForEach-Object { $_.ToString('x2') }) -join '')
}

$actualPaths = @()
foreach ($governancePath in @('AGENTS.md', 'README.md', 'backlog.md', 'mission.md', 'governance.md')) {
    if (Test-Path -LiteralPath (Join-Path $Target $governancePath)) { $actualPaths += $governancePath }
}
if (Test-Path -LiteralPath (Join-Path $Target 'docs') -PathType Container) { $actualPaths += 'docs/' }

$approved = @{}
foreach ($entry in $Conflict) {
    $pair = Parse-Pair $entry '--conflict'
    $path = $pair[0]
    if ($path -notin @('AGENTS.md', 'README.md', 'backlog.md', 'mission.md', 'governance.md', 'docs/') -or $approved.ContainsKey($path)) {
        Fail 'conflict decision set must exactly match target conflicts'
    }
    if ($pair[1] -notin @('APPROVE_PRESERVE', 'APPROVE_MERGE', 'APPROVE_REPLACE_WITH_BACKUP', 'APPROVE_SKIP')) {
        Fail 'conflict decision set must use normalized APPROVE_* decisions'
    }
    $approved[$path] = $pair[1]
}
if (($approved.Count -ne $actualPaths.Count) -or (@($actualPaths | Where-Object { -not $approved.ContainsKey($_) }).Count -gt 0)) {
    Fail 'conflict decision set must exactly match target conflicts'
}
$backupMap = @{}
$backupDestinations = @{}
foreach ($entry in $BackupMapping) {
    $pair = Parse-Pair $entry '--backup-mapping'
    if ($pair[0] -notin $actualPaths -or $backupMap.ContainsKey($pair[0]) -or -not (Is-SafeRelativePath $pair[1])) {
        Fail 'backup mapping must remain within target and use an approved conflict path'
    }
    $backupKey = $pair[1].TrimEnd('/', '\')
    if ($backupDestinations.ContainsKey($backupKey)) {
        Fail 'backup mappings must use unique destinations'
    }
    $backupDestinations[$backupKey] = $pair[0]
    $backupMap[$pair[0]] = $pair[1]
}
$rollbackMap = @{}
foreach ($entry in $RollbackMapping) {
    $pair = Parse-Pair $entry '--rollback-mapping'
    if ($pair[0] -notin $actualPaths -or $rollbackMap.ContainsKey($pair[0]) -or $pair[1] -eq 'not_applicable') {
        Fail 'replacement requires a rollback mapping for every approved path'
    }
    $rollbackMap[$pair[0]] = $pair[1]
}

foreach ($path in $actualPaths) {
    if ($approved[$path] -ne 'APPROVE_REPLACE_WITH_BACKUP') {
        Write-Output 'State: DEFERRED'
        Write-Output 'Mutation: none'
        Write-Output 'Target: unchanged'
        exit 0
    }
}
if ($backupMap.Count -ne $actualPaths.Count -or $rollbackMap.Count -ne $actualPaths.Count) {
    if ($actualPaths.Count -eq 0 -and $backupMap.Count -eq 0 -and $rollbackMap.Count -eq 0) {
        # A replacement decision on a conflict-free target has no backup work.
    } else {
        Fail 'replacement requires exact backup and rollback mappings for every conflict'
    }
}
if ($actualPaths.Count -eq 0) {
    if ($backupMap.Count -ne 0 -or $rollbackMap.Count -ne 0) {
        Fail 'backup mappings are not allowed without an approved replacement path'
    }
} elseif ([string]::IsNullOrWhiteSpace($GitignoreDecision)) {
    Fail 'replacement requires an explicit gitignore decision: YES or NO'
}

if ($PreviewFingerprint -notmatch '^[0-9a-fA-F]{64}$') {
    Fail '--preview-fingerprint must be a SHA-256 value'
}
$calculatedFingerprint = Get-PreviewFingerprint
if ($PreviewFingerprint.ToLowerInvariant() -ne $calculatedFingerprint) {
    Fail 'preview fingerprint does not match the current target preview'
}

$sourceSnapshots = @{}
foreach ($path in $actualPaths) {
    $source = Join-Path $Target $path.TrimEnd('/')
    $backup = Join-Path $Target $backupMap[$path].TrimEnd('/')
    if ($source -eq $backup) {
        Fail 'backup mapping must differ from the approved source path'
    }
    foreach ($otherPath in $actualPaths) {
        $otherSource = Join-Path $Target $otherPath.TrimEnd('/')
        if ($backup.StartsWith("$otherSource\", [StringComparison]::OrdinalIgnoreCase)) {
            Fail 'backup mapping must remain outside every approved source path'
        }
    }
    $sourceSnapshots[$path] = @(Get-PathSnapshot $source)
}

# All sources and destinations are preflighted before any backup operation.
foreach ($path in $actualPaths) {
    $source = Join-Path $Target $path.TrimEnd('/')
    $backup = Join-Path $Target $backupMap[$path].TrimEnd('/')
    if (Test-Path -LiteralPath $backup) {
        if ((@(Get-PathSnapshot $backup) -join "`n") -ne ($sourceSnapshots[$path] -join "`n")) {
            Fail "existing backup does not match approved source path: $path"
        }
    } else {
        $parent = Split-Path -Parent $backup
        if (Test-Path -LiteralPath $parent -PathType Leaf) {
            Fail "backup parent is not a directory: $parent"
        }
    }
}

$createdBackups = @()
$createdBackupParents = @()
try {
    foreach ($path in $actualPaths) {
        $source = Join-Path $Target $path.TrimEnd('/')
        $backup = Join-Path $Target $backupMap[$path].TrimEnd('/')
        if (Test-Path -LiteralPath $backup) { continue }
        $parent = Split-Path -Parent $backup
        if (-not (Test-Path -LiteralPath $parent)) {
            $createdBackupParents += $parent
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        $createdBackups += $backup
        Copy-Item -LiteralPath $source -Destination $backup -Recurse
    }
    foreach ($path in $actualPaths) {
        $source = Join-Path $Target $path.TrimEnd('/')
        $backup = Join-Path $Target $backupMap[$path].TrimEnd('/')
        if ((@(Get-PathSnapshot $source) -join "`n") -ne ($sourceSnapshots[$path] -join "`n")) {
            Fail "approved source changed while creating backup: $path"
        }
        if ((@(Get-PathSnapshot $backup) -join "`n") -ne ($sourceSnapshots[$path] -join "`n")) {
            Fail "backup verification failed for approved path: $path"
        }
    }
} catch {
    foreach ($created in $createdBackups) {
        Remove-Item -LiteralPath $created -Recurse -Force -ErrorAction SilentlyContinue
    }
    foreach ($parent in $createdBackupParents) {
        if (Test-Path -LiteralPath $parent) {
            $children = @(Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue)
            if ($children.Count -eq 0) {
                Remove-Item -LiteralPath $parent -Force -ErrorAction SilentlyContinue
            }
        }
    }
    throw
}

foreach ($path in $actualPaths) {
    $source = Join-Path $Target $path.TrimEnd('/')
    $backup = Join-Path $Target $backupMap[$path].TrimEnd('/')
    if ((@(Get-PathSnapshot $source) -join "`n") -ne ($sourceSnapshots[$path] -join "`n")) {
        Fail "approved source changed after backup verification: $path"
    }
    if ((@(Get-PathSnapshot $backup) -join "`n") -ne ($sourceSnapshots[$path] -join "`n")) {
        Fail "backup changed after verification: $path"
    }
}

& $Initializer -Lang $Lang -Module $Module -Target $Target -Force -Name $targetName
if ($LASTEXITCODE -ne 0) { Fail "initializer failed with exit code $LASTEXITCODE" }
& $Validator -Target $Target -Mode instantiated
if ($LASTEXITCODE -ne 0) { Fail "validator failed with exit code $LASTEXITCODE" }
Write-Output 'State: BOOTSTRAP_APPROVED'
Write-Output 'Mutation: delegated'
Write-Output "Target: $Target"
foreach ($path in $actualPaths) {
    Write-Output "BACKUP_MAPPING=$path -> $($backupMap[$path])"
    Write-Output "ROLLBACK_MAPPING=$path -> $($rollbackMap[$path])"
}
if ($actualPaths.Count -eq 0) {
    Write-Output 'GITIGNORE_DECISION=not_applicable'
} else {
    Write-Output "GITIGNORE_DECISION=$GitignoreDecision"
}
