
Describe 'Module' {

    BeforeAll {
        $pathSeparator = [IO.Path]::PathSeparator
        $savedModulePath = $env:PSModulePath
        if ($env:PSModulePath.split($pathSeparator) -notcontains $testModuleDir) {
            $env:PSModulePath += ($pathSeparator + $testModuleDir)
        }
        if ($env:PSModulePath.Split($pathSeparator) -notcontains $env:BHModulePath) {
            $env:PSModulePath += ($pathSeparator + $env:BHProjectPath)
        }
        Remove-Module Microsoft.PowerShell.Operation.Validation -Force -ErrorAction SilentlyContinue
        Import-Module $env:BHModulePath -Force
    }

    AfterAll {
        $env:PSModulePath = $savedModulePath
        Remove-Module OperationValidation
    }

    Context "Exported Commands" {

        $commands = Get-Command -Module OperationValidation | Sort-object Name

        It "Exports 2 commands" {
            $commands.Count | Should be 2
        }
        It "The command names are correct" {
            $commands[0].Name | Should be "Get-OperationValidation"
            $commands[1].Name | Should be "Invoke-OperationValidation"
        }
    }

}