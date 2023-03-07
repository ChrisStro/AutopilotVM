function Block-Elevation {
    $Elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ( -not $Elevated ) {
        throw "The AutopilotVM module requires elevation."
    }
}
