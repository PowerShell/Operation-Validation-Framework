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
    psake            = 'latest'
    PSScriptAnalyzer = 'latest'
}