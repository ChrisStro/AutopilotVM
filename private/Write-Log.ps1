Function Write-Log {
    param(
        [string]$TextBlock,
        [parameter(mandatory=$false,HelpMessage="Enter text for output")]
        [ValidateSet("Start","Notify","Finish")]
        $State
    )
    switch ($State) {
        "Start"{$Color = "cyan"}
        "Notify"{$Color = "yellow"}
        "Finish"{$Color = "green"}
        Default{$Color = "" }
    }
    $Logdate = Get-Date -Format g
    if (!$Section) {$Section = $PSCommandPath | Split-Path -Leaf -ErrorAction SilentlyContinue}
    #set parameter Hashtable
    $Parameter = @{
        object = "[$Logdate] [$Section - $TextBlock]"
    }
    if($State){$Parameter.ForegroundColor = $Color}

    Write-Host  @Parameter
}