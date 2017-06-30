
function New-OperationValidationResult
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function', Target='*')]
    param (
        [Parameter(Mandatory=$true)][string]$Module,
        [Parameter(Mandatory=$true)][string]$FileName,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Result,
        [Parameter()][object]$RawResult,
        [Parameter()][object]$Error
    )
    $o = New-Object -TypeName pscustomobject
    Add-Member -InputObject $o -MemberType NoteProperty -Name Module -Value $Module
    Add-Member -InputObject $o -MemberType NoteProperty -Name FileName -Value $FileName
    Add-Member -InputObject $o -MemberType NoteProperty -Name ShortName -Value ([io.path]::GetFileName($FileName))
    Add-Member -InputObject $o -MemberType NoteProperty -Name Name -Value $Name
    Add-Member -InputObject $o -MemberType NoteProperty -Name Result -Value $Result
    Add-Member -InputObject $o -MemberType NoteProperty -Name Error -Value $Error
    Add-Member -InputObject $o -MemberType NoteProperty -Name RawResult -Value $RawResult
    $o.psobject.Typenames.Insert(0,"OperationValidationResult")
    $ToString = { return ("{0} ({1}): {2}" -f $this.Module, $this.FileName, $this.Name) }
    Add-Member -inputobject $o -membertype ScriptMethod -Name ToString -Value $toString -Force
    $o
}
