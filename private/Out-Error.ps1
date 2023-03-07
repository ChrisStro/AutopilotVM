function Out-Error {
    $Logdate = Get-Date -Format g
    $Message    = $_.Exception.Message
    $Line       = $_.InvocationInfo.ScriptLineNumber
    Write-Host -ForegroundColor Red "[$Logdate] [$section] Error : '$Message' on Line : '$Line'"
}