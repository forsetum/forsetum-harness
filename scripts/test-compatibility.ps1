<# Standalone public-package smoke gate; Windows PowerShell 5.1 and PowerShell 7. #>
[CmdletBinding()]
param([string]$Root = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Root = (Resolve-Path -LiteralPath $Root).Path
$work = Join-Path ([IO.Path]::GetTempPath()) ('forsetum compatibility ' + [guid]::NewGuid().ToString('N'))
$modules = @('web-fullstack','landing-page','sales-outreach','general-office','mobile-app','cli-automation','content-marketing','research-analysis','web-starter','it-infra-ops','app-maintenance','procurement-tender','hr-people-ops','education-training','supply-chain-logistics','event-project-mgmt','ui-ux-design','content-creator','digital-advertising','academic-education','health-medical','construction-civil','manufacturing-hse','culinary-fnb','agribusiness-farming','sme-business','business-growth')
function Assert([bool]$condition, [string]$message) { if (-not $condition) { throw "FAIL: $message" } }
function Inventory([string]$path) {
    $base = (Resolve-Path -LiteralPath $path).Path.TrimEnd('\','/')
    @(Get-ChildItem -LiteralPath $base -Recurse -Force | Sort-Object FullName | ForEach-Object {
        $relative = $_.FullName.Substring($base.Length) -replace '\\','/'
        if ($_.PSIsContainer) { "D $relative" } else { "F $relative $((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)" }
    }) -join "`n"
}
try {
    New-Item -ItemType Directory -Path $work | Out-Null
    Write-Output "OS: $([Environment]::OSVersion.VersionString)"
    Write-Output "PowerShell: $($PSVersionTable.PSVersion) Edition: $($PSVersionTable.PSEdition)"
    Write-Output "Root: $Root"
    # Exercise named forwarding and process status using the installed native interpreter.
    # A positional splat breaks Template/Target binding; a swallowed exit makes CI green.
    $wrapperFixture = Join-Path $work 'wrapper regression'
    New-Item -ItemType Directory -Path $wrapperFixture | Out-Null
    $wrapper = Join-Path $wrapperFixture 'validate-template.ps1'
    $canonical = Join-Path $wrapperFixture 'validate-harness.ps1'
    $record = Join-Path $wrapperFixture 'record.json'
    Copy-Item -LiteralPath (Join-Path $Root 'scripts/validate-template.ps1') -Destination $wrapper
    @'
[CmdletBinding(DefaultParameterSetName = 'All')]
param(
    [Parameter(ParameterSetName = 'All')][switch]$All,
    [Parameter(ParameterSetName = 'Template')][string]$Template,
    [Parameter(ParameterSetName = 'Root')][switch]$Root,
    [Parameter(ParameterSetName = 'Target')][string]$Target,
    [Parameter(ParameterSetName = 'Target')][string]$Mode = 'source'
)
[ordered]@{ParameterSet=$PSCmdlet.ParameterSetName;All=[bool]$All;Template=$Template;Root=[bool]$Root;Target=$Target;Mode=$Mode} |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'record.json')
'@ | Set-Content -LiteralPath $canonical
    $interpreter = (Get-Process -Id $PID).Path
    $forwardCases = @(
        @{Label='default All';Arguments=@();Set='All'},
        @{Label='explicit All';Arguments=@('-All');Set='All'},
        @{Label='Template';Arguments=@('-Template','id');Set='Template'},
        @{Label='Root';Arguments=@('-Root');Set='Root'},
        @{Label='Target source';Arguments=@('-Target',(Join-Path $work 'target with spaces'));Set='Target'},
        @{Label='Target instantiated';Arguments=@('-Target',(Join-Path $work 'target with spaces'),'-Mode','instantiated');Set='Target'}
    )
    foreach ($case in $forwardCases) {
        if (Test-Path -LiteralPath $record) { Remove-Item -LiteralPath $record }
        $arguments = @('-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',$wrapper) + $case.Arguments
        & $interpreter @arguments | Out-Null
        Assert ($LASTEXITCODE -eq 0) "wrapper $($case.Label) process failed"
        Assert (Test-Path -LiteralPath $record) "wrapper $($case.Label) did not invoke canonical validator"
        $observed = Get-Content -LiteralPath $record -Raw | ConvertFrom-Json
        Assert ($observed.ParameterSet -eq $case.Set) "wrapper $($case.Label) parameter set"
        switch ($case.Set) {
            'All' { Assert $observed.All 'wrapper All switch lost' }
            'Template' { Assert ($observed.Template -eq 'id') 'wrapper Template value lost' }
            'Root' { Assert $observed.Root 'wrapper Root switch lost' }
            'Target' {
                Assert ($observed.Target -eq (Join-Path $work 'target with spaces')) 'wrapper spaced Target value lost'
                $expectedMode = 'source'
                if ($case.Label -eq 'Target instantiated') { $expectedMode = 'instantiated' }
                Assert ($observed.Mode -eq $expectedMode) 'wrapper Target Mode lost'
            }
        }
        Write-Output "PASS: wrapper $($case.Label) forwarding"
    }
    Set-Content -LiteralPath $canonical -Value 'exit 23'
    $process = Start-Process -FilePath $interpreter -ArgumentList @('-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',('"' + $wrapper + '"')) -Wait -PassThru
    Assert ($process.ExitCode -eq 23) 'wrapper swallowed canonical exit 23'
    Set-Content -LiteralPath $canonical -Value "throw 'expected wrapper regression failure'"
    # Isolate expected terminating diagnostics in a child process.
    $failureLog = Join-Path $wrapperFixture 'expected-error.log'
    $process = Start-Process -FilePath $interpreter -ArgumentList @('-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',('"' + $wrapper + '"')) -Wait -PassThru -RedirectStandardError $failureLog
    Assert ($process.ExitCode -ne 0) 'wrapper swallowed canonical terminating error'
    Write-Output 'PASS: wrapper canonical nonzero exit and terminating error propagation'
    $installed = Join-Path $work 'installed skill'
    Copy-Item -LiteralPath (Join-Path $Root 'skills/forsetum-harness') -Destination $installed -Recurse
    $runtime = Join-Path $installed 'runtime'
    if (-not (Test-Path -LiteralPath $runtime)) {
        Assert (Test-Path -LiteralPath (Join-Path $Root 'scripts/export-public.sh')) 'public package missing runtime'
        New-Item -ItemType Directory -Path (Join-Path $runtime 'scripts') -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $Root 'template') -Destination (Join-Path $runtime 'template') -Recurse
        foreach ($name in @('init','bundle','validate-harness','validate-template')) {
            foreach ($extension in @('sh','ps1')) {
                Copy-Item -LiteralPath (Join-Path $Root "scripts/$name.$extension") -Destination (Join-Path $runtime 'scripts')
            }
        }
    }
    foreach ($name in @('init','bundle','validate-harness','validate-template')) {
        foreach ($extension in @('sh','ps1')) {
            $a = (Get-FileHash -LiteralPath (Join-Path $Root "scripts/$name.$extension")).Hash
            $b = (Get-FileHash -LiteralPath (Join-Path $runtime "scripts/$name.$extension")).Hash
            Assert ($a -eq $b) "runtime script drift: $name.$extension"
        }
    }
    $cases = 0
    foreach ($lang in @('en','id')) {
        foreach ($validatorName in @('validate-harness','validate-template')) {
            $global:LASTEXITCODE = 0
            & (Join-Path $runtime "scripts/$validatorName.ps1") -Template $lang
            Assert ($? -and $LASTEXITCODE -eq 0) "$lang/$validatorName failed"
        }
        $source = Join-Path $Root "template/$lang"
        Assert ((Inventory $source) -eq (Inventory (Join-Path $runtime "template/$lang"))) "$lang runtime template drift"
        $manifest = Get-Content -LiteralPath (Join-Path $source 'manifest.json') -Raw | ConvertFrom-Json
        $ids = @($manifest.modules.PSObject.Properties.Name | Sort-Object)
        Assert (($ids -join ',') -eq (($modules | Sort-Object) -join ',')) "$lang approved 27 module inventory"
        $directories = @(Get-ChildItem -LiteralPath (Join-Path $source 'modules') -Directory -Force | Select-Object -ExpandProperty Name | Sort-Object)
        Assert (($directories -join ',') -eq (($modules | Sort-Object) -join ',')) "$lang approved 27 module directory inventory"
        foreach ($module in $modules) {
            $metadata = $manifest.modules.$module
            foreach ($field in @('name','category','description','directory','variables','readiness_checks','tier','persona','interview_phases','domain_guardrails')) {
                Assert ($metadata.PSObject.Properties.Name -contains $field) "$lang/$module missing metadata: $field"
            }
            $initTarget = Join-Path $work "$lang/$module/init target"
            $bundleTarget = Join-Path $work "$lang/$module/bundle target"
            $global:LASTEXITCODE = 0
            & (Join-Path $runtime 'scripts/init.ps1') -Lang $lang -Module $module -Name 'Compatibility Fixture' -Target $initTarget | Out-Null
            Assert ($? -and $LASTEXITCODE -eq 0) "$lang/$module initializer failed"
            $global:LASTEXITCODE = 0
            & (Join-Path $runtime 'scripts/bundle.ps1') -Lang $lang -Module $module -Name 'Compatibility Fixture' -Dir $bundleTarget | Out-Null
            Assert ($? -and $LASTEXITCODE -eq 0) "$lang/$module bundler failed"
            foreach ($target in @($initTarget,$bundleTarget)) {
                Assert (Test-Path -LiteralPath (Join-Path $target 'AGENTS.md')) "$lang/$module AGENTS missing"
                Assert (Test-Path -LiteralPath (Join-Path $target 'docs/INDEX.md')) "$lang/$module index missing"
                Assert (-not ((Get-Content -LiteralPath (Join-Path $target 'AGENTS.md') -Raw).Contains('{{PROJECT_NAME}}'))) "$lang/$module name not interpolated"
                foreach ($item in Get-ChildItem -LiteralPath (Join-Path $source "modules/$module") -Force -Recurse -File) {
                    $relative = $item.FullName.Substring((Join-Path $source "modules/$module").Length).TrimStart("\","/")
                    Assert (Test-Path -LiteralPath (Join-Path $target $relative) -PathType Leaf) "$lang/$module overlay missing: $relative"
                }
            }
            Assert ((Inventory $initTarget) -eq (Inventory $bundleTarget)) "$lang/$module init/bundle mismatch"
            $cases++
            Write-Output "PASS: $lang/$module init and bundle"
        }
    }
    Assert ($cases -eq 54) 'expected 54 cases'
    $target = Join-Path $work 'conflict target'
    New-Item -ItemType Directory -Path (Join-Path $target 'docs') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target 'AGENTS.md') -Value 'keep agents'
    Set-Content -LiteralPath (Join-Path $target 'docs/existing.md') -Value 'keep docs'
    $before = Inventory $target
    $handoff = Join-Path $installed 'scripts/decision-handoff.ps1'
    $parameters = @{Target=$target;Lang='en';Module='web-starter';Initializer=(Join-Path $runtime 'scripts/init.ps1');Validator=(Join-Path $runtime 'scripts/validate-harness.ps1')}
    foreach ($decision in @('CANCEL','PRESERVE','SKIP','DEFER')) {
        $result = & $handoff -Decision $decision @parameters
        Assert (($result -join "`n").Contains('Mutation: none')) "$decision did not decline mutation"
        Assert ((Inventory $target) -eq $before) "$decision changed target"
    }
    $rejected = $false
    try { & $handoff -Decision APPROVE_REPLACE_WITH_BACKUP @parameters | Out-Null } catch { $rejected = $true; Write-Output "Expected rejection: $_" }
    Assert $rejected 'incomplete conflict approval accepted'
    Assert ((Inventory $target) -eq $before) 'rejected approval changed target'
    Write-Output 'PASS: installed native handoff conflict/cancellation safety'
    Write-Output 'PASS: 54 language/module cases; 108 initializer/bundler executions'
} finally {
    if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force }
}
