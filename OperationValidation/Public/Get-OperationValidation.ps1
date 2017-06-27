
function Get-OperationValidation {
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

    .PARAMETER TestType
    The type of tests to retrieve, this may be either "Simple", "Comprehensive"
    or Both ("Simple,Comprehensive"). "Simple,Comprehensive" is the default.

    .PARAMETER Version
    The version of the module to retrieve. If the specified, the latest version
    of the module will be retured.

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

    .PARAMETER Tag
    Executes tests with specified tag parameter values. Wildcard characters and tag values that include spaces
    or whitespace characters are not supported.

    When you specify multiple tag values, Get-OperationValidation executes tests that have any of the
    listed tags. If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

    .PARAMETER ExcludeTag
    Omits tests with the specified tag parameter values. Wildcard characters and tag values that include spaces
    or whitespace characters are not supported.

    When you specify multiple ExcludeTag values, Get-OperationValidation omits tests that have any
    of the listed tags. If you use both Tag and ExcludeTag, ExcludeTag takes precedence.
    .LINK
    Invoke-OperationValidation

    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string[]]$ModuleName = "*",
        [Parameter()][ValidateSet("Simple","Comprehensive")][string[]]$TestType =  @("Simple","Comprehensive"),
        [Parameter()][Version]$Version,
        [Parameter()][string[]]$Tag,
        [Parameter()][string[]]$ExcludeTag
    )

    PROCESS {
        Write-Progress -Activity 'Inspecting Modules' -Status ' '
        if ($PSBoundParameters.ContainsKey('Version'))
        {
            $moduleCollection = @(Get-ModuleList -Name $ModuleName -Version $Version)
        }
        else
        {
            $moduleCollection = @(Get-ModuleList -Name $ModuleName)
        }

        $count = 1
        $moduleCount = $moduleCollection.Count
        Write-Debug -Message "Found [$moduleCount] OVF modules"
        foreach($modulePath in $moduleCollection)
        {
            Write-Progress -Activity ("Searching for Diagnostics in $modulePath") -PercentComplete ($count++/$moduleCount*100) -status ' '
            $diagnosticsDir = Join-Path -Path $modulePath -ChildPath 'Diagnostics'

            # Get the module manifest so we can pull out the version
            $moduleName = Split-Path -Path $modulePath -Leaf
            $manifestFile = Get-ChildItem -Path $modulePath -Filter "$($moduleName).psd1"
            if (-not $manifestFile) {
                if ("$moduleName" -as [version]) {
                    # We are in a "version" directory so get the actual module name from the parent directory
                    $parent = Split-Path -Path (Split-Path -Path $modulePath -Parent) -Leaf
                    $manifestFile = Get-ChildItem -Path $modulePath -Filter "$($parent).psd1"
                }
            }

            # Some OVF modules might not have a manifest (.psd1) file.
            if ($manifestFile) {
                $manifest = Parse-Psd1 $manifestFile.FullName
                #$manifest = Test-ModuleManifest -Path $manifestFile.FullName -Verbose:$false -ErrorAction SilentlyContinue
            }
            else
            {
                $manifest = $null
            }

            if ( test-path -path $diagnosticsDir )
            {
                foreach($dir in $testType)
                {
                    $testDir = Join-Path -Path $diagnosticsDir -ChildPath $dir
                    if (-not (Test-Path -Path $testDir))
                    {
                        continue
                    }
                    foreach($file in (Get-ChildItem -Path $testDir -Filter *.tests.ps1))
                    {
                        # Pull out parameters to Pester script if they exist
                        $script = Get-Command -Name $file.fullname
                        $parameters = $script.Parameters
                        if ($parameters.Keys.Count -gt 0)
                        {
                            Write-Debug -Message 'Test script has overrideable parameters'
                            Write-Debug -Message "`n$($parameters.Keys | Out-String)"
                        }

                        $tests = @(Get-TestFromScript -ScriptPath $file.FullName)
                        foreach ($test in $tests)
                        {
                            # Only return tests that match the tag filter(s)
                            if ($Tag -and @(Compare-Object -ReferenceObject $Tag -DifferenceObject $test.Tags -IncludeEqual -ExcludeDifferent).count -eq 0) { continue }
                            if ($ExcludeTag -and @(Compare-Object -ReferenceObject $ExcludeTag -DifferenceObject $test.Tags -IncludeEqual -ExcludeDifferent).count -gt 0) { continue }

                            $modInfoParams = @{
                                FilePath = $file.Fullname
                                File = $file.Name
                                Type = $dir
                                Name = $test.Name
                                ModuleName =  $modulePath
                                Tags = $test.Tags
                                Version = if ($manifest.ModuleVersion) { [version]$manifest.ModuleVersion } else { $null }
                                Parameters = $parameters
                            }
                            New-OperationValidationInfo @modInfoParams
                        }
                    }
                }
            }
        }
    }
}
