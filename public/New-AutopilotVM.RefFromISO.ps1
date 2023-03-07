function New-AutopilotVM.RefFromISO {
    [CmdletBinding()]
    param(
        [parameter(mandatory = $True, HelpMessage = "Path and name of ISO File file.")]
        [ValidateNotNullOrEmpty()]
        $ISOPath,

        [ValidateRange(1, 10)]
        [int]$WimIndex
    )

    begin {
        $Section = "Apply windows image offline"
    }

    process {
        try {
            $ErrorActionPreference = "stop"
            $VHDXFile = Join-Path (Get-AutopilotVM.folder) "Ref\Win_Client.vhdx"

            Write-Log -State Start "Apply windows image..."
            $ISO = Mount-DiskImage -ImagePath $ISOPath -PassThru
            Start-Sleep -Seconds 3
            Write-Log "Mounting $ISOPath done..."
            $SourcePath = "$(($ISO | Get-Volume).DriveLetter):\"
            $Wimfile = Join-Path -Path "$SourcePath" -ChildPath "sources\install.wim"
            if (-not $WimIndex) {
                $WimIndex = Get-WindowsImage -ImagePath $Wimfile | Out-GridView -Title "Select Image" -PassThru | Select-Object -ExpandProperty ImageIndex
            }

            # Check for VHDX/Image selection
            $VHDFileCheck = Test-Path $VHDXFile
            if (!$VHDFileCheck) {
                Write-Log -State Notify "File does not exist, create new one"
                New-VHD -Path $VHDXFile -Dynamic -SizeBytes 80GB | Out-Null
            }
            if (!$WimIndex) {
                Write-Log -State Notify "No Windowsimage selected..."
                break
            }

            # Create VHDX
            Disable-Autorun # disable autorun before mounting vhdx

            Mount-DiskImage -ImagePath $VHDXFile | Out-Null
            $VHDXDisk = Get-DiskImage -ImagePath $VHDXFile | Get-Disk
            $VHDXDiskNumber = [string]$VHDXDisk.Number

            # Format VHDx
            Write-Log "Formating VHDX"
            Initialize-Disk -Number $VHDXDiskNumber -PartitionStyle GPT | Out-Null
            $VHDXDrive1 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -Size 499MB
            $VHDXDrive1 | Format-Volume -FileSystem FAT32 -NewFileSystemLabel System -Confirm:$false | Out-Null
            $VHDXDrive2 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' -Size 128MB
            $VHDXDrive3 = New-Partition -DiskNumber $VHDXDiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -UseMaximumSize
            $VHDXDrive3 | Format-Volume -FileSystem NTFS -NewFileSystemLabel OSDisk -Confirm:$false | Out-Null
            Add-PartitionAccessPath -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive1.PartitionNumber -AssignDriveLetter
            $VHDXDrive1 = Get-Partition -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive1.PartitionNumber
            Add-PartitionAccessPath -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive3.PartitionNumber -AssignDriveLetter
            $VHDXDrive3 = Get-Partition -DiskNumber $VHDXDiskNumber -PartitionNumber $VHDXDrive3.PartitionNumber
            $VHDXVolume1 = [string]$VHDXDrive1.DriveLetter + ":"
            $VHDXVolume3 = [string]$VHDXDrive3.DriveLetter + ":"

            # Apply Image
            Write-Log "Apply image : [Index : $WimIndex] [Wimfile : $WIMfile]"
            Expand-WindowsImage -ImagePath $WIMfile -Index $WimIndex -ApplyPath $VHDXVolume3\ | Out-Null

            # Apply BootFiles
            cmd /c "$VHDXVolume3\Windows\system32\bcdboot $VHDXVolume3\Windows /s $VHDXVolume1 /f UEFI" | Out-Null

            "
            select disk $VHDXDiskNumber
            select partition 2
            Set ID=c12a7328-f81f-11d2-ba4b-00a0c93ec93b OVERRIDE
            GPT Attributes=0x8000000000000000
            " | & $env:SystemRoot\System32\DiskPart.exe | Out-Null

            Write-Log -State Finish "VHDX done"

        } catch {
            Out-Error
            break
        } finally {
            Enable-Autorun # enable autorun again
            if ($VHDXDisk) {
                # Dismount VHDX
                Dismount-DiskImage -ImagePath $VHDXFile | Out-Null
            }
            if ($ISO) {
                # Dismount ISO
                $ISO | Dismount-DiskImage | Out-Null
            }
        }
    }
}