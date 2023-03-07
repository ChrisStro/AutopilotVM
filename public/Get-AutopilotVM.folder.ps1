function Get-AutopilotVM.folder {
    $section = "Load folder for AutopilotVM"
    $configJson = "$AutopilotVMPath\folder.json"
    if (Test-Path $configJson) {
        Get-Content $configJson | ConvertFrom-Json
    }
    else {
        Write-Log -State Notify "No current config found, run [New-AutopilotVM.folder] first"
    }
}