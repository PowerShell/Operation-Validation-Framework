$MyDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$moduleDir = (resolve-path "$myDir/../..").path

Describe "OperationValidation Module Tests" {
    BeforeAll {
        $SavedModulePath = $env:PSModulePath
        if ( $env:psmodulepath.split(";") -notcontains $moduleDir )
        {
            $env:psmodulepath += ";$moduleDir"
        }
        Remove-Module Microsoft.PowerShell.Operation.Validation -Force -ErrorAction SilentlyContinue
        Import-Module OperationValidation -Force
        $Commands = Get-Command -module OperationValidation|sort-object Name
    }
    AfterAll {
        $env:PSModulePath = $SavedModulePath
        Remove-Module OperationValidation
    }
    It "Module has been loaded" {
        Get-Module OperationValidation | should not BeNullOrEmpty
    }
    Context "Exported Commands" {
        It "Exports 2 commands" {
            $commands.Count | Should be 2
        }
        It "The command names are correct" {
            $commands[0].Name | Should be "Get-OperationValidation"
            $commands[1].Name | Should be "Invoke-OperationValidation"
        }
    }
    Context "Get-OperationValidation parameters" {
        It "ModuleName parameter is proper type" {
            $commands[0].Parameters['ModuleName'].ParameterType | Should be ([System.String[]])
        }
        It "Version parameter is proper type" {
            $commands[0].Parameters['Version'].ParameterType | Should be ([System.Version])
        }
        It "TestType parameter is proper type" {
            $commands[0].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It "Tag parameter is property type" {
            $commands[0].Parameters['Tag'].ParameterType | Should be ([System.String[]])
        }
        It "ExcludeTag parameter is property type" {
            $commands[0].Parameters['Tag'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter has proper constraints" {
            $Commands[0].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq "Simple" | Should be "Simple"
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq "Comprehensive" | Should be "Comprehensive"
        }
    }
    Context "Invoke-OperationValidation parameters" {
        It "TestFilePath parameter is proper type" {
            $commands[1].Parameters['TestFilePath'].ParameterType | Should be ([System.String[]])
        }
        It "TestInfo parameter is proper type" {
            $commands[1].Parameters['TestInfo'].ParameterType | Should be ([System.Management.Automation.PSObject[]])
        }
        It "ModuleName parameter is proper type" {
            $commands[1].Parameters['ModuleName'].ParameterType | Should be ([System.String[]])
        }
        It "Version parameter is proper type" {
            $commands[1].Parameters['Version'].ParameterType | Should be ([System.Version])
        }
        It "Overrides parameter is proper type" {
            $commands[1].Parameters['Overrides'].ParameterType | Should be ([System.Collections.Hashtable])
        }
        It "IncludePesterOutput is proper type" {
            $commands[1].Parameters['IncludePesterOutput'].ParameterType | Should be ([System.Management.Automation.SwitchParameter])
        }
        It "TestType parameter is proper type" {
            $commands[1].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It "Tag parameter is proper type" {
            $commands[1].Parameters['Tag'].ParameterType | Should be ([System.String[]])
        }
        It "ExcludeTag parameter is proper type" {
            $commands[1].Parameters['ExcludeTag'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter has proper constraints" {
            $Commands[1].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq "Simple" | Should be "Simple"
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq "Comprehensive" | Should be "Comprehensive"
        }
    }
    Context "Get-OperationValidation finds proper tests" {
        It "Can find its own tests" {
            $tests = Get-OperationValidation -Modulename OperationValidation

            $tests.Count | Should be 2
            $tests.File -eq "PSGallery.Simple.Tests.ps1" | Should be "PSGallery.Simple.Tests.ps1"
            $tests.File -eq "PSGallery.Comprehensive.Tests.ps1" | Should be "PSGallery.Comprehensive.Tests.ps1"
        }
        It "Can find tests which don't have an actual module" {
            $tests = Get-OperationValidation -moduleName Example.WindowsSearch
            @($tests).Count | Should be 1
            $tests.File | should be WindowsSearch.Simple.Tests.ps1
        }
        It "Can find a specific version of a module" {
            $v1Tests = @(Get-OperationValidation -ModuleName 'VersionedModule' -Version '1.0.0')
            $v1Tests.Count | Should be 1
            $v1Tests.File | Should be 'PSGallery.Simple.Tests.ps1'

            $v2Tests = @(Get-OperationValidation -ModuleName 'VersionedModule' -Version '2.0.0')
            $v2Tests.Count | Should be 3
            $v2Tests[0].File | Should be 'PSGallery.Simple.Tests.ps1'
            $v2Tests[1].File | Should be 'PSGallery.Simple.Tests.ps1'
        }
        It "Can get the latest version of a module if no version is specified" {
            $tests = Get-OperationValidation -ModuleName VersionedModule
            $tests[0].Version | Should be ([Version]'2.0.0')
            $tests[1].Version | Should be ([Version]'2.0.0')
        }
        It "Can get tests with a tag" {
            $tests = Get-OperationValidation -Tag 'AAABBBCCC'
            $tests.Count | should be 2
            $tests[0].Tags[0] | Should be 'AAABBBCCC'
            $tests[1].Tags[0] | Should be 'AAABBBCCC'
            $tests[0].Name | Should be 'Simple Validation of PSGallery'
            $tests[1].Name | Should be 'Simple Validation of Microsoft'
        }
        It "Can get tests with multiple tags" {
            $tests = Get-OperationValidation -Tag 'AAABBBCCC', 'XXXYYYZZZ'
            $tests.Count | Should be 2
            @($tests | Where-Object {'AAABBBCCC' -in $_.Tags}).Count | Should be 2
            @($tests | Where-Object {'XXXYYYZZZ' -in $_.Tags}).Count | Should be 1
        }
        It "Can exclude modules with a tag" {
            $tests = Get-OperationValidation -ExcludeTag 'AAABBBCCC'
            $myTest = $tests | Where-Object {$_.Tags -Contains 'AAABBBCCC'}
            $myTest | Should BeNullOrEmpty
        }
        It "Can exclude modules with multiple tags" {
            $tests = Get-OperationValidation -ExcludeTag 'AAABBBCCC', 'XXXYYYZZZ'
            $myTest = $tests | Where-Object {('AAABBBCCC' -in $_.Tags) -or ('XXXYYYZZZ' -in $_.Tags)}
            $myTest | Should BeNullOrEmpty
        }
        It "Formats the output appropriately" {
            $output = Get-OperationValidation -Modulename OperationValidation | Out-String -Stream -Width 210 | Where-Object {$_}
            $expected = ".*Module:   .*OperationValidation",
                        "Version:  *"
                        "Type:     Simple",
                        "Tags:     {}",
                        "File:     PSGallery.Simple.Tests.ps1",
                        "FilePath: .*PSGallery.Simple.Tests.ps1",
                        "Name:",
                        "Simple Validation of PSGallery",
                        ""
                        "Module:   .*OperationValidation",
                        "Type:     Comprehensive",
                        "Tags:     {}",
                        "File:     PSGallery.Comprehensive.Tests.ps1",
                        "FilePath: .*PSGallery.Comprehensive.Tests.ps1",
                        "Name:",
                        "    E2E validation of PSGallery"
            for($i = 0; $i -lt $expected.Count; $i++)
            {
                $output[$i] | Should match $expected[$i]
            }
        }
    }

    Context "Invoke-OperationValidation passes override parameters" {
        $tests = Get-OperationValidation -ModuleName VersionedModule -Version '1.0.0'

        It "No override parameters supplied" {
            $results = $tests | Invoke-OperationValidation
            $results[0].Result | Should be 'Passed'
            $results[1].Result | Should be 'Passed'
        }

        It "Override parameters supplied" {
            $results = $tests | Invoke-OperationValidation -Overrides @{ WebsiteUrl = 'http://www.microsoft.com'}
            $results[0].Result | Should be 'Passed'
            $results[1].Result | Should be 'Failed'
        }
    }

    Context "Invoke-OperationValidation runs tests based on tags" {
        It "Can run tests with certain tag" {
            $results = Invoke-OperationValidation -Tag 'AAABBBCCC'
            $results[0].Result | Should be 'Passed'
            $results[1].Result | Should be 'Passed'
        }

        It "Can run tests excluding a tag" {
            $results = Invoke-OperationValidation -Modulename VersionedModule -ExcludeTag 'AAABBBCCC'
            $results.Result | Should be 'Passed'

            $results = Invoke-OperationValidation -Modulename VersionedModule -ExcludeTag 'XXXYYYZZZ'
            $results.Count | Should be 2
        }
    }
}
