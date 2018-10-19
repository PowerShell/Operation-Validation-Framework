
$testModuleDir = (Resolve-Path -Path (Join-Path -Path $env:BHProjectPath -ChildPath TestArtifacts)).Path

Describe 'OperationValidation Module Tests' {

    BeforeAll {
        $pathSeparator = [IO.Path]::PathSeparator
        $SavedModulePath = $env:PSModulePath
        if ($env:PSModulePath.split($pathSeparator) -notcontains $testModuleDir) {
            $env:PSModulePath += ($pathSeparator + $testModuleDir)
        }
        if ($env:PSModulePath.Split($pathSeparator) -notcontains $env:BHModulePath) {
            $env:PSModulePath += ($pathSeparator + $env:BHProjectPath)
        }
        Remove-Module Microsoft.PowerShell.Operation.Validation -Force -ErrorAction SilentlyContinue
        Import-Module $env:BHModulePath -Force
        $commands = Get-Command -Module OperationValidation | Sort-object Name
    }

    AfterAll {
        $env:PSModulePath = $savedModulePath
        Remove-Module OperationValidation
    }

    Context 'Get-OperationValidation parameters' {
        It 'ModuleName parameter is proper type' {
            $commands[0].Parameters['Name'].ParameterType | Should be ([System.String[]])
        }
        It 'Version parameter is proper type' {
            $commands[0].Parameters['Version'].ParameterType | Should be ([System.Version])
        }
        It 'TestType parameter is proper type' {
            $commands[0].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It 'Tag parameter is property type' {
            $commands[0].Parameters['Tag'].ParameterType | Should be ([System.String[]])
        }
        It 'ExcludeTag parameter is property type' {
            $commands[0].Parameters['Tag'].ParameterType | Should be ([System.String[]])
        }
        It 'TestType parameter has proper constraints' {
            $Commands[0].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq 'Simple' | Should be 'Simple'
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq 'Comprehensive' | Should be 'Comprehensive'
        }
    }
    Context 'Invoke-OperationValidation parameters' {
        It 'TestFilePath parameter is proper type' {
            $commands[1].Parameters['TestFilePath'].ParameterType | Should be ([System.String[]])
        }
        It 'TestInfo parameter is proper type' {
            $commands[1].Parameters['TestInfo'].ParameterType | Should be ([System.Management.Automation.PSObject[]])
        }
        It 'ModuleName parameter is proper type' {
            $commands[1].Parameters['ModuleName'].ParameterType | Should be ([System.String[]])
        }
        It 'Version parameter is proper type' {
            $commands[1].Parameters['Version'].ParameterType | Should be ([System.Version])
        }
        It 'Overrides parameter is proper type' {
            $commands[1].Parameters['Overrides'].ParameterType | Should be ([System.Collections.Hashtable])
        }
        It 'IncludePesterOutput is proper type' {
            $commands[1].Parameters['IncludePesterOutput'].ParameterType | Should be ([System.Management.Automation.SwitchParameter])
        }
        It 'TestType parameter is proper type' {
            $commands[1].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It 'Tag parameter is proper type' {
            $commands[1].Parameters['Tag'].ParameterType | Should be ([System.String[]])
        }
        It 'ExcludeTag parameter is proper type' {
            $commands[1].Parameters['ExcludeTag'].ParameterType | Should be ([System.String[]])
        }
        It 'TestType parameter has proper constraints' {
            $Commands[1].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq 'Simple' | Should be 'Simple'
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq 'Comprehensive' | Should be 'Comprehensive'
        }
    }
}
