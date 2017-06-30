
# emit an object which can be used in reporting
Function Convert-TestResult
{
    param ( $result )
    foreach ( $testResult in $result.TestResult )
    {
        $testError = $null
        if ( $testResult.Result -eq "Failed" )
        {
            Write-Verbose -message "Creating error object"
            $testError = new-OperationValidationFailure -Stacktrace $testResult.StackTrace -FailureMessage $testResult.FailureMessage
        }
        $Module = $result.Path.split([io.path]::DirectorySeparatorChar)[-4]
        $TestName = "{0}:{1}:{2}" -f $testResult.Describe,$testResult.Context,$testResult.Name
        New-OperationValidationResult -Module $Module -Name $TestName -FileName $result.path -Result $testresult.result -RawResult $testResult -Error $TestError
    }
}
