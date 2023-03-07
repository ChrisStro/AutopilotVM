$Script:AutopilotVMPath = "$env:ProgramData\AutopilotVM"
# public
Get-ChildItem $PSScriptRoot\Public -Include *.ps1 -Recurse | ForEach-Object {
. $_.FullName;
Export-ModuleMember -Function $_.BaseName
}
Get-ChildItem $PSScriptRoot\Private -Include *.ps1 -Recurse | ForEach-Object {
. $_.FullName
}

# Export-ModuleMember -Function *-*