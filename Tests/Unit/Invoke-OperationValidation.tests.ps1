
$testModuleDir = (Resolve-Path -Path (Join-Path -Path $env:BHProjectPath -ChildPath TestArtifacts)).Path

Describe 'Invoke-OperationValidation' {

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

    Context "Passes override parameters" {
        $tests = Get-OperationValidation -ModuleName VersionedModule -Version '1.0.0'

        It "No override parameters supplied" {
            $results = $tests | Invoke-OperationValidation
            $results[0].Result | Should be 'Passed'
            $results[1].Result | Should be 'Passed'
        }

        It "Override parameters supplied" {
            $results = $tests | Invoke-OperationValidation -Overrides @{ WebsiteUrl = 'https://www.microsoft.com'}
            $results[0].Result | Should be 'Passed'
            $results[1].Result | Should be 'Failed'
        }
    }

    Context "Runs tests based on tags" {
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

    Context 'Accepts Path and LiteralPath' {
        It 'Can run tests by Path' {
            $results = $testModuleDir | Invoke-OperationValidation
            $results.Count | should be 4
        }

        It 'Can run tests by LiteralPath' {
            $results = Invoke-OperationValidation -LiteralPath $testModuleDir
            $results.Count | should be 4
        }
    }

    Context 'Single Files' {
        it 'Can run a single Pester script' {
            $results = Invoke-OperationValidation -TestFilePath (Join-Path -Path $testModuleDir -ChildPath 'SingleTest.tests.ps1')
            $results.Result | Should Be 'Passed'
        }
    }
}