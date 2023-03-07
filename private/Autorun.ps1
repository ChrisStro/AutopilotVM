function Disable-Autorun {
    $path ='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer'
    Set-ItemProperty $path -Name NoDriveTypeAutorun -Type DWord -Value 0xFF | Out-Null
}
function Enable-Autorun {
    $path ='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer'
    Remove-ItemProperty $path -Name NoDriveTypeAutorun | Out-Null
}