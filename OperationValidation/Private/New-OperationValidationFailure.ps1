
function New-OperationValidationFailure
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function', Target='*')]
    param (
        [Parameter(Mandatory=$true)][string]$StackTrace,
        [Parameter(Mandatory=$true)][string]$FailureMessage
    )
    $o = [pscustomobject]@{
        StackTrace = $StackTrace
        FailureMessage = $FailureMessage
        }
    $o.psobject.Typenames.Insert(0,"OperationValidationFailure")
    $ToString = { return $this.StackTrace }
    Add-Member -inputobject $o -membertype ScriptMethod -Name ToString -Value $toString -Force
    $o
}
