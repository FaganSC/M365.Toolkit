function Copy-SP365Nav {
    <#
    .SYNOPSIS
        Copies SharePoint navigation nodes between navigation locations or sites.

    .DESCRIPTION
        Reads the navigation hierarchy from a source location and recreates it in
        a target location. Existing target navigation is cleared by default.

        Provide SourceSite and TargetSite for a cross-site copy. Set SameSite to
        true to copy between navigation locations in the source site.

    .PARAMETER SourceSite
        The absolute URL of the SharePoint site from which navigation is read.

    .PARAMETER TargetSite
        The absolute URL of the destination SharePoint site. Provide this
        parameter unless SameSite is true.

    .PARAMETER SameSite
        Indicates that the source and target navigation locations belong to the
        source site. The command does not establish a separate target connection
        when this value is true.

    .PARAMETER ClearTargetNav
        Controls whether existing target navigation nodes are removed before the
        source nodes are added. The default value is true.

    .PARAMETER SourceNavigationLocation
        The PnP navigation location from which nodes are read, such as QuickLaunch
        or TopNavigationBar.

    .PARAMETER TargetNavigationLocation
        The PnP navigation location to which nodes are added, such as QuickLaunch
        or TopNavigationBar.

    .EXAMPLE
        Copy-SP365Nav -SourceSite 'https://contoso.sharepoint.com/sites/source' `
            -TargetSite 'https://contoso.sharepoint.com/sites/target' `
            -SourceNavigationLocation QuickLaunch `
            -TargetNavigationLocation QuickLaunch

        Copies Quick Launch navigation between two SharePoint sites.

    .EXAMPLE
        Copy-SP365Nav -SourceSite 'https://contoso.sharepoint.com/sites/operations' `
            -SameSite $true `
            -SourceNavigationLocation QuickLaunch `
            -TargetNavigationLocation TopNavigationBar `
            -ClearTargetNav $false

        Appends Quick Launch nodes to the top navigation in the same site.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .NOTES
        The source navigation is not modified. Use Move-SP365Nav to remove the
        source navigation after populating the target.
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$SourceSite,
        [parameter(Mandatory = $false)]
        [string]$TargetSite,
        [bool]$SameSite = $false,
        [bool]$ClearTargetNav = $true,
        [PnP.Framework.Enums.NavigationType]$SourceNavigationLocation,
        [PnP.Framework.Enums.NavigationType]$TargetNavigationLocation
    ) 
    Begin {
        $isVerbose = $VerbosePreference -ne 'SilentlyContinue'
        Write-Verbose "Starting Copy-SP365Nav function"
        Write-Debug "SourceSite: $SourceSite, TargetSite: $TargetSite, SameSite: $SameSite, ClearTargetNav: $ClearTargetNav, SourceNavigationLocation: $SourceNavigationLocation, TargetNavigationLocation: $TargetNavigationLocation"
        $privatePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath "private"
        Write-Verbose "Private path set to $privatePath"
        @(Get-ChildItem -Path $privatePath -Recurse -Filter "*.ps1") | ForEach-Object {
            try {
                . $_.FullName
            }
            catch {
                Write-Verbose "Failed to source $($_.FullName): $($_.Exception.Message)"
            
            }
        }
        Test-ForModuleUpdate
        Write-Verbose "Initialization complete"
        if (-not $SourceSite -and -not $TargetSite) {
            throw "At least one of the parameters (`$SourceSite or `$TargetSite) must be provided."
        }
    }
    Process {
        try {
            Connect-SP365 -Url $SourceSite
            Write-Host "Starting to retrieve navigation from source site"
            $siteNav = Get-SiteNav -NavigationNodeLocation $SourceNavigationLocation
            Write-Host "Finished retrieving navigation from source site"
            Write-Host "Total navigation nodes retrieved: $($siteNav.Count)"
            Write-Host ""
            
            if (-not $SameSite) {
                Connect-SP365 -Url $TargetSite
            }
            if ($ClearTargetNav) {
                Clear-SiteNav -Location $TargetNavigationLocation
            }
            Add-SiteNav -newNavNodes $siteNav -Location $TargetNavigationLocation
        }
        catch {
            Write-Verbose "An error occurred: $($_.Exception.Message)"
        }
    }
}