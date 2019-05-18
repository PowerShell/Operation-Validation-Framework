# Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)

$moduleName = $env:BHProjectName
$moduleManifest = Join-Path -Path $env:BHModulePath -ChildPath "$($moduleName).psd1"
$testModuleDir = (Resolve-Path -Path (Join-Path -Path $env:BHProjectPath -ChildPath TestArtifacts)).Path

# Get module commands
# Remove all versions of the module from the session. Pester can't handle multiple versions.
$pathSeparator = [IO.Path]::PathSeparator
$savedModulePath = $env:PSModulePath
if ($env:PSModulePath.split($pathSeparator) -notcontains $testModuleDir) {
    $env:PSModulePath += ($pathSeparator + $testModuleDir)
}
if ($env:PSModulePath.Split($pathSeparator) -notcontains $env:BHModulePath) {
    $env:PSModulePath += ($pathSeparator + $env:BHProjectPath)
}
Remove-Module Microsoft.PowerShell.Operation.Validation -Force -ErrorAction SilentlyContinue -Verbose:$false
Import-Module $env:BHModulePath -Force -Verbose:$false

$moduleVersion = (Test-ModuleManifest $moduleManifest -Verbose:$false | Select-Object -ExpandProperty Version).ToString()
$ms = [Microsoft.PowerShell.Commands.ModuleSpecification]@{ ModuleName = $moduleName; RequiredVersion = $moduleVersion }
$commands = Get-Command -FullyQualifiedModule $ms -CommandType Cmdlet, Function, Workflow  # Not alias

## When testing help, remember that help is cached at the beginning of each session.
## To test, restart session.

Describe 'Module help' {

    foreach ($command in $commands) {
        $commandName = $command.Name

        # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
        $help = Get-Help $commandName -ErrorAction SilentlyContinue -Verbose:$false

        Describe "[$commandName]" {

            # If help is not found, synopsis in auto-generated help is the syntax diagram
            It "Is not auto-generated" {
                $help.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
            }

            # Should be a description for every function
            It "Has description" {
                $help.Description | Should Not BeNullOrEmpty
            }

            # Should be at least one example
            It "Has example code" {
                ($help.Examples.Example | Select-Object -First 1).Code | Should Not BeNullOrEmpty
            }

            # Should be at least one example description
            It "Has example help" {
                ($help.Examples.Example.Remarks | Select-Object -First 1).Text | Should Not BeNullOrEmpty
            }

            Context 'Parameters' {

                $common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable',
                'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'Confirm', 'Whatif'

                $parameters = $command.ParameterSets.Parameters | Sort-Object -Property Name -Unique | Where-Object { $_.Name -notin $common }
                $parameterNames = $parameters.Name

                ## Without the filter, WhatIf and Confirm parameters are still flagged in "finds help parameter in code" test
                $helpParameters = $help.Parameters.Parameter | Where-Object { $_.Name -notin $common } | Sort-Object -Property Name -Unique
                $helpParameterNames = $helpParameters.Name

                foreach ($parameter in $parameters) {
                    $parameterName = $parameter.Name
                    $parameterHelp = $help.parameters.parameter | Where-Object Name -EQ $parameterName

                    # Should be a description for every parameter
                    It "$parameterName`: Has description" {
                        $parameterHelp.Description.Text | Should Not BeNullOrEmpty
                    }

                    # Required value in Help should match IsMandatory property of parameter
                    It "$parameterName`: IsMandatory is correct" {
                        $codeMandatory = $parameter.IsMandatory.toString()
                        $parameterHelp.Required | Should Be $codeMandatory
                    }

                    # Parameter type in Help should match code
                    # It "help for $commandName has correct parameter type for $parameterName" {
                    #     $codeType = $parameter.ParameterType.Name
                    #     # To avoid calling Trim method on a null object.
                    #     $helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
                    #     $helpType | Should be $codeType
                    # }
                }

                context 'Help parameters' {
                    foreach ($helpParm in $HelpParameterNames) {
                        # Shouldn't find extra parameters in help.
                        It "[$helpParm] found in parameter help" {
                            $helpParm -in $parameterNames | Should Be $true
                        }
                    }
                }
            }

            if ($help.relatedLinks.navigationLink.uri) {
                Context "Help Links" {
                    foreach ($link in $help.relatedLinks.navigationLink.uri) {
                        # Should have a valid uri if one is provided.
                        it "[$link] should have 200 Status Code for $commandName" {
                            $Results = Invoke-WebRequest -Uri $link -UseBasicParsing
                            $Results.StatusCode | Should Be '200'
                        }
                    }
                }
            }
        }
    }
}

$env:PSModulePath = $savedModulePath
Remove-Module OperationValidation
