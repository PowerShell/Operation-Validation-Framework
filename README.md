
# Operation-Validation-Framework

| Azure Pipelines | AppVeyor | PS Gallery | License
|-----------------|----------|------------|---------|
[![Azure Pipelines Build Status][azure-pipeline-badge]][azure-pipeline-build] | [![AppVeyor Build Status][appveyor-badge]][appveyor-build] | [![PowerShell Gallery][psgallery-badge]][psgallery] | [![License][license-badge]][license]

A set of tools for executing validation of the operation of a system.
It provides a way to organize and execute Pester tests which are written
to validate operation (rather than limited feature tests)

Modules which include a Diagnostics directory are inspected for
Pester tests in either the "Simple" or "Comprehensive" directories.
If files are found in those directories, they will be inspected to determine
whether they are Pester tests. If Pester tests are found, the
test names in those files will be returned.

The module structure required is as follows:

* ModuleBase\
   * Diagnostics\
      * Simple         *simple tests are held in this location  (e.g., ping, serviceendpoint checks)*
      * Comprehensive  *comprehensive scenario tests should be placed here*


It supplies two cmdlets:
```
PS# get-help *operationvalidation

Name                              Category  Synopsis
----                              --------  --------
Get-OperationValidation           Function  Retrieve the operational tests from modules
Invoke-OperationValidation        Function  Invoke the operational tests from modules
```

## Examples
```
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


    PS> Invoke-OperationValidation -IncludePesterOutput

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

```
[azure-pipeline-badge]: https://dev.azure.com/devblackops/Operation-Validation-Framework/_apis/build/status/PowerShell.Operation-Validation-Framework?branchName=master
[azure-pipeline-build]: https://dev.azure.com/devblackops/Operation-Validation-Framework/_build/latest?definitionId=4&branchName=master
[appveyor-badge]: https://ci.appveyor.com/api/projects/status/rvbve3ajjtn4m0n2?svg=true
[appveyor-build]: https://ci.appveyor.com/project/devblackops/operation-validation-framework-a635v
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/operationvalidation.svg
[psgallery]: https://www.powershellgallery.com/packages/operationvalidation
[license-badge]: https://img.shields.io/github/license/powerShell/operation-validation-framework.svg
[license]: https://raw.githubusercontent.com/PowerShell/Operation-Validation-Framework/master/LICENSE