---
external help file: OperationValidation-help.xml
Module Name: OperationValidation
online version:
schema: 2.0.0
---

# Invoke-OperationValidation

## SYNOPSIS
Invoke the operational tests from modules

## SYNTAX

### FileAndTest (Default)
```
Invoke-OperationValidation [-TestInfo <PSObject[]>] [-IncludePesterOutput] [-Overrides <Hashtable>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### TestFile
```
Invoke-OperationValidation [-TestFilePath <String[]>] [-IncludePesterOutput] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### UseGetOperationTest
```
Invoke-OperationValidation [-ModuleName <String[]>] [-TestType <String[]>] [-IncludePesterOutput]
 [-Version <Version>] [-Overrides <Hashtable>] [-Tag <String[]>] [-ExcludeTag <String[]>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Path
```
Invoke-OperationValidation [-Path] <String[]> [-TestType <String[]>] [-IncludePesterOutput]
 [-Version <Version>] [-Overrides <Hashtable>] [-Tag <String[]>] [-ExcludeTag <String[]>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### LiteralPath
```
Invoke-OperationValidation [-LiteralPath] <String[]> [-TestType <String[]>] [-IncludePesterOutput]
 [-Version <Version>] [-Overrides <Hashtable>] [-Tag <String[]>] [-ExcludeTag <String[]>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Modules which include Diagnostics tests are executed via this cmdlet

## EXAMPLES

### EXAMPLE 1
```
Get-OperationValidation -ModuleName OperationValidation | Invoke-OperationValidation -IncludePesterOutput
```

Describing Simple Test Suite
\[+\] first Operational test 20ms
\[+\] second Operational test 19ms
\[+\] third Operational test 9ms
Tests completed in 48ms
Passed: 3 Failed: 0 Skipped: 0 Pending: 0
Describing Scenario targeted tests
Context The RemoteAccess service
    \[+\] The service is running 37ms
Context The Firewall Rules
    \[+\] A rule for TCP port 3389 is enabled 1.19s
    \[+\] A rule for UDP port 3389 is enabled 11ms
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

## PARAMETERS

### -TestFilePath
The path to a diagnostic test to execute.
By default all discoverable diagnostics will be invoked

```yaml
Type: String[]
Parameter Sets: TestFile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TestInfo
The type of tests to invoke, this may be either "Simple", "Comprehensive"
or Both ("Simple,Comprehensive").
"Simple,Comprehensive" is the default.

```yaml
Type: PSObject[]
Parameter Sets: FileAndTest
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ModuleName
By default this is * which will retrieve and execute all OVF modules in $env:psmodulepath
Additional module directories may be added.
If you wish to check both
$env:psmodulepath and your own specific locations, use
*,\<yourmodulepath\>

```yaml
Type: String[]
Parameter Sets: UseGetOperationTest
Aliases:

Required: False
Position: Named
Default value: None
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
The type of tests to execute, this may be either "Simple", "Comprehensive"
or Both ("Simple,Comprehensive").
"Simple,Comprehensive" is the default.

```yaml
Type: String[]
Parameter Sets: UseGetOperationTest, Path, LiteralPath
Aliases:

Required: False
Position: Named
Default value: @('Simple', 'Comprehensive')
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePesterOutput
Include the Pester output when execute the tests.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
The version of the module to retrieve.
If the specified, the latest version
of the module will be retured.

```yaml
Type: Version
Parameter Sets: UseGetOperationTest, Path, LiteralPath
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Overrides
If the Pester test(s) include script parameters, those parameters can be overridden by
specifying a hashtable of values.
The key(s) in the hashtable must match the parameter
names in the Pester test.

For example, if the Pester test includes a parameter block like the following, one or more of
these parameters can be overriden using values from the hashtable passed to the -Overrides parameter.

Pester test script:
param(
    \[int\]$SomeValue = 100
    \[bool\]$ExtraChecks = $false
)

Overrides the default parameter values:
Invoke-OperationValidation -ModuleName MyModule -Overrides @{ SomeValue = 500; ExtraChecks = $true }

```yaml
Type: Hashtable
Parameter Sets: FileAndTest, UseGetOperationTest, Path, LiteralPath
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

When you specify multiple tag values, Invoke-OperationValidation executes tests that have any of the
listed tags.
If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

```yaml
Type: String[]
Parameter Sets: UseGetOperationTest, Path, LiteralPath
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
Parameter Sets: UseGetOperationTest, Path, LiteralPath
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

[Get-OperationValidation]()

