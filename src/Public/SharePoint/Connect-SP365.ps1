function Connect-SP365 {
    [CmdletBinding()]
    param (
        $Url = $null
    )

    $privatePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath "private"
    @(Get-ChildItem -Path $privatePath -Recurse -Filter "*.ps1") | ForEach-Object {
        try {
            . $_.FullName
        }
        catch {
            exit
        }
    }

    Test-ForModuleUpdate
    
    $settingsFilePath = "$(Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent)\tenants.json"
    if (-not (Test-Path $settingsFilePath)) {
        New-Item -Path $settingsFilePath -ItemType File | Out-Null
        $jsonContent = '{"SharePoint": []}'
        Set-Content -Path  $settingsFilePath -Value $jsonContent | ConvertTo-Json
    }

    $settings = Get-Content $settingsFilePath | ConvertFrom-Json
    if ($settings.SharePoint.Count -eq 0) {
        Add-NewTenant -settingsFilePath $settingsFilePath
    }

    $settings = Get-Content $settingsFilePath | ConvertFrom-Json
    if ($null -eq $Url) {
        $settings.SharePoint | ForEach-Object {
            Write-Host -NoNewline "Tenant "
            Write-Host -NoNewline -ForegroundColor Yellow $_.id
            Write-Host -NoNewline ": "
            Write-Host "$($_.name) ($($_.url[0]))"
        }

        Write-Host ""
        Write-Host "Please enter the desired tenant number."

        Write-Host -NoNewline "Enter "
        Write-Host -NoNewline -ForegroundColor Yellow "n"
        Write-Host " to login with a new account"
        
        Write-Host -NoNewline "Enter "
        Write-Host -NoNewline -ForegroundColor Yellow "u"
        Write-Host " to update the above saved connection settings."

        Write-Host -NoNewline "Enter "
        Write-Host -NoNewline -ForegroundColor Yellow "r"
        Write-Host " to remove the above saved connection settings."

        Write-Host -NoNewline "Enter "
        Write-Host -NoNewline -ForegroundColor Yellow "x"
        Write-Host " to exit process"

        $inputVal = Read-Host

        if ($inputVal.ToLower() -eq "n") {
            Add-NewTenant -settingsFilePath $settingsFilePath
            return
        }
        elseif ($inputVal.ToLower() -eq "r") {
            Remove-Tenant -settingsFilePath $settingsFilePath
            return
        }
        elseif ($inputVal.ToLower() -eq "u") {
            Update-Tenant -settingsFilePath $settingsFilePath
            return
        }
        elseif ($inputVal.ToLower() -eq "x") {
            return
        }
        else {
            $tenant = $settings.SharePoint | Where-Object { $_.id -eq $inputVal }
            $Url = $tenant.url[0]
        }
    }
    else {
        $uri = [System.Uri]::new($Url)
        $tenant = $settings.SharePoint | Where-Object { $_.url -eq $uri.Host }
    }
    
    if ($null -eq $tenant) {
        Write-Host "Tenant not found"
        return
    }
    $tenantName = $tenant.name
    $tenantClientId = $tenant.clientId
    Write-Host -NoNewline "Connecting to $($tenantName) ($($Url))"
    Connect-PnPOnline -Url $Url -ClientId $tenantClientId -Interactive 
    Write-Host -ForegroundColor Green " .....Success"
}
