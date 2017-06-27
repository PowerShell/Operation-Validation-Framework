Describe "Simple Validation of PSGallery" {
    It "The PowerShell Gallery should be responsive" {
        $request = [System.Net.WebRequest]::Create("http://psget/psgallery")
        $response = $Request.GetResponse()
        $response.StatusCode | Should be OK
    }
}

