function Test-AutopilotVM.folder {
    $result = ![string]::IsNullOrEmpty($AutopilotVMProv.folder)
    if ($result) {
        $result = Test-Path $AutopilotVMProv.folder
    }
    $result
}