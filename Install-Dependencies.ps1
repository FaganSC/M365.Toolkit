Write-Host "Installing required modules..." -ForegroundColor Green

@("Pester", "PowerShellGet") | ForEach-Object {
    $module = $_
    Write-Host "Installing $module" -ForegroundColor Green
    Install-Module -Name $module -Force -Scope CurrentUser -SkipPublisherCheck -Verbose
}

$moduleManifest = Get-Item -Path .\M365.Toolkit.psd1
$data = Import-PowerShellDataFile  $moduleManifest.FullName
$requiredModulesNames = $data.RequiredModules.ModuleName
$requiredModulesVersions = $data.RequiredModules.ModuleVersion
if ($requiredModulesNames) {
    if ($requiredModulesNames.Count -eq 1) {
        Write-Host "Installing $requiredModulesNames version $requiredModulesVersions" -ForegroundColor Green
        Install-Module -Name $requiredModulesNames -RequiredVersion $requiredModulesVersions -Force -Scope CurrentUser -SkipPublisherCheck -Verbose
    }
    else {
        foreach ($x in 0..($requiredModulesNames.Count - 1)) {
            $module = $requiredModulesNames[$x]
            $version = $requiredModulesVersions[$x]
            Write-Host "Installing $module version $version" -ForegroundColor Green
            Install-Module -Name $module -RequiredVersion $version -Force -Scope CurrentUser -SkipPublisherCheck -Verbose
        }
    }
}
