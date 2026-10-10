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

Write-Warning 'validate-template.ps1 is deprecated; use validate-harness.ps1.'
$Canonical = Join-Path $PSScriptRoot 'validate-harness.ps1'
$ForwardedArguments = @()
switch ($PSCmdlet.ParameterSetName) {
    'All' { $ForwardedArguments += '-All' }
    'Template' { $ForwardedArguments += @('-Template', $Template) }
    'Root' { $ForwardedArguments += '-Root' }
    'Target' {
        $ForwardedArguments += @('-Target', $Target, '-Mode', $Mode)
    }
}
& $Canonical @ForwardedArguments
exit $LASTEXITCODE
