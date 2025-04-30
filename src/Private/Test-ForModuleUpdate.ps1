function Test-ForModuleUpdate {
    [cmdletbinding()]            
    param()
    $ModuleName = "M365.Toolkit"

    $checkedVersion = Get-Variable -Name M365ToolkitCheckedVersion -ValueOnly -Scope Global -ErrorAction SilentlyContinue

    if ($checkedVersion -ne "Yes") {
        [version]$currentVersion = (Get-Module -ListAvailable | Where-Object { $_.Name -eq $ModuleName } | Select-Object Version).Version.ToString()
        [version]$latestVersion = (Invoke-WebRequest "https://api.github.com/repos/FaganSC/$($ModuleName)/releases" | ConvertFrom-Json)[0].tag_name

        if ($currentVersion -gt $latestVersion) {
            Write-Verbose "You are using an pre-release: $($currentVersion.ToString())"
            Write-Host -BackgroundColor Blue -ForegroundColor White "You are using a pre-release version of $($ModuleName)."
            Write-Host -BackgroundColor Blue -ForegroundColor White "Please check the PowerShell Gallery for the latest stable release."
        }
        elseif ($currentVersion -ne $latestVersion) {
            Write-Verbose "There is a new version available: $($latestVersion.ToString())"
            Write-Host -BackgroundColor Yellow -ForegroundColor Black "There is a new version of $($ModuleName) available."
            Write-Host -BackgroundColor Yellow -ForegroundColor Black "Please update to the latest version."
        }
        Set-Variable -Name M365ToolkitCheckedVersion -Value "Yes" -Force -Scope Global
    }
}
