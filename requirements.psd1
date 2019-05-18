@{
    PSDependOptions = @{
        Target = 'CurrentUser'
    }
    BuildHelpers     = 'latest'
    Pester           = @{
        Version = 'latest'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    PowerShellBuild  = '0.3.0'
    psake            = 'latest'
    PSScriptAnalyzer = 'latest'
}