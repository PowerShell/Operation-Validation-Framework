
function Invoke-OperationValidation {
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

    .PARAMETER Path
    One or more paths to search for OVF modules in. This bypasses searching the directories contained in $env:PSModulePath.

    .PARAMETER LiteralPath
    One or more literal paths to search for OVF modules in. This bypasses searching the directories contained in $env:PSModulePath.

    Unlike the Path parameter, the value of LiteralPath is used exactly as it is typed.
    No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation
    marks tell PowerShell not to interpret any characters as escape sequences.

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

    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'FileAndTest')]
    param (
        [Parameter(
            ParameterSetName = 'TestFile',
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$TestFilePath,

        [Parameter(
            ParameterSetName = 'FileAndTest',
            ValueFromPipeline
        )]
        [pscustomobject[]]$TestInfo,

        [Parameter(ParameterSetName = 'UseGetOperationTest')]
        [string[]]$ModuleName,

        [parameter(
            Mandatory,
            ParameterSetName  = 'Path',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]$Path,

        [parameter(
            Mandatory,
            ParameterSetName = 'LiteralPath',
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string[]]$LiteralPath,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'LiteralPath')]
        [Parameter(ParameterSetName = 'UseGetOperationTest')]
        [ValidateSet('Simple', 'Comprehensive')]
        [string[]]$TestType = @('Simple', 'Comprehensive'),

        [switch]$IncludePesterOutput,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'LiteralPath')]
        [Parameter(ParameterSetName = 'UseGetOperationTest')]
        [Version]$Version,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'LiteralPath')]
        [Parameter(ParameterSetName = 'FileAndTest')]
        [Parameter(ParameterSetName = 'UseGetOperationTest')]
        [hashtable]$Overrides,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'LiteralPath')]
        [Parameter(ParameterSetName = 'UseGetOperationTest')]
        [string[]]$Tag,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'LiteralPath')]
        [Parameter(ParameterSetName = 'UseGetOperationTest')]
        [string[]]$ExcludeTag
    )

    begin {
        $pesterMod = Get-Module -Name Pester
        if (-not $pesterMod) {
            if (Get-Module -Name Pester -ListAvailable) {
                $pesterMod = Import-Module -Name Pester -Verbose:$false -PassThru
            } else {
                Throw "Cannot load Pester module"
            }
        }

        if ($PSCmdLet.ParameterSetName -eq 'UseGetOperationTest') {
            if ([string]::IsNullOrEmpty($ModuleName)) {
                $ModuleName = '*'
            }
        }

        $resolveOvfTestParameterSetNames = 'UseGetOperationTest', 'Path', 'LiteralPath'
    }

    process {
        if ($PSCmdlet.ParameterSetName -in $resolveOvfTestParameterSetNames) {
            $getOvfParams = @{
                TestType = $TestType
            }
            if ($PSBoundParameters.ContainsKey('Version')) {
                $getOvfParams.Version = $Version
            }
            if ($PSBoundParameters.ContainsKey('Tag')) {
                $getOvfParams.Tag = $Tag
            }
            if ($PSBoundParameters.ContainsKey('ExcludeTag')) {
                $getOvfParams.ExcludeTag = $ExcludeTag
            }

            if ($PSCmdlet.ParameterSetName -eq 'Path') {
                $getOvfParams.Path = $Path
            } elseIf ($PSCmdlet.ParameterSetName -eq 'LiteralPath') {
                $getOvfParams.LiteralPath = $LiteralPath
            } elseIf ($PSCmdLet.ParameterSetName -eq 'UseGetOperationTest') {
                $getOvfParams.ModuleName = $ModuleName
            }

            $testInfo = Get-OperationValidation @getOvfParams
        }

        if ($testInfo) {
            # first check to be sure all of the TestInfos are sane
            foreach($ti in $testinfo) {
                if (-not ($ti.FilePath -and $ti.Name)) {
                    throw "TestInfo must contain the path and the list of tests"
                }
            }

            # first check to be sure all of the TestInfos are sane
            foreach($ti in $testinfo) {
                if (-not ($ti.FilePath -and $ti.Name)) {
                    throw "TestInfo must contain the path and the list of tests"
                }
            }

            [int]$testCount = 0
            Write-Verbose -Message ("EXECUTING: {0} [{1}]" -f $ti.FilePath,($ti.Name -join ","))
            foreach($ti in $testinfo) {
                Write-Progress -Activity "Executing: $($ti.Name)" -PercentComplete ($testCount++ / $($testinfo.Count) * 100)
            
                $pesterParams = @{
                    TestName = $ti.Name
                    PassThru = $true
                    Verbose  = $false
                }

                # Pester 4.0.0 deprecated the 'Quiet' parameter in favor of 'Show'
                if ($pesterMod.Version -ge '4.0.0') {
                    if ($IncludePesterOutput) {
                        $pesterParams.Show = 'All'
                    } else {
                        $pesterParams.Show = 'None'
                    }
                } else {
                    $pesterParams.Quiet = -not $IncludePesterOutput
                }

                if ($ti.ScriptParameters) {
                    Write-Debug -Message 'Test has script parameters'
                    if ($PSBoundParameters.ContainsKey('Overrides')) {
                        Write-Verbose -Message "Overriding with parameters:`n$($Overrides | Format-Table -Property Key, Value | Out-String)"
                        $pesterParams.Script = @{
                            Path       = $ti.FilePath
                            Parameters = $Overrides
                        }
                    } else {
                        Write-Debug -Message 'Using default parameters for test'
                        $pesterParams.Path = $ti.FilePath
                    }
                } else {
                    $pesterParams.Path = $ti.FilePath
                }

                if ($PSBoundParameters.ContainsKey('Tag')) {
                    $pesterParams.Tag = $Tag
                }

                if ($PSBoundParameters.ContainsKey('ExcludeTag')) {
                    $pesterParams.ExcludeTag = $ExcludeTag
                }

                if ($PSCmdlet.ShouldProcess("$($ti.Name) [$($ti.FilePath)]")) {
                    $testResult = Invoke-Pester @pesterParams
                    if ($testResult) {
                        Add-member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $ti.FilePath
                        Convert-TestResult -Result $testResult -ModuleName $ti.ModuleName
                    }
                }
            }
            return
        }

        if ($TestFilePath) {
            $pesterParams = @{
                PassThru = $true
                Verbose  = $false
            }

            # Pester 4.0.0 deprecated the 'Quiet' parameter in favor of 'Show'
            if ($pesterMod.Version -ge '4.0.0') {
                if ($IncludePesterOutput) {
                    $pesterParams.Show = 'All'
                } else {
                    $pesterParams.Show = 'None'
                }
            } else {
                $pesterParams.Quiet = -not $IncludePesterOutput
            }

            foreach($filePath in $TestFilePath) {
                write-progress -Activity "Invoking tests in $filePath"
                if ($PSCmdlet.ShouldProcess($filePath)) {
                    $testResult = Invoke-Pester $filePath @pesterParams
                    Add-Member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $filePath
                    Convert-TestResult -Result $testResult
                }
            }
        }
    }
}
