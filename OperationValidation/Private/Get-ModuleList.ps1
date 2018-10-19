function Get-ModuleList {
    [cmdletbinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(
            Mandatory,
            ParameterSetName = 'Name'
        )]
        [string[]]$Name,

        [Parameter(
            Mandatory,
            ParameterSetName = 'Path'
        )]
        [string[]]$Path,

        [version]$Version
    )

    if ($PSCmdlet.ParameterSetName -eq 'Name') {
        $pathsToSearch = $env:PSModulePath.Trim($script:pathSeparator).Split($script:pathSeparator)
    } elseIf ($PSCmdlet.ParameterSetName -eq 'Path') {
        $pathsToSearch = $Path
    }

    foreach($p in $pathsToSearch) {
        if (Test-Path -Path $p) {
            foreach($modDir in Get-ChildItem -Path $p -Directory) {
                Write-Debug "Checking for OVF in [$modDir]"

                if ($PSCmdlet.ParameterSetName -eq 'Path') {
                    $Name = $modDir.Name
                }

                foreach ($n in $Name) {
                    if ($modDir.Name -like $n) {
                        # now determine if there's a diagnostics directory, or a version
                        if (Test-Path -Path (Join-Path -Path $modDir.FullName -ChildPath 'Diagnostics')) {
                            # Did we specify a specific version to find?
                            if ($PSBoundParameters.ContainsKey('Version')) {
                                $manifestFile = Get-ChildItem -Path $modDir.FullName -Filter "$($modDir.Name).psd1" | Select-Object -First 1
                                if ($manifestFile -and (Test-Path -Path $manifestFile.FullName)) {
                                    Write-Verbose $manifestFile
                                    $manifest = Test-ModuleManifest -Path $manifestFile.FullName -Verbose:$false
                                    if ($manifest.Version -eq $Version) {
                                        $modDir.FullName
                                        break
                                    }
                                }
                            } else {
                                $modDir.FullName
                                break
                            }
                        }

                        # Get latest version if no specific version specified
                        if ($PSBoundParameters.ContainsKey('Version')) {
                            $versionDirectories = Get-Childitem -Path $modDir.FullName -Directory |
                                Where-Object { $_.name -as [version] -and $_.Name -eq $Version }
                        } else {
                            $versionDirectories = Get-Childitem -Path $modDir.FullName -Directory |
                                Where-Object { $_.name -as [version] }
                        }

                        $potentialDiagnostics = $versionDirectories | Where-Object {
                            Test-Path -Path (Join-Path -Path $_.FullName -ChildPath 'Diagnostics')
                        }
                        # Now select the most recent module path which has diagnostics
                        $DiagnosticDir = $potentialDiagnostics |
                            Sort-Object {$_.name -as [version]} |
                            Select-Object -Last 1
                        if ($DiagnosticDir) {
                            $DiagnosticDir.FullName
                            break
                        }
                    }
                }
            }
        } else {
            Write-Error -Message "Could not access [$p]. Does it exist?"
        }
    }
}
