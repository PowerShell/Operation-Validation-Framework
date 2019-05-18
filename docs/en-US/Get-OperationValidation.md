---
external help file: OperationValidation-help.xml
Module Name: OperationValidation
online version:
schema: 2.0.0
---

# Get-OperationValidation

## SYNOPSIS
Retrieve the operational tests from modules

## SYNTAX

### ModuleName (Default)
```
Get-OperationValidation [[-Name] <String[]>] [-TestType <String[]>] [-Version <Version>] [-Tag <String[]>]
 [-ExcludeTag <String[]>] [<CommonParameters>]
```

### Path
```
Get-OperationValidation [-Path] <String[]> [-TestType <String[]>] [-Version <Version>] [-Tag <String[]>]
 [-ExcludeTag <String[]>] [<CommonParameters>]
```

### LiteralPath
```
Get-OperationValidation [-LiteralPath] <String[]> [-TestType <String[]>] [-Version <Version>] [-Tag <String[]>]
 [-ExcludeTag <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Modules which include a Diagnostics directory are inspected for
Pester tests in either the "Simple" or "Comprehensive" subdirectories.
If files are found in those directories, they will be inspected to determine
whether they are Pester tests.
If Pester tests are found, the
test names in those files will be returned.

The module structure required is as follows:

ModuleBase\
    Diagnostics\
        Simple         # simple tests are held in this location
                        (e.g., ping, serviceendpoint checks)
        Comprehensive  # comprehensive scenario tests should be placed here

## EXAMPLES

### EXAMPLE 1
```
Get-OperationValidation -Name OVF.Windows.Server
```

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

### EXAMPLE 2
```
$tests = Get-OperationValidation
```

Search in all modules found in $env:PSModulePath for OVF tests.

### EXAMPLE 3
```
$tests = Get-OperationValidation -Path C:\MyTests
```

Search for OVF modules under c:\MyTests

### EXAMPLE 4
```
$simpleTests = Get-OperationValidation -ModuleName OVF.Windows.Server -TypeType Simple
```

Get just the simple tests in the OVF.Windows.Server module.

### EXAMPLE 5
```
$tests = Get-OperationValidation -ModuleName OVF.Windows.Server -Version 1.0.2
```

Get all the tests from version 1.0.2 of the OVF.Windows.Server module.

### EXAMPLE 6
```
$storageTests = Get-OperationValidation -Tag Storage
```

Search in all modules for OVF tests that include the tag Storage.

### EXAMPLE 7
```
$tests = Get-OperationValidation -ExcludeTag memory
```

Search for OVF tests that don't include the tag Memory

## PARAMETERS

### -Name
One or more module names to inspect and return if they adhere to the OVF Pester test structure.

By default this is \[*\] which will inspect all modules in $env:PSModulePath.

```yaml
Type: String[]
Parameter Sets: ModuleName
Aliases: ModuleName

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
One or more paths to search for OVF modules in.
This bypasses searching the directories contained in $env:PSModulePath.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -LiteralPath
One or more literal paths to search for OVF modules in.
This bypasses searching the directories contained in $env:PSModulePath.

Unlike the Path parameter, the value of LiteralPath is used exactly as it is typed.
No characters are interpreted as wildcards.
If the path includes escape characters, enclose it in single quotation marks.
Single quotation
marks tell PowerShell not to interpret any characters as escape sequences.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases: PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TestType
The type of tests to retrieve, this may be either "Simple", "Comprehensive", or Both ("Simple,Comprehensive").
"Simple, Comprehensive" is the default.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @('Simple', 'Comprehensive')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
The version of the module to retrieve.
If not specified, the latest version
of the module will be retured.

```yaml
Type: Version
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Executes tests with specified tag parameter values.
Wildcard characters and tag values that include spaces
or whitespace characters are not supported.

When you specify multiple tag values, Get-OperationValidation executes tests that have any of the
listed tags.
If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeTag
Omits tests with the specified tag parameter values.
Wildcard characters and tag values that include spaces
or whitespace characters are not supported.

When you specify multiple ExcludeTag values, Get-OperationValidation omits tests that have any
of the listed tags.
If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Invoke-OperationValidation]()

