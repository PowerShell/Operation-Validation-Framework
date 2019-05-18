
$script:pathSeparator = [IO.Path]::PathSeparator

# Dot source public/private functions
$public  = @( Get-ChildItem -Path ([IO.Path]::Combine($PSScriptRoot, 'Public', '*.ps1'))  -Recurse -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path ([IO.Path]::Combine($PSScriptRoot, 'Private', '*.ps1')) -Recurse -ErrorAction SilentlyContinue )
foreach($import in @($public + $private)) {
    try {
        . $import.FullName
    } catch {
        throw "Unable to dot source [$($import.FullName)]"
    }
}

Export-ModuleMember -Function $public.Basename
