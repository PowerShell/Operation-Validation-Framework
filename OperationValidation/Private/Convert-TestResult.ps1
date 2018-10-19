
# Emit an object which can be used in reporting
Function Convert-TestResult {
    param (
        [Parameter(Mandatory)]
        $result,

        [string]$ModuleName
    )

    foreach ($testResult in $result.TestResult) {
        $testError = $null
        if ($testResult.Result -eq 'Failed') {
            Write-Verbose -message 'Creating error object'
            $testError = New-OperationValidationFailure -Stacktrace $testResult.StackTrace -FailureMessage $testResult.FailureMessage
        }

        $TestName = '{0}:{1}:{2}' -f $testResult.Describe, $testResult.Context, $testResult.Name

        $newOVResultParams = @{
            Name      = $TestName
            FileName  = $result.path
            Result    = $testresult.result
            RawResult = $testResult
            Error     = $TestError
        }
        if (-not [string]::IsNullOrEmpty($ModuleName)) {
            $newOVResultParams.Module = $ModuleName
        }
        New-OperationValidationResult @newOVResultParams
    }
}
