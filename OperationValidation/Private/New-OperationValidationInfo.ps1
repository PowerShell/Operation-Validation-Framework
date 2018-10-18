
function New-OperationValidationInfo {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function', Target='*')]
    param (
        [Parameter(Mandatory)]
        [string]$File,

        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string[]]$Name,

        [string[]]$TestCases,

        [Parameter(Mandatory)]
        [ValidateSet('None', 'Simple', 'Comprehensive')]
        [string]$Type,

        [string]$Modulename,

        [string[]]$Tags,

        [Version]$Version,

        [hashtable]$Parameters
    )

    $o = [pscustomobject]@{
        PSTypeName       = 'OperationValidationInfo'
        File             = $File
        FilePath         = $FilePath
        Name             = $Name
        TestCases        = $testCases
        Type             = $type
        ModuleName       = $Modulename
        Tags             = $Tags
        Version          = $Version
        ScriptParameters = $Parameters
    }
    $toString = { return ('{0} ({1}): {2}' -f $this.testFile, $this.Type, ($this.TestCases -join ',')) }
    Add-Member -InputObject $o -MemberType ScriptMethod -Name ToString -Value $toString -Force
    $o
}
