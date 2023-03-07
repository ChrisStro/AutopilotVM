function Clear-AutopilotVM.Vm {
    [CmdletBinding()]
    param ()

    begin {}

    process {
        Get-ChildItem (Join-Path (Get-AutopilotVM.folder) "vm") | Select-Object -ExpandProperty Name |
        Out-GridView -Title "Select VM to delete" -PassThru | Get-VM | ForEach-Object {
            $vmFolder = Join-Path (Get-AutopilotVM.folder) "vm\$($_.Name)"
            stop-vm $_ -Force
            $_ | Get-VMHardDiskDrive | Remove-Item -Force
            Remove-VM $_ -Force
            Remove-Item $vmFolder -Recurse -Force
        }
    }

    end {}
}