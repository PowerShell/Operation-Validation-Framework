
function Invoke-OperationValidation
{
    <#
    .SYNOPSIS
    Invoke the operational tests from modules

    .DESCRIPTION
    Modules which include Diagnostics tests are executed via this cmdlet

    .PARAMETER TestFilePath
    The path to a diagnostic test to execute. By default all discoverable diagnostics will be invoked

    .PARAMETER TestInfo
    The type of tests to invoke, this may be either "Simple", "Comprehensive"
    or Both ("Simple,Comprehensive"). "Simple,Comprehensive" is the default.

    .PARAMETER ModuleName
    By default this is * which will retrieve and execute all OVF modules in $env:psmodulepath
    Additional module directories may be added. If you wish to check both
    $env:psmodulepath and your own specific locations, use
    *,<yourmodulepath>

    .PARAMETER TestType
    The type of tests to execute, this may be either "Simple", "Comprehensive"
    or Both ("Simple,Comprehensive"). "Simple,Comprehensive" is the default.

    .PARAMETER IncludePesterOutput
    Include the Pester output when execute the tests.

    .PARAMETER Version
    The version of the module to retrieve. If the specified, the latest version
    of the module will be retured.

    .PARAMETER Overrides
    If the Pester test(s) include script parameters, those parameters can be overridden by
    specifying a hashtable of values. The key(s) in the hashtable must match the parameter
    names in the Pester test.

    For example, if the Pester test includes a parameter block like the following, one or more of
    these parameters can be overriden using values from the hashtable passed to the -Overrides parameter.

    Pester test script:
    param(
        [int]$SomeValue = 100
        [bool]$ExtraChecks = $false
    )

    Overrides the default parameter values:
    Invoke-OperationValidation -ModuleName MyModule -Overrides @{ SomeValue = 500; ExtraChecks = $true }

    .PARAMETER Tag
    Executes tests with specified tag parameter values. Wildcard characters and tag values that include spaces
    or whitespace characters are not supported.

    When you specify multiple tag values, Invoke-OperationValidation executes tests that have any of the
    listed tags. If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

    .PARAMETER ExcludeTag
    Omits tests with the specified tag parameter values. Wildcard characters and tag values that include spaces
    or whitespace characters are not supported.

    When you specify multiple ExcludeTag values, Get-OperationValidation omits tests that have any
    of the listed tags. If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

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

    [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="FileAndTest")]
    param (
        [Parameter(ParameterSetName="Path",ValueFromPipelineByPropertyName=$true)][string[]]$TestFilePath,
        [Parameter(ParameterSetName="FileAndTest",ValueFromPipeline=$true)][pscustomobject[]]$TestInfo,
        [Parameter(ParameterSetName="UseGetOperationTest")][string[]]$ModuleName = "*",
        [Parameter(ParameterSetName="UseGetOperationTest")]
        [ValidateSet("Simple","Comprehensive")][string[]]$TestType = @("Simple","Comprehensive"),
        [Parameter()][switch]$IncludePesterOutput,
        [Parameter(ParameterSetName="UseGetOperationTest")]
        [Parameter()][Version]$Version,
        [Parameter(ParameterSetName="FileAndTest")]
        [Parameter(ParameterSetName="UseGetOperationTest")]
        [Parameter()][hashtable]$Overrides,
        [Parameter(ParameterSetName="UseGetOperationTest")]
        [Parameter()][string[]]$Tag,
        [Parameter(ParameterSetName="UseGetOperationTest")]
        [Parameter()][string[]]$ExcludeTag
        )
    BEGIN
    {
        if ( -not (Get-Module -Name Pester))
        {
            if ( Get-Module -Name Pester -ListAvailable)
            {
                Import-Module -Name Pester -Verbose:$false
            }
            else
            {
                Throw "Cannot load Pester module"
            }
        }
    }
    PROCESS
    {
        if ( $PSCmdlet.ParameterSetName -eq "UseGetOperationTest" )
        {
            $getOvfParams = @{
                ModuleName = $ModuleName
                TestType = $TestType
            }
            if ($PSBoundParameters.ContainsKey('Version'))
            {
                $getOvfParams.Version = $Version
            }
            if ($PSBoundParameters.ContainsKey('Tag'))
            {
                $getOvfParams.Tag = $Tag
            }
            if ($PSBoundParameters.ContainsKey('ExcludeTag'))
            {
                $getOvfParams.ExcludeTag = $ExcludeTag
            }

            $testInfo = Get-OperationValidation @getOvfParams
        }

        if ( $null -ne $testInfo )
        {
            # first check to be sure all of the TestInfos are sane
            foreach($ti in $testinfo)
            {
                if ( ! ($ti.FilePath -and $ti.Name))
                {
                    throw "TestInfo must contain the path and the list of tests"
                }
            }

            # first check to be sure all of the TestInfos are sane
            foreach($ti in $testinfo)
            {
                if ( ! ($ti.FilePath -and $ti.Name))
                {
                    throw "TestInfo must contain the path and the list of tests"
                }
            }

            Write-Verbose -Message ("EXECUTING: {0} [{1}]" -f $ti.FilePath,($ti.Name -join ","))
            foreach($ti in $testinfo)
            {
                $pesterParams = @{
                    TestName = $ti.Name
                    PassThru = $true
                    Verbose = $false
                }

                # Pester 4.0.0 deprecated the 'Quiet' parameter in favor of 'Show'
                $pesterMod = Get-Module -Name Pester
                if ($pesterMod.Version -ge '4.0.0')
                {
                    if ($IncludePesterOutput)
                    {
                        $pesterParams.Show = 'All'
                    }
                    else
                    {
                        $pesterParams.Show = 'None'
                    }
                }
                else
                {
                    $pesterParams.Quiet = !$IncludePesterOutput
                }

                if ($ti.ScriptParameters)
                {
                    Write-Debug -Message 'Test has script parameters'
                    if ($PSBoundParameters.ContainsKey('Overrides'))
                    {
                        Write-Verbose -Message "Overriding with parameters:`n$($Overrides | Format-Table -Property Key, Value | Out-String)"
                        $pesterParams.Script = @{
                            Path = $ti.FilePath
                            Parameters = $Overrides
                        }
                    }
                    else
                    {
                        Write-Debug -Message 'Using default parameters for test'
                        $pesterParams.Path = $ti.FilePath
                    }
                }
                else
                {
                    $pesterParams.Path = $ti.FilePath
                }

                if ($PSBoundParameters.ContainsKey('Tag'))
                {
                    $pesterParams.Tag = $Tag
                }

                if ($PSBoundParameters.ContainsKey('ExcludeTag'))
                {
                    $pesterParams.ExcludeTag = $ExcludeTag
                }

                if ( $PSCmdlet.ShouldProcess("$($ti.Name) [$($ti.FilePath)]"))
                {
                    $testResult = Invoke-Pester @pesterParams
                    if ($testResult)
                    {
                        Add-member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $ti.FilePath
                        Convert-TestResult -Result $testResult -ModuleName $ModuleName
                    }
                }
            }
            return
        }

        if ($TestFilePath)
        {
            foreach($filePath in $TestFilePath) {
                write-progress -Activity "Invoking tests in $filePath"
                if ( $PSCmdlet.ShouldProcess($filePath)) {
                    $testResult = Invoke-Pester $filePath -passthru -quiet:$quiet
                    Add-Member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $filePath
                    Convert-TestResult -Result $testResult
                }
            }
        }
    }
}
