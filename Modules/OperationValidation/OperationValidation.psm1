#Region ObjectHelpers
function New-OperationValidationFailure
{
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
function New-OperationValidationResult
{
    param (
        [Parameter(Mandatory=$true)][string]$Module,
        [Parameter(Mandatory=$true)][string]$FileName,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Result,
        [Parameter()][object]$RawResult,
        [Parameter()][object]$Error
    )
    $o = new-object -TypeName pscustomobject
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
function new-OperationValidationInfo
{
    param ( 
        [Parameter(Mandatory=$true)][string]$File,
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string[]]$Name,
        [Parameter()][string[]]$TestCases,
        [Parameter(Mandatory=$true)][ValidateSet("None","Simple","Comprehensive")][string]$Type,
        [Parameter()][string]$modulename
        )
    $o = [pscustomobject]@{
        File = $File
        FilePath = $FilePath
        Name = $Name
        TestCases = $testCases
        Type = $type
        ModuleName = $modulename
    }
    $o.psobject.Typenames.Insert(0,"OperationValidationInfo")
    $ToString = { return ("{0} ({1}): {2}" -f $this.testFile, $this.Type, ($this.TestCases -join ",")) }
    Add-Member -inputobject $o -membertype ScriptMethod -Name ToString -Value $toString -Force
    $o
}
# endregion

function Get-TestFromScript
{
    param ( [string]$scriptPath )
    $errs = $null
    $tok =[System.Management.Automation.PSParser]::Tokenize((get-content -read 0 -Path $scriptPath), [ref]$Errs)
    write-verbose -Message $scriptPath

    for($i = 0; $i -lt $tok.count; $i++) {
        if ( $tok[$i].type -eq "Command" -and $tok[$i].content -eq "Describe" ) 
        {
            $i++
            if ( $tok[$i].Type -eq "String" ) { $tok[$i].Content }
            else
            {
                # ok - we didn't get the describe text first, 
                # we likely saw a "-Tags" statement, so that means that
                # the describe text will immediately preceed the scriptblock
                while($tok[$i].Type -ne "GroupStart")
                {
                    $i++
                }
                $i--
                $tok[$i].Content
            }
        }
    }

}
<#
.SYNOPSIS
Retrieve the operational tests from modules

.DESCRIPTION
Modules which include a Diagnostics directory are inspected for 
Pester tests in either the "Simple" or "Comprehensive" directories.
If files are found in those directories, they will be inspected to determine
whether they are Pester tests. If Pester tests are found, the 
test names in those files will be returned.

The module structure required is as follows:

ModuleBase\
    Diagnostics\
        Simple         # simple tests are held in this location 
                         (e.g., ping, serviceendpoint checks)
        Comprehensive  # comprehensive scenario tests should be placed here
         
.PARAMETER ModuleName
By default this is * which will retrieve all modules in $env:psmodulepath
Additional module directories may be added. If you wish to check both
$env:psmodulepath and your own specific locations, use
*,<yourmodulepath>

.PARAMETER Type
The type of tests to retrieve, this may be either "Simple", "Comprehensive"
or Both ("Simple,Comprehensive"). "Simple,Comprehensive" is the default.

.EXAMPLE
PS> Get-OperationValidation -ModuleName C:\temp\modules\AddNumbers

    Type:         Simple
    File:     addnum.tests.ps1
    FilePath: C:\temp\modules\AddNumbers\Diagnostics\Simple\addnum.tests.ps1
    Name:
        Add-Em
        Subtract em
        Add-Numbers
    Type:         Comprehensive
    File:     Comp.Adding.Tests.ps1
    FilePath: C:\temp\modules\AddNumbers\Diagnostics\Comprehensive\Comp.Adding.Tests.ps1
    Name:
        Comprehensive Adding Tests
        Comprehensive Subtracting Tests
        Comprehensive Examples

.LINK
Invoke-OperationValidation

#>
function Get-OperationValidation
{
[CmdletBinding()]
param (
    [Parameter(Position=0)][string[]]$ModuleName = "*",
    [Parameter()][ValidateSet("Simple","Comprehensive")][string[]]$TestType =  @("Simple","Comprehensive")
    )

    BEGIN
    {

        #$testTypes = $type.Tostring().Replace(" ","").split(",")
        function Get-TestName ( $ast )
        {
            for($i = 1; $i -lt $ast.Parent.CommandElements.Count; $i++)
            {
                if ( $ast.Parent.CommandElements[$i] -is "System.Management.Automation.Language.CommandParameterAst") { $i++; continue }
                if ( $ast.Parent.CommandElements[$i] -is "System.Management.Automation.Language.ScriptBlockExpressionAst" ) { continue }
                if ( $ast.Parent.CommandElements[$i] -is "System.Management.Automation.Language.StringConstantExpressionAst" ) { return $ast.Parent.CommandElements[$i].Value }
            }
            throw "Could not determine test name"
        }
        function Get-TestFromAst ( $ast )
        {
            $eb = $ast.EndBlock
            foreach($statement in $eb.Statements)
            {
                if ( $statement -isnot "System.Management.Automation.Language.PipelineAst" )
                {
                    continue
                }
                $CommandAst = $statement.PipelineElements[0].CommandElements[0]

                if (  $CommandAst.Value -eq "Describe" )
                {
                    Get-TestName $CommandAst
                }
            }
        }
        function Get-TestCaseNamesFromAst ( $ast )
        {
            $eb = $ast.EndBlock
            foreach($statement in $eb.Statements)
            {
                if ( $statement -isnot "System.Management.Automation.Language.PipelineAst" )
                {
                    continue
                }
                $CommandAst = $statement.PipelineElements[0].CommandElements[0]

                if (  $CommandAst.Value -eq "It" )
                {
                    Get-TestName $CommandAst
                }
            }
        }
        function Get-ModuleList 
        {
            param ( [string[]]$Name )
            foreach($p in $env:psmodulepath.split(";"))
            {
                if ( test-path -path $p )
                {
                    foreach($modDir in get-childitem -path $p -directory)
                    {
                        foreach ($n in $name )
                        {
                            if ( $modDir.Name -like $n )
                            {
                                # now determine if there's a diagnostics directory, or a version
                                if ( test-path -path ($modDir.FullName + "\Diagnostics"))
                                {
                                    $modDir.FullName
                                    break
                                }
                                $versionDirectories = Get-Childitem -path $modDir.FullName -dir | 
                                    where-object { $_.name -as [version] }
                                $potentialDiagnostics = $versionDirectories | where-object {
                                    test-path ($_.fullname + "\Diagnostics")
                                    }
                                # now select the most recent module path which has diagnostics
                                $DiagnosticDir = $potentialDiagnostics | 
                                    sort-object {$_.name -as [version]} | 
                                    Select-Object -Last 1
                                if ( $DiagnosticDir )
                                {
                                    $DiagnosticDir.FullName
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    PROCESS
    {
        Write-Progress -Activity "Inspecting Modules" -Status " "
        $moduleCollection = Get-ModuleList -Name $ModuleName   
        $count = 1; 
        $moduleCount = @($moduleCollection).Count
        foreach($module in $moduleCollection)
        {
            Write-Progress -Activity ("Searching for Diagnostics in " + $module) -PercentComplete ($count++/$moduleCount*100) -status " "
            $diagnosticsDir=$module + "\Diagnostics" 
            if ( test-path -path $diagnosticsDir )
            {
                foreach($dir in $testType)
                {
                    $testDir = "$diagnosticsDir\$dir"
                    write-verbose -Message "SPECIFIC TEST: $testDir"
                    if ( ! (test-path -path $testDir) ) 
                    {
                        continue
                    }
                    foreach($file in get-childitem -path $testDir -filter *.tests.ps1)
                    {
                        Write-Verbose -Message $file.fullname
                        $testName = Get-TestFromScript -scriptPath $file.FullName
                        new-OperationValidationInfo -FilePath $file.Fullname -File $file.Name -Type $dir -Name $testName -ModuleName $Module
                    }
                }
            }
        }
    }
}

<#
.SYNOPSIS
Invoke the operational tests from modules

.DESCRIPTION
Modules which include Diagnostics tests are executed via this cmdlet

.PARAMETER testFilePath
The path to a diagnostic test to execute. By default all discoverable diagnostics will be invoked

.PARAMETER TestInfo
The type of tests to invoke, this may be either "Simple", "Comprehensive"
or Both ("Simple,Comprehensive"). "Simple,Comprehensive" is the default.

.EXAMPLE
PS> Get-OperationValidation -ModuleName OperationValidation | Invoke-OperationValidation -IncludePesterOutput
Describing Simple Test Suite
 [+] first Operational test 20ms
 [+] second Operational test 19ms
 [+] third Operational test 9ms
Tests completed in 48ms
Passed: 3 Failed: 0 Skipped: 0 Pending: 0
Describing Scenario targeted tests
   Context The RemoteAccess service
    [+] The service is running 37ms
   Context The Firewall Rules
    [+] A rule for TCP port 3389 is enabled 1.19s
    [+] A rule for UDP port 3389 is enabled 11ms
Tests completed in 1.24s
Passed: 3 Failed: 0 Skipped: 0 Pending: 0


   Module: OperationValidation

Result  Name
------- --------
Passed  Simple Test Suite::first Operational test
Passed  Simple Test Suite::second Operational test
Passed  Simple Test Suite::third Operational test
Passed  Scenario targeted tests:The RemoteAccess service:The service is running
Passed  Scenario targeted tests:The Firewall Rules:A rule for TCP port 3389 is enabled
Passed  Scenario targeted tests:The Firewall Rules:A rule for UDP port 3389 is enabled

.LINK
Get-OperationValidation
#>
function Invoke-OperationValidation
{
    [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="FileAndTest")]
    param (
        [Parameter(ParameterSetName="Path",ValueFromPipelineByPropertyName=$true)][string[]]$testFilePath,
        [Parameter(ParameterSetName="FileAndTest",ValueFromPipeline=$true)][pscustomobject[]]$TestInfo,
        [Parameter(ParameterSetName="UseGetOperationTest")][string[]]$ModuleName = "*",
        [Parameter(ParameterSetName="UseGetOperationTest")]
        [ValidateSet("Simple","Comprehensive")][string[]]$TestType = @("Simple","Comprehensive"),
        [Parameter()][switch]$IncludePesterOutput
        )
    BEGIN
    {
        $quiet = ! $IncludePesterOutput
        if ( ! (get-module -Name Pester))
        {
            if ( get-module -list Pester )
            {
                import-module -Name Pester
            }
            else
            {
                Throw "Cannot load Pester module"
            }
        }
        # $resultCollection = @()
    }
    PROCESS
    {
        if ( $PSCmdlet.ParameterSetName -eq "UseGetOperationTest" )
        {
            $tests = Get-OperationValidation -ModuleName $ModuleName -TestType $TestType 
            $tests | Invoke-OperationValidation -IncludePesterOutput:$IncludePesterOutput
            return
        }
        
        if ( ($testFilePath -eq $null) -and ($TestInfo -eq $null) )
        {
            Get-OperationValidation | Invoke-OperationValidation -IncludePesterOutput:$IncludePesterOutput
            return
        }

        
        if ( $testInfo -ne $null )
        {
            # first check to be sure all of the TestInfos are sane
            foreach($ti in $testinfo)
            {
                if ( ! ($ti.FilePath -and $ti.Name))
                {
                    throw "TestInfo must contain the path and the list of tests"
                }
            }
            
            write-verbose -Message ("EXECUTING: {0} {1}" -f $ti.FilePath,($ti.Name -join ","))
            foreach($tname in $ti.Name)
            {
                $testResult = Invoke-pester -Path $ti.FilePath -TestName $tName -quiet:$quiet -PassThru
                Add-member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $ti.FilePath
                Convert-TestResult $testResult 
            }
            return
        }

        foreach($test in $testFilePath)
        {
            write-progress -Activity "Invoking tests in $test"
            if ( $PSCmdlet.ShouldProcess($test))
            {
                $testResult = Invoke-Pester $test -passthru -quiet:$quiet
                Add-Member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $test
                Convert-TestResult $testResult
            }
        }
    }

}

# emit an object which can be used in reporting
Function Convert-TestResult
{
    param ( $result )
    foreach ( $testResult in $result.TestResult )
    {
        $testError = $null
        if ( $testResult.Result -eq "Failed" )
        {
            Write-Verbose -message "Creating error object"
            $testError = new-OperationValidationFailure -Stacktrace $testResult.StackTrace -FailureMessage $testResult.FailureMessage
        }
        $Module = $result.Path.split([io.path]::DirectorySeparatorChar)[-4]
        $TestName = "{0}:{1}:{2}" -f $testResult.Describe,$testResult.Context,$testResult.Name
        New-OperationValidationResult -Module $Module -Name $TestName -FileName $result.path -Result $testresult.result -RawResult $testResult -Error $TestError
    }

}
