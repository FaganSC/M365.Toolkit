function Get-M365ToolkitInfo {
    <#
    .SYNOPSIS
        Returns basic information about the M365.Toolkit module.
    .DESCRIPTION
        Sample public function demonstrating the module structure. Replace with real
        M365 Toolkit functionality.
    .EXAMPLE
        Get-M365ToolkitInfo
    #>
    [CmdletBinding()]
    param()

    [PSCustomObject]@{
        ModuleName = 'M365.Toolkit'
        Version    = (Get-Module -Name M365.Toolkit).Version
        Loaded     = (Get-Date)
    }
}
