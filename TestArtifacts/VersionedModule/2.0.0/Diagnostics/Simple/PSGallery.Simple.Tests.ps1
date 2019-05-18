Describe 'Simple Validation of PSGallery' -Tag 'AAABBBCCC' {
    It 'The PowerShell Gallery should be responsive' {
        $response = Invoke-WebRequest -Uri 'https://www.powershellgallery.com' -UseBasicParsing
        $response.StatusCode | Should be 200
    }
}

Describe 'Simple Validation of Microsoft' -Tag 'AAABBBCCC', 'XXXYYYZZZ' {
    It 'Microsoft should be responsive' {
        $response = Invoke-WebRequest -Uri 'https://www.microsoft.com' -UseBasicParsing
        $response.StatusCode | Should be 200
    }
}


Describe 'Simple Validation of Github' -Tag 'JJJKKKLLL' {
    It 'GitHub should be responsive' {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $response = Invoke-WebRequest -Uri 'https://www.github.com' -UseBasicParsing
        $response.StatusCode | Should be 200
    }
}
