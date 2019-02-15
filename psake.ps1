
properties {
    $projectRoot = $ENV:BHProjectPath
    if(-not $projectRoot) {
        $projectRoot = $PSScriptRoot
    }

    $sut = $env:BHModulePath
    $tests = Join-Path -Path $projectRoot -ChildPath 'Tests'
    $outputDir = Join-Path -Path $projectRoot -ChildPath 'out'
    if (-not (Test-Path -Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory
    }
    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
}

task default -depends Test

task Init {
    "`nSTATUS: Testing with PowerShell $($PSVersionTable.PSVersion.Major)"
    'Build System Details:'
    Get-Item ENV:BH*
} -description 'Initialize build environment'

task Test -Depends Init, Analyze, Pester -description 'Run test suite'

task Analyze -Depends Init {
    $analysis = Invoke-ScriptAnalyzer -Path $env:BHModulePath -Verbose:$false
    $errors = $analysis | Where-Object {$_.Severity -eq 'Error'}
    $warnings = $analysis | Where-Object {$_.Severity -eq 'Warning'}

    if (($errors.Count -eq 0) -and ($warnings.Count -eq 0)) {
        '    PSScriptAnalyzer passed without errors or warnings'
    }

    if (@($errors).Count -gt 0) {
        Write-Error -Message 'One or more Script Analyzer errors were found. Build cannot continue!'
        $errors | Format-Table
    }

    if (@($warnings).Count -gt 0) {
        Write-Warning -Message 'One or more Script Analyzer warnings were found. These should be corrected.'
        $warnings | Format-Table
    }
} -description 'Run PSScriptAnalyzer'

task Pester-Meta -depends Init {
    $testResultsXml = Join-Path -Path $outputDir -ChildPath 'testResults_meta.xml'
    $testResults = Invoke-Pester -Path (Join-Path -Path $tests -ChildPath 'Meta') -PassThru -OutputFile $testResultsXml -OutputFormat NUnitXml
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester meta tests failed. Build cannot continue!'
    }
} -description 'Run Pester meta tests'

task Pester-Unit -depends Init {
    $testResultsXml = Join-Path -Path $outputDir -ChildPath 'testResults_unit.xml'
    $testResults = Invoke-Pester -Path (Join-Path -Path $tests -ChildPath 'Unit') -PassThru -OutputFile $testResultsXml -OutputFormat NUnitXml
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester unit tests failed. Build cannot continue!'
    }
} -description 'Run Pester unit tests'

task Pester -Depends Pester-Meta, Pester-Unit {
} -description 'Run all Pester tests'
