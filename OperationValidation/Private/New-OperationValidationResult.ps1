
function New-OperationValidationResult {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function', Target='*')]
    param (
        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Result,

        [string]$Module,

        [object]$RawResult,

        [object]$Error
    )

    $o = [pscustomobject]@{
        PSTypeName = 'OperationValidationResult'
        Module     = $Module
        FileName   = $FileName
        ShortName  = ([IO.Path]::GetFileName($FileName))
        Name       = $Name
        Result     = $Result
        Error      = $Error
        RawResult  = $RawResult
    }
    $toString = { return ('{0} ({1}): {2}' -f $this.Module, $this.FileName, $this.Name) }
    Add-Member -InputObject $o -MemberType ScriptMethod -Name ToString -Value $toString -Force
    $o
}
