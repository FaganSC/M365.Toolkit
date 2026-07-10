function Connect-SP365 {
    [CmdletBinding()]
    param (
        $Url = $null
    )

    $isVerbose = $VerbosePreference -ne 'SilentlyContinue'
    Write-Verbose "Starting Connect-SP365 function"
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

    $onedriveAppsPath = "$($env:OneDrive)\Apps\M365.Toolkit"
    $settingsFilePath = "$($onedriveAppsPath)\tenants.json"
    if (-not (Test-Path $onedriveAppsPath)) {
        New-Item -Path $onedriveAppsPath -ItemType Directory | Out-Null
    }
    if (-not (Test-Path $settingsFilePath)) {
        $settingsFilePath = "$(Split-Path -Path ($(Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent)) -Parent)\tenants.json"
        Move-Item -Path $settingsFilePath -Destination "$($onedriveAppsPath)\tenants.json" -Force
        $settingsFilePath = "$($onedriveAppsPath)\tenants.json"
    }  

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
    $tenantId = $tenant.tenantId
    $tenantClientId = $tenant.clientId
    $tenantEnvironment = $tenant.environment

    Write-Verbose "Preparing to connect to tenant $tenantName with URL $Url"
    Write-Verbose "Connecting with ClientId $tenantClientId"
    Write-Verbose "Connecting to environment $tenantEnvironment"
    Write-Verbose "Attempting to connect to SharePoint Online"
    Write-Verbose "Connecting to URL $Url"
    
    try {
        Write-Host -NoNewline "Connecting to $($tenantName) ($($Url))"

        try {
            $connection = Get-PnPConnection -ErrorAction SilentlyContinue
        }
        catch {
        }
        if ($connection -and $connection.Url.TrimEnd('/') -eq $Url.TrimEnd('/')) { 
            Write-Host -ForegroundColor Yellow " .....Already Connected"
        }
        else { 
            $connectParams = @{
                Url         = $Url
                ClientId    = $tenantClientId
                Interactive = $true
                Verbose     = $isVerbose
            }

            if ($tenantEnvironment) {
                $connectParams.AzureEnvironment = $tenantEnvironment
                $connectParams.Tenant = $tenantId
            }

            Connect-PnPOnline @connectParams
            Write-Host -ForegroundColor Green " .....Success"
        }
    }
    catch {
        Write-Host "An error occurred: $_"
        throw $_
    }
}

Export-ModuleMember -Function *