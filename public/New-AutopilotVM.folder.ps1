function New-AutopilotVM.folder {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    process {
        try {
            $ErrorActionPreference = "stop"

            if (-not (Test-Path $Path)) {
                $newPath = New-Item -Path $Path -ItemType Directory -Force
                New-Item (Join-Path $newPath.FullName "VM") -ItemType Directory -Force | Out-Null
                New-Item (Join-Path $newPath.FullName "Ref") -ItemType Directory -Force | Out-Null
                New-Item (Join-Path $newPath.FullName "AutoPilotProfile") -ItemType Directory -Force | Out-Null
            } else {
                throw 'Folder already exists, please use Set-AutopilotVM.folder'
            }

            # store sourcepath in filesystem
            if (-not (Test-Path $AutopilotVMPath)) {
                New-Item $AutopilotVMPath -ItemType Directory -Force | Out-Null
            }
            $newPath.FullName | ConvertTo-Json | Out-File "$AutopilotVMPath\folder.json" -Encoding ASCII
        } catch {
            Out-Error
            break
        }
    }
}