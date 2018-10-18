
function Parse-Psd1 {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $data
    )
    $data
}
