function Get-OperationValidation {
    <#
    .SYNOPSIS
    Retrieve the operational tests from modules

    .DESCRIPTION
    Modules which include a Diagnostics directory are inspected for
    Pester tests in either the "Simple" or "Comprehensive" subdirectories.
    If files are found in those directories, they will be inspected to determine
    whether they are Pester tests. If Pester tests are found, the
    test names in those files will be returned.

    The module structure required is as follows:

    ModuleBase\
        Diagnostics\
            Simple         # simple tests are held in this location
                            (e.g., ping, serviceendpoint checks)
            Comprehensive  # comprehensive scenario tests should be placed here

    .PARAMETER Name
    One or more module names to inspect and return if they adhere to the OVF Pester test structure.

    By default this is [*] which will inspect all modules in $env:PSModulePath.

    .PARAMETER Path
    One or more paths to search for OVF modules in. This bypasses searching the directories contained in $env:PSModulePath.

    .PARAMETER LiteralPath
    One or more literal paths to search for OVF modules in. This bypasses searching the directories contained in $env:PSModulePath.

    Unlike the Path parameter, the value of LiteralPath is used exactly as it is typed.
    No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation
    marks tell PowerShell not to interpret any characters as escape sequences.

    .PARAMETER TestType
    The type of tests to retrieve, this may be either "Simple", "Comprehensive", or Both ("Simple,Comprehensive").
    "Simple, Comprehensive" is the default.

    .PARAMETER Version
    The version of the module to retrieve. If not specified, the latest version
    of the module will be retured.

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

    .EXAMPLE
    PS> Get-OperationValidation -Name OVF.Windows.Server

        Module:   C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2
        Version:  1.0.2
        Type:     Simple
        Tags:     {}
        File:     LogicalDisk.tests.ps1
        FilePath: C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2\Diagnostics\Simple\LogicalDisk.tests.ps1
        Name:
            Logical Disks


        Module:   C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2
        Version:  1.0.2
        Type:     Simple
        Tags:     {}
        File:     Memory.tests.ps1
        FilePath: C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2\Diagnostics\Simple\Memory.tests.ps1
        Name:
            Memory


        Module:   C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2
        Version:  1.0.2
        Type:     Simple
        Tags:     {}
        File:     Network.tests.ps1
        FilePath: C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2\Diagnostics\Simple\Network.tests.ps1
        Name:
            Network Adapters


        Module:   C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2
        Version:  1.0.2
        Type:     Simple
        Tags:     {}
        File:     Services.tests.ps1
        FilePath: C:\Program Files\WindowsPowerShell\Modules\OVF.Windows.Server\1.0.2\Diagnostics\Simple\Services.tests.ps1
        Name:
            Operating System

    .EXAMPLE
    PS> $tests = Get-OperationValidation

    Search in all modules found in $env:PSModulePath for OVF tests.

    .EXAMPLE
    PS> $tests = Get-OperationValidation -Path C:\MyTests

    Search for OVF modules under c:\MyTests

    .EXAMPLE
    PS> $simpleTests = Get-OperationValidation -ModuleName OVF.Windows.Server -TypeType Simple

    Get just the simple tests in the OVF.Windows.Server module.

    .EXAMPLE
    $tests = Get-OperationValidation -ModuleName OVF.Windows.Server -Version 1.0.2

    Get all the tests from version 1.0.2 of the OVF.Windows.Server module.

    .EXAMPLE
    $storageTests = Get-OperationValidation -Tag Storage

    Search in all modules for OVF tests that include the tag Storage.

    .EXAMPLE
    $tests = Get-OperationValidation -ExcludeTag memory

    Search for OVF tests that don't include the tag Memory

    .LINK
    Invoke-OperationValidation

    #>
    [CmdletBinding(DefaultParameterSetName = 'ModuleName')]
    param (
        [Parameter(
            ParameterSetName = 'ModuleName',
            Position = 0
        )]
        [Alias('ModuleName')]
        [string[]]$Name = '*',

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

        # [Parameter(ParameterSetName = 'ModuleName')]
        # [Parameter(ParameterSetName = 'Path')]
        # [Parameter(ParameterSetName = 'LiteralPath')]
        [ValidateSet('Simple', 'Comprehensive')]
        [string[]]$TestType =  @('Simple', 'Comprehensive'),

        [Version]$Version,

        [string[]]$Tag,

        [string[]]$ExcludeTag
    )

    PROCESS {
        Write-Progress -Activity 'Inspecting Modules' -Status ' '

        # Resolve module list either by module name, path, or literalpath
        $modListParams = @{}
        switch ($PSCmdlet.ParameterSetName) {
            'ModuleName' {
                $modListParams.Name = $Name
                break
            }
            'Path' {
                $paths = Resolve-Path -Path $Path | Select-Object -ExpandProperty Path
                $modListParams.Path = $paths
            }
            'LiteralPath' {
                $paths = Resolve-Path -LiteralPath $LiteralPath | Select-Object -ExpandProperty Path
                $modListParams.Path = $paths
            }
        }

        if ($PSBoundParameters.ContainsKey('Version')) {
            $modListParams.Version = $Version
            $moduleCollection = @(Get-ModuleList -Name $Name -Version $Version)
        }
        $moduleCollection = @(Get-ModuleList @modListParams)

        $count = 1
        $moduleCount = $moduleCollection.Count
        Write-Debug -Message "Found [$moduleCount] OVF modules"
        foreach($modulePath in $moduleCollection) {
            Write-Progress -Activity ("Searching for Diagnostics in $modulePath") -PercentComplete ($count++/$moduleCount*100) -status ' '
            $diagnosticsDir = Join-Path -Path $modulePath -ChildPath 'Diagnostics'

            # Get the module manifest so we can pull out the version
            $modName = Split-Path -Path $modulePath -Leaf
            $manifestFile = Get-ChildItem -Path $modulePath -Filter "$($modName).psd1"
            if (-not $manifestFile) {
                if ("$modName" -as [version]) {
                    # We are in a "version" directory so get the actual module name from the parent directory
                    $parent = Split-Path -Path (Split-Path -Path $modulePath -Parent) -Leaf
                    $manifestFile = Get-ChildItem -Path $modulePath -Filter "$($parent).psd1"
                }
            }

            # Some OVF modules might not have a manifest (.psd1) file.
            if ($manifestFile) {
                if ($PSVersionTable.PSVersion.Major -ge 5) {
                    $manifest = Import-PowerShellDataFile -Path $manifestFile.FullName
                } else {
                    $manifest = Parse-Psd1 $manifestFile.FullName
                }
            } else {
                $manifest = $null
            }

            if (Test-Path -Path $diagnosticsDir) {
                foreach($dir in $testType) {
                    $testDir = Join-Path -Path $diagnosticsDir -ChildPath $dir
                    if (-not (Test-Path -Path $testDir)) {
                        continue
                    }
                    foreach($file in (Get-ChildItem -Path $testDir | Where-Object {$_.Name -like '*.tests.ps1'})) {
                        # Pull out parameters to Pester script if they exist
                        $script = Get-Command -Name $file.fullname
                        $parameters = $script.Parameters
                        if ($parameters.Keys.Count -gt 0) {
                            Write-Debug -Message 'Test script has overrideable parameters'
                            Write-Debug -Message "`n$($parameters.Keys | Out-String)"
                        }

                        $tests = @(Get-TestFromScript -ScriptPath $file.FullName)
                        foreach ($test in $tests) {
                            # Only return tests that match the tag filter(s)
                            if ($Tag -and @(Compare-Object -ReferenceObject $Tag -DifferenceObject $test.Tags -IncludeEqual -ExcludeDifferent).count -eq 0) { continue }
                            if ($ExcludeTag -and @(Compare-Object -ReferenceObject $ExcludeTag -DifferenceObject $test.Tags -IncludeEqual -ExcludeDifferent).count -gt 0) { continue }

                            $modInfoParams = @{
                                FilePath   = $file.Fullname
                                File       = $file.Name
                                Type       = $dir
                                Name       = $test.Name
                                ModuleName =  $modulePath
                                Tags       = $test.Tags
                                Version    = if ($manifest.ModuleVersion) { [version]$manifest.ModuleVersion } else { $null }
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
