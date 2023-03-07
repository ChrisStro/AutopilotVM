function Get-AutopilotVm.profiles {
    $profilesPath = Join-Path (Get-AutopilotVM.folder) "AutoPilotProfile"

    Get-ChildItem $profilesPath | Get-Content -raw | ConvertFrom-Json |
    Select-Object @{Name = 'ProfileName'; Expression= {$_.Comment_File -replace 'Profile ',''}}, `
    ZtdCorrelationId,CloudAssignedDeviceName,CloudAssignedTenantDomain, `
    @{Name = 'dyn_expression'; Expression = {"(device.enrollmentProfileName -eq `"OfflineAutopilotProfile-$($_.ZtdCorrelationId)`") or (device.enrollmentProfileName -eq `"$($_.Comment_File -replace 'Profile ','')`")"}}
}