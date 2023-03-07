function Save-AutopilotVm.profiles {
    param ()

    # var
    $workSpace = Get-AutopilotVM.folder

    # check for needed module
    $autoPilotModule = Get-InstalledModule -Name WindowsAutoPilotIntune -ErrorAction SilentlyContinue
    if (!$autoPilotModule) { Install-Module -Name WindowsAutoPilotIntune -Force -Confirm:$false }

    # retrieve all profiles
    Import-Module -Name WindowsAutoPilotIntune -Force | Out-Null
    Connect-MSGraph -Quiet

    $profileList = Get-AutopilotProfile

    if (!$profileList) { Write-Warning "Sry, no profiles retrieved, cancel..."; break }

    $profileList | ForEach-Object {
        $name = $_.displayName
        $autopilotConfigFile = "$name" + ".json"
        Write-Host "Create autopilot json file for [$name]"

        $_ | ConvertTo-AutopilotConfigurationJSON | Out-File "$workSpace\AutoPilotProfile\$autopilotConfigFile" -Encoding ascii
    }
}