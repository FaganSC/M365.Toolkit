function Copy-SP365Nav {
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