Describe 'Simple Validation of PSGallery' {
    It 'The PowerShell Gallery should be responsive' {
        $request = [System.Net.WebRequest]::Create('https://www.powershellgallery.com')
        $response = $Request.GetResponse()
        $response.StatusCode | Should be OK
    }
}

Describe 'Simple Validation of Microsoft' {
    It 'Microsoft should be responsive' {
        $request = [System.Net.WebRequest]::Create('https://www.microsoft.com')
        $response = $Request.GetResponse()
        $response.StatusCode | Should be OK
    }
}