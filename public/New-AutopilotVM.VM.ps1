function New-AutopilotVM.VM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = "Default", HelpMessage = "Name of virtual machine")]
        [string]$VMName,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = "Default", HelpMessage = "Virtual switch to attach")]
        [string]$VMSwitch = "Default Switch"
    )

    begin {
        # Precheck
        ######################
        Block-Elevation

        try {
            $parentVHDX = Join-Path (Get-AutopilotVM.folder) "Ref\Win_Client.vhdx"
            $vmVHDX = Join-Path (Get-AutopilotVM.folder) "VM\$VMName\OS-Disk_Diff.vhdx"

            $ErrorActionPreference = 'stop'

            $section = "Runing precheck "
            if (-not (Test-Path $parentVHDX)) {
                throw "Reference vhdx missing, run [New-AutopilotVM.RefFromISO] first"
            }

            $section = "Create virtual machine"
            Write-Log -State Start -Textblock "Start build process"
        } catch {
            Out-Error
            break
        }
    }

    process {
        try {
            # validate input
            Get-VMSwitch -Name $VMSwitch | Out-Null

            if (Get-VM -VMName $VMName -ErrorAction SilentlyContinue) {
                Write-Log -State Notify "Virtual machine $VMName already exists, skip build"
                return
                #throw "Virtual machine already exists"
            }

            # create vm
            $vmSplatt = @{
                VMName             = $VMName
                SwitchName         = $VMSwitch
                Generation         = 2
                MemoryStartupBytes = 4096 * 1024 * 1024
                Path               = Join-Path (Get-AutopilotVM.folder) "VM"
            }

            # handle differencing disk
            Write-Log "Create new vm with differencing vhdx"
            New-VHD -Path $vmVHDX -Differencing -ParentPath $parentVHDX | Out-Null
            $vmSplatt.VHDPath = $vmVHDX
            $vm = New-VM @VmSplatt

            # apply autopilot profile
            $vmHDD = $vm | Get-VMHardDiskDrive | Where-Object Path -Match "OS-Disk"
            Add-ProfileToVHD -vhdpath $vmVHDX

            # configure vm
            Set-VMFirmware -VM $vm -FirstBootDevice $vmHDD
            Get-VMIntegrationService -VM $vm | Enable-VMIntegrationService
            Set-VM -VM $vm -StaticMemory -ProcessorCount 4 -Notes "created_by_AutopilotVM" -AutomaticCheckpointsEnabled $false
            Set-VMKeyProtector -NewLocalKeyProtector -VM $vm; Enable-VMTPM -VM $vm

            # boot
            Write-Log "Booting virtual machine..."
            if ($ConnectVM) {
                vmconnect localhost $vmName
            }
            Start-VM -Name $VMName ; Start-Sleep -Seconds 8
        } catch {
            Out-Error
            break
        } finally {
            Write-Log -State Finish "VM $VMName done"
        }
    }
    end {}
}