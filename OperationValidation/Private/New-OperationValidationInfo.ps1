
function New-OperationValidationInfo
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function', Target='*')]
    param (
        [Parameter(Mandatory=$true)][string]$File,
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string[]]$Name,
        [Parameter()][string[]]$TestCases,
        [Parameter(Mandatory=$true)][ValidateSet("None","Simple","Comprehensive")][string]$Type,
        [Parameter()][string]$Modulename,
        [Parameter()][string[]]$Tags,
        [Parameter()][Version]$Version,
        [Parameter()][hashtable]$Parameters
        )
    $o = [pscustomobject]@{
        File = $File
        FilePath = $FilePath
        Name = $Name
        TestCases = $testCases
        Type = $type
        ModuleName = $Modulename
        Tags = $Tags
        Version = $Version
        ScriptParameters = $Parameters
    }
    $o.psobject.Typenames.Insert(0,"OperationValidationInfo")
    $ToString = { return ("{0} ({1}): {2}" -f $this.testFile, $this.Type, ($this.TestCases -join ",")) }
    Add-Member -inputobject $o -membertype ScriptMethod -Name ToString -Value $toString -Force
    $o
}
