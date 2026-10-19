$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$handoff = Join-Path $scriptDir '..\scripts\decision-handoff.ps1'
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("forsetum-handoff-ps-{0}" -f [guid]::NewGuid())
New-Item -ItemType Directory -Path $tempRoot | Out-Null

function Fail([string]$Message) {
    throw "FAIL: $Message"
}

function Assert-Contains([string]$Haystack, [string]$Needle, [string]$Label) {
    if (-not $Haystack.Contains($Needle)) {
        Fail "${Label}: expected '$Needle'"
    }
}

function Get-PathSnapshot([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return @('file', (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant())
    }
    $root = (Resolve-Path -LiteralPath $Path).Path
    $lines = @('directory')
    Get-ChildItem -LiteralPath $root -Recurse -File | Sort-Object FullName | ForEach-Object {
        $relative = $_.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
        $lines += "$relative $((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())"
    }
    return $lines
}

function Get-PreviewFingerprint([string]$Target, [string]$Lang, [string]$Module) {
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

try {
    $target = Join-Path $tempRoot 'target'
    $backup = Join-Path $target '.forsetum-backups\task'
    New-Item -ItemType Directory -Path (Join-Path $target 'docs') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target 'AGENTS.md') -Value 'existing agents' -NoNewline
    Set-Content -LiteralPath (Join-Path $target 'README.md') -Value 'existing readme' -NoNewline
    Set-Content -LiteralPath (Join-Path $target 'docs\existing.md') -Value 'existing docs' -NoNewline

    $initializer = Join-Path $tempRoot 'initializer.ps1'
    $validator = Join-Path $tempRoot 'validator.ps1'
    $log = Join-Path $tempRoot 'commands.log'
    @'
"initializer:$($args -join '|')" | Add-Content -LiteralPath $env:FORSETUM_HANDOFF_PS_LOG
'@ | Set-Content -LiteralPath $initializer
    @'
"validator:$($args -join '|')" | Add-Content -LiteralPath $env:FORSETUM_HANDOFF_PS_LOG
'@ | Set-Content -LiteralPath $validator
    $env:FORSETUM_HANDOFF_PS_LOG = $log

    $before = (Get-FileHash -LiteralPath (Join-Path $target 'AGENTS.md') -Algorithm SHA256).Hash
    $readmeBefore = (Get-FileHash -LiteralPath (Join-Path $target 'README.md') -Algorithm SHA256).Hash
    $cancel = & $handoff -Decision CANCEL -Target $target -Lang en -Module app-maintenance -Initializer $initializer -Validator $validator | Out-String
    Assert-Contains $cancel 'State: CANCELLED' 'cancel state'
    Assert-Contains $cancel 'Mutation: none' 'cancel mutation'
    if (Test-Path -LiteralPath $log) { Fail 'cancel invoked a delegated command' }
    $after = (Get-FileHash -LiteralPath (Join-Path $target 'AGENTS.md') -Algorithm SHA256).Hash
    $readmeAfter = (Get-FileHash -LiteralPath (Join-Path $target 'README.md') -Algorithm SHA256).Hash
    if ($before -ne $after) { Fail 'cancel changed the target' }
    if ($readmeBefore -ne $readmeAfter) { Fail 'cancel changed README.md' }

    $previewFingerprint = Get-PreviewFingerprint $target 'id' 'app-maintenance'

    $approved = & $handoff -Decision APPROVE_REPLACE_WITH_BACKUP `
        -Target $target -Lang id -Module app-maintenance `
        -Initializer $initializer -Validator $validator `
        -PreviewFingerprint $previewFingerprint `
        -Conflict @('AGENTS.md=APPROVE_REPLACE_WITH_BACKUP', 'README.md=APPROVE_REPLACE_WITH_BACKUP', 'docs/=APPROVE_REPLACE_WITH_BACKUP') `
        -BackupMapping @('AGENTS.md=.forsetum-backups/task/AGENTS.md', 'README.md=.forsetum-backups/task/README.md', 'docs/=.forsetum-backups/task/docs') `
        -RollbackMapping @('AGENTS.md=restore AGENTS.md', 'README.md=restore README.md', 'docs/=restore docs') `
        -GitignoreDecision NO | Out-String
    Assert-Contains $approved 'State: BOOTSTRAP_APPROVED' 'approved state'
    Assert-Contains $approved 'Mutation: delegated' 'approved mutation'
    if (-not (Test-Path -LiteralPath (Join-Path $backup 'AGENTS.md'))) { Fail 'AGENTS.md backup missing' }
    if (-not (Test-Path -LiteralPath (Join-Path $backup 'README.md'))) { Fail 'README.md backup missing' }
    if (-not (Test-Path -LiteralPath (Join-Path $backup 'docs\existing.md'))) { Fail 'docs backup missing' }
    $readmeBackupHash = (Get-FileHash -LiteralPath (Join-Path $backup 'README.md') -Algorithm SHA256).Hash
    if ($readmeBefore -ne $readmeBackupHash) { Fail 'README.md backup mismatch' }
    $logText = Get-Content -LiteralPath $log -Raw
    Assert-Contains $logText 'initializer:' 'initializer invocation'
    Assert-Contains $logText '-Force' 'force forwarding'
    Assert-Contains $logText '-Name' 'name forwarding'
    Assert-Contains $logText 'validator:' 'validator invocation'
    Assert-Contains $logText '-Target' 'validator target forwarding'

    Write-Output 'PASS: PowerShell decision handoff fixtures'
} finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
