function Get-M365ToolkitInfo {
    <#
    .SYNOPSIS
        Returns basic information about the M365.Toolkit module.

    .DESCRIPTION
        Returns the module name, the version of the loaded M365.Toolkit module,
        and the time at which the command was run.

    .EXAMPLE
        Get-M365ToolkitInfo

        Returns information about the currently loaded M365.Toolkit module.

    .INPUTS
        None.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

        The returned object contains ModuleName, Version, and Loaded properties.
    #>
    [CmdletBinding()]
    param()

    [PSCustomObject]@{
        ModuleName = 'M365.Toolkit'
        Version    = (Get-Module -Name M365.Toolkit).Version
        Loaded     = (Get-Date)
    }
}
