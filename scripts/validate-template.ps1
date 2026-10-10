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

Write-Warning 'validate-template.ps1 is deprecated; use validate-harness.ps1.'
$Canonical = Join-Path $PSScriptRoot 'validate-harness.ps1'
$ForwardedArguments = @{}
switch ($PSCmdlet.ParameterSetName) {
    'All' { $ForwardedArguments.All = $true }
    'Template' { $ForwardedArguments.Template = $Template }
    'Root' { $ForwardedArguments.Root = $true }
    'Target' {
        $ForwardedArguments.Target = $Target
        $ForwardedArguments.Mode = $Mode
    }
}
$global:LASTEXITCODE = 0
& $Canonical @ForwardedArguments
exit $LASTEXITCODE
