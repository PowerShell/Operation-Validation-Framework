Describe 'Simple Validation of PSGallery' -Tag 'AAABBBCCC' {
    It 'The PowerShell Gallery should be responsive' {
        $request = [System.Net.WebRequest]::Create('https://www.powershellgallery.com')
        $response = $Request.GetResponse()
        $response.StatusCode | Should be OK
    }
}

Describe 'Simple Validation of Microsoft' -Tag 'AAABBBCCC', 'XXXYYYZZZ' {
    It 'Microsoft should be responsive' {
        $request = [System.Net.WebRequest]::Create('https://www.microsoft.com')
        $response = $Request.GetResponse()
        $response.StatusCode | Should be OK
    }
}


Describe 'Simple Validation of Github' -Tag 'JJJKKKLLL' {
    It 'GitHub should be responsive' {
        $request = [System.Net.WebRequest]::Create('https://www.github.com')
        $response = $Request.GetResponse()
        $response.StatusCode | Should be OK
    }
}
