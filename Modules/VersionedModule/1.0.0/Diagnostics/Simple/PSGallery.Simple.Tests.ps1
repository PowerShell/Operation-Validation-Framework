param(
    [string]$WebsiteUrl = 'https://www.powershellgallery.com',
    [string]$StatusCode = 'OK'
)


Describe 'Simple Validation of PSGallery' -Tag 'AAABBBCCC' {
    It 'The PowerShell Gallery should be responsive' {
        $request = [System.Net.WebRequest]::Create($WebsiteUrl)
        $response = $Request.GetResponse()
        $response.StatusCode | Should Be $StatusCode
    }

    it 'Has correct test parameters' {
        $WebsiteUrl | Should Be 'https://www.powershellgallery.com'
        $StatusCode | Should Be 'OK'
    }
}
