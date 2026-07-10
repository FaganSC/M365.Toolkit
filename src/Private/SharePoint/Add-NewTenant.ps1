$environments = "Production", "PPE", "China", "Germany", "USGovernment", "USGovernmentHigh", "USGovernmentDoD", "BleuCloud", "DelosCloud", "GovSGCloud", "Custom"
function Add-NewTenant {
    param (
        [Parameter(Mandatory = $true)]
        $settingsFilePath
    )
    try {
        $settings = Get-Content $settingsFilePath | ConvertFrom-Json
        Write-Host "No tenant found. Please add a new tenant."
        $newTenantName = Read-Host "Enter the tenant name"
        $newTenantId = Read-Host "Enter the tenant ID"
        $newTenantRootHost = Read-Host "Enter the tenant host (contoso.sharepoint.com)"
        $newClientId = Read-Host "Enter the client id"
        
        $normalizedRootHost = (($newTenantRootHost -replace "^https?://", "") -split "/")[0].Trim()
        $tenantName = ($normalizedRootHost -replace "(?i)(?:-admin|-my)?\.sharepoint\..*$", "").TrimEnd('.', '/')
        $tld = if ($normalizedRootHost -match "(?i)sharepoint\.(.+)$") { "sharepoint.$($Matches[1])" } else { "sharepoint.com" }
        
        $x = 0
        $environments | ForEach-Object { 
            Write-Host "$($x). $_"
            $x++
        }

        $environment = Read-Host "Enter the environment (0-$($environments.Count - 1))"
        if ((-not $environment) -or ($environment  -lt 0 -or $environment -ge $environments.Count)) {
            $environment = 0
        }
        $newTenant = @{
            id          = ($settings.SharePoint.Count).ToString()
            name        = $newTenantName
            tenantId    = $newTenantId
            url         = @("$($tenantName).$tld", "$($tenantName)-admin.$tld", "$($tenantName)-my.$tld")
            clientId    = $newClientId
            environment = $environments[$environment]
        }

        $settings.SharePoint += $newTenant
        $settings | ConvertTo-Json -Depth 3 | Set-Content -Path $settingsFilePath
        Write-Host "Tenant added successfully"
        Write-Host ""
    } catch {
        Write-Host "An error occurred: $_"
        throw $_
    }
}

function Remove-Tenant {
    param (
        [Parameter(Mandatory = $true)]
        $settingsFilePath
    )
    $settings = Get-Content $settingsFilePath | ConvertFrom-Json
    $tenantId = Read-Host "Enter Tenant ID to remove"

    $confirmVal = Read-Host "Are you sure you want to remove the tenant $($settings.SharePoint[$tenantId].name)? (y/n)"
    if ($confirmVal.ToLower() -eq 'y') {
        $x = 0
        $settings.SharePoint = $settings.SharePoint | Where-Object { $_.id -ne $tenantId.ToString() }
        $settings.SharePoint | ForEach-Object {
            $_.id = $x.ToString()
            $x++
        }
        $settings | ConvertTo-Json -Depth 3 | Set-Content -Path $settingsFilePath
        Write-Host "Tenant removed successfully"
    }
    else {
        Write-Host "Action Cancelled"
    }
}

function Update-Tenant {
    param (
        [Parameter(Mandatory = $true)]
        $settingsFilePath
    )
    $settings = Get-Content $settingsFilePath | ConvertFrom-Json
    $tenantId = Read-Host "Enter Tenant ID to update"
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
        Write-Host "Tenant updated successfully"
    }
    else {
        Write-Host "Action Cancelled"
    }
}