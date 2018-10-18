
function New-OperationValidationFailure {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function', Target='*')]
    param (
        [Parameter(Mandatory)]
        [string]$StackTrace,

        [Parameter(Mandatory)]
        [string]$FailureMessage
    )

    $o = [pscustomobject]@{
        PSTypeName     = 'OperationValidationFailure'
        StackTrace     = $StackTrace
        FailureMessage = $FailureMessage
    }
    $toString = { return $this.StackTrace }
    Add-Member -Inputobject $o -MemberType ScriptMethod -Name ToString -Value $toString -Force
    $o
}
