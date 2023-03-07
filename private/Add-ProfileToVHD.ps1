function Add-ProfileToVHD {
    param (
        [string]$vhdpath
    )
    try {
        $section = "Adding AutopilotConfigurationFile"

        $mDrive = (Mount-VHD -Path $vhdpath -NoDriveLetter -Passthru | Get-Partition | Get-Volume | Where-Object { $_.FileSystemLabel -match "OSDisk" }).Path
        $jsonTargetPath = Join-Path $mDrive "Windows\Provisioning\Autopilot"
        $jsonTargetFile = Join-Path $jsonTargetPath "AutopilotConfigurationFile.json"

        $autopilotJson = Get-ChildItem (Join-Path (Get-AutopilotVM.folder) "AutoPilotProfile") | Out-GridView -PassThru | Select-Object -ExpandProperty Fullname
        Write-Log -State Start "Inject AutopilotConfigurationFile.json into $VMName"
        if (!(Test-Path -Path $jsonTargetPath)) {
            Write-Log "Create folder to store json file"
            New-Item -Path $jsonTargetPath -ItemType Directory -Force | Out-Null
        }
        Write-Log -State Start "Copy json file to $jsonTargetPath"
        Copy-Item -Path $autopilotJson -Destination $jsonTargetFile
    }
    catch {
        Out-Error
        break
    }
    finally {
        if ($mDrive) {
            Write-Log "Dismounting vhd of $VMName"
            Dismount-VHD -Path $vhdpath
        }
    }
}