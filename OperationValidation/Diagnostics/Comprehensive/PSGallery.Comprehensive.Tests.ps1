
Describe 'E2E validation of PSGallery' -Fixture {
    BeforeAll {
        $repository = 'PSGallery'
        $moduleName = 'FormatTools'
        $version = '0.5.0'
        if (Get-Module -Name $moduleName -ListAvailable) {
            # the module is already installed
            $PSDefaultParameterValues['It:skip'] = $true
        }
    }

    # It 'should return the same number of modules via cmdlets and website' {
    #     $galleryUrl = 'https://www.powershellgallery.com'
    #     # timing window here - between these two operations, modules list may change
    #     $wc = New-Object System.Net.WebClient
    #     $modules = Find-Module -Repository $repository -ErrorAction SilentlyContinue
    #     $page = $wc.downloadstring("${galleryUrl}/packages").replace("`n", '')
    #     $expectedCount = $page -replace ".*There are (\d+) modules.*", '$1'
    #     $modules.Count | Should be $expectedCount
    # }
    It -skip:$false 'Should be possible to find a known module' {
        $myModule = Find-Module -Repository $repository -Name $moduleName -RequiredVersion $version
        $myModule.Name    | Should be $moduleName
        $myModule.Version | Should be $version
    }
    It 'Should be possible to install and import a known module' {
        Install-Module -Force -Name $moduleName -RequiredVersion $version -Repository $repository -Scope CurrentUser
        $m = Import-Module $moduleName -PassThru
        $m.ModuleBase.IndexOf($HOME) | Should be 0
    }

    AfterAll {
        if ($PSDefaultParameterValues['It:skip'] -ne $true) {
            Uninstall-Module -Force -RequiredVersion $version -Name $ModuleName -ErrorAction SilentlyContinue
        }
    }
}

