function Test-ForModuleUpdate {
    [cmdletbinding()]            
    param()
    $ModuleName = "M365.Toolkit"
    $checkedVersion = (Get-Variable -Name M365ToolkitCheckedVersion -Scope Global -ErrorAction SilentlyContinue).Value
    Write-Verbose "Checked Version: $checkedVersion"
    if ($checkedVersion -ne "Yes") {
        $currentVersion = ((Get-Module -ListAvailable | Where-Object { $_.Name -eq $ModuleName })[0] | Select-Object Version).Version.ToString()
        Write-Verbose "Current Version: $currentVersion"
        # PowerShell TestGallery API endpoint for the module
        $Url = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='$ModuleName'"

        $response = Invoke-RestMethod -Uri $Url -UseBasicParsing
        $latestGalleryVersion = ($response | Sort-Object updated -Descending | Select-Object -First 1).properties.Version
        Write-Verbose "Latest Gallery Version: $latestGalleryVersion"
        if ($currentVersion -eq $latestGalleryVersion) {
            Write-Verbose "You are using the latest version: $($currentVersion.ToString())"
        }
        if ($currentVersion -gt $latestGalleryVersion) {
            Write-Verbose "You are using an pre-release: $($currentVersion.ToString())"
            Write-Host -BackgroundColor Blue -ForegroundColor White "You are using a pre-release version of $($ModuleName)."
            Write-Host -BackgroundColor Blue -ForegroundColor White "Please check the PowerShell Gallery for the latest stable release."
        }
        elseif ($currentVersion -ne $latestGalleryVersion) {
            Write-Verbose "There is a new version available: $($latestGalleryVersion.ToString())"
            Write-Host -BackgroundColor Yellow -ForegroundColor Black "There is a new version of $($ModuleName) available."
            Write-Host -BackgroundColor Yellow -ForegroundColor Black "Please update to the latest version."
        }
        Set-Variable -Name M365ToolkitCheckedVersion -Value "Yes" -Force -Scope Global
    }
}
