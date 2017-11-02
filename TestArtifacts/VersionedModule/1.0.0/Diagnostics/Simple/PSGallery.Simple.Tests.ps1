param(
    [string]$WebsiteUrl = 'https://www.powershellgallery.com',
    [string]$StatusCode = 200
)

Describe 'Simple Validation of PSGallery' -Tag 'AAABBBCCC' {
    It 'The PowerShell Gallery should be responsive' {
        $response = Invoke-WebRequest -Uri $WebsiteUrl -UseBasicParsing
        $response.StatusCode | Should Be $StatusCode
    }

    it 'Has correct test parameters' {
        $WebsiteUrl | Should Be 'https://www.powershellgallery.com'
        $StatusCode | Should Be 200
    }
}
