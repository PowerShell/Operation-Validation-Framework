Describe "E2E validation of PSGallery" {
    BeforeAll {
        $Repository = "InternalPSGallery"
        $ModuleName = "FormatTools"
        $Version = "0.5.0"
        import-module PowerShellGet -Force
        if ( Get-Module -list ${ModuleName} )
        {
            # the module is already installed
            $PSDefaultParameterValues["It:skip"] = $true
        } 
    }

    It "should return the same number of modules via cmdlets and website" {
        $GalleryUrl = "http://psget/psgallery"
        # timing window here - between these two operations, modules list may change
        $wc = new-object System.Net.WebClient
        $modules = Find-Module -Repository InternalPSGallery -ea SilentlyContinue
        $page = $wc.downloadstring("${GalleryUrl}/packages").replace("`n","")
        $expectedCount = $page -replace ".*There are (\d+) modules.*",'$1'
        $modules.Count | Should be $expectedCount
    }
    It -skip:$false "Should be possible to find a known module" {
        $myModule = find-module -repository ${Repository} -Name ${ModuleName} -RequiredVersion ${Version}
        $myModule.Name | Should be ${ModuleName}
        $myModule.Version | Should be $Version
    }
    It "Should be possible to install and import a known module" {
        install-module -Force -Name ${ModuleName} -RequiredVersion ${Version} -Repository ${Repository} -Scope CurrentUser
        $m = Import-Module ${ModuleName} -PassThru
        $m.ModuleBase.IndexOf($HOME) | Should be 0
    }
    AfterAll {
        if ( $PSDefaultParameterValues["It:skip"] -ne $true)
        {
            Uninstall-Module -force -RequiredVersion ${version} -Name ${ModuleName} -ea SilentlyContinue
        }
    }
}

