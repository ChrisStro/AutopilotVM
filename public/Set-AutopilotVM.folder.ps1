function Set-AutopilotVM.folder {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    process {
        try {
            $ErrorActionPreference = "stop"

            $newPath = Get-Item $Path
            if (!$newPath.PSIsContainer) {
                throw "Path has to be a folder"
            }

            $newPath.FullName | ConvertTo-Json | Out-File "$AutopilotVMPath\folder.json" -Encoding ASCII
            $AutopilotVMProv = $newPath.FullName
        } catch {
            Out-Error
            break
        }
    }
}