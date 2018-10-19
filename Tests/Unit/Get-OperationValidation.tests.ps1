
$testModuleDir = (Resolve-Path -Path (Join-Path -Path $env:BHProjectPath -ChildPath TestArtifacts)).Path

Describe 'Get-OperationValidation' {

    BeforeAll {
        $pathSeparator = [IO.Path]::PathSeparator
        $savedModulePath = $env:PSModulePath
        if ($testModuleDir -notin $env:PSModulePath.split($pathSeparator)) {
            $env:PSModulePath += ($pathSeparator + $testModuleDir)
        }
        if ($env:BHProjectPath -notin $env:PSModulePath.Split($pathSeparator)) {
            $env:PSModulePath += ($pathSeparator + $env:BHProjectPath)
        }
        Remove-Module Microsoft.PowerShell.Operation.Validation -Force -ErrorAction SilentlyContinue -Verbose:$false
        Import-Module $env:BHModulePath -Force -Verbose:$false
    }

    AfterAll {
        $env:PSModulePath = $savedModulePath
        Remove-Module OperationValidation -Verbose:$false
    }

    Context "Finds proper tests" {
        It "Can find its own tests" {
            $tests = Get-OperationValidation -Path (Split-Path -Path $env:BHModulePath -Parent)

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
            $tests[2].Version | Should be ([Version]'2.0.0')
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
        It 'Can get tests by Path' {
            $tests = $testModuleDir | Get-OperationValidation
            $tests.Count | should be 4
        }

        It 'Can get tests by LiteralPath' {
            $tests = Get-OperationValidation -LiteralPath $testModuleDir
            $tests.Count | should be 4
        }
    }
}