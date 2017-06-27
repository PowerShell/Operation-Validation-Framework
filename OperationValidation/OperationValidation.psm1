
# Dot source public/private functions
$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
foreach($import in @($public + $private)) {
    . $import.fullname
}

Export-ModuleMember -Function $public.Basename
