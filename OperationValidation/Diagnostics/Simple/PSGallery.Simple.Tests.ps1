Describe -Name 'Simple Validation of PSGallery' {
    It 'The PowerShell Gallery should be responsive' {
        $response = Invoke-WebRequest -Uri 'https://www.powershellgallery.com'
        $response.StatusCode | Should be 200
    }
}
