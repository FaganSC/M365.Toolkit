function Add-NewTenant {
    param (
        [Parameter(Mandatory = $true)]
        $settingsFilePath
    )

    $settings = Get-Content $settingsFilePath | ConvertFrom-Json
    Write-Host "No tenant found. Please add a new tenant."
    $newTenantName = Read-Host "Enter the tenant name"
    $newTenantAdminHost = Read-Host "Enter the tenant admin host (contoso-admin.sharepoint.com)"
    $newTenantRootHost = Read-Host "Enter the tenant root host (contoso.sharepoint.com)"
    $newClientId = Read-Host "Enter the client id"

    $newTenant = @{
        id       = ($settings.SharePoint.Count).ToString()
        name     = $newTenantName
        url      = @($newTenantAdminHost, $newTenantRootHost)
        clientId = $newClientId
    }
    $settings.SharePoint += $newTenant
    $settings | ConvertTo-Json -Depth 3 | Set-Content -Path $settingsFilePath
    Write-Host "Tenant added successfully"
    Write-Host ""
}

function Remove-Tenant {
    param (
        [Parameter(Mandatory = $true)]
        $settingsFilePath
    )
    $settings = Get-Content $settingsFilePath | ConvertFrom-Json
    $tenantId = Read-Host "Enter Tentant ID to remove"

    $confirmVal = Read-Host "Are you sure you want to remove the tenant $($settings.SharePoint[$inputVal].name)? (y/n)"
    if ($confirmVal.ToLower() -eq 'y') {
        $x = 0
        $settings.SharePoint = $settings.SharePoint | Where-Object { $_.id -ne $tenantId.ToString() }
        $settings.SharePoint | ForEach-Object {
            $_.id = $x.ToString()
            $x++
        }
        $settings | ConvertTo-Json -Depth 3 | Set-Content -Path $settingsFilePath
        Write-Host "Tenant removed successfully"
    } else {
        Write-Host "Action Cancelled"
    }
}

function Update-Tenant {
    param (
        [Parameter(Mandatory = $true)]
        $settingsFilePath
    )
    $settings = Get-Content $settingsFilePath | ConvertFrom-Json
    $tenantId = Read-Host "Enter Tentant ID to update"
    Write-Host -ForegroundColor Yellow "Leave blank to keep the existing value"
    $newTenantName = Read-Host "Enter the tenant name ($($settings.SharePoint[$tenantId].name))"
    $newTenantAdminHost = Read-Host "Enter the tenant admin host ($($settings.SharePoint[$tenantId].url[0]))"
    $newTenantRootHost = Read-Host "Enter the tenant root host ($($settings.SharePoint[$tenantId].url[1]))"
    $newClientId = Read-Host "Enter the client id ($($settings.SharePoint[$tenantId].clientId))"

    $confirmVal = Read-Host "Are you sure you want to update the tenant $($settings.SharePoint[$tenantId].name)? (y/n)"
    if ($confirmVal.ToLower() -eq 'y') {
        $settings.SharePoint[$tenantId].name = if ($newTenantName) { $newTenantName } else { $settings.SharePoint[$tenantId].name }
        $settings.SharePoint[$tenantId].url[0] = if ($newTenantAdminHost) { $newTenantAdminHost } else { $settings.SharePoint[$tenantId].url[0] }
        $settings.SharePoint[$tenantId].url[1] = if ($newTenantRootHost) { $newTenantRootHost } else { $settings.SharePoint[$tenantId].url[1] }
        $settings.SharePoint[$tenantId].clientId = if ($newClientId) { $newClientId } else { $settings.SharePoint[$tenantId].clientId }


        $settings | ConvertTo-Json -Depth 3 | Set-Content -Path $settingsFilePath
        Write-Host "Tenant removed successfully"
    } else {
        Write-Host "Action Cancelled"
    }
}