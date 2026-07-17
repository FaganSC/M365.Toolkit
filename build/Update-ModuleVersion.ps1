<#
.SYNOPSIS
    Updates the ModuleVersion in a PowerShell module manifest (.psd1).
.DESCRIPTION
    Sets an explicit module version or increments the requested version component
    and writes the new version to the manifest.
.PARAMETER ManifestPath
    Path to the .psd1 manifest file to update.
.PARAMETER Bump
    Version component to increment: Major, Minor, Patch, or Build.
.PARAMETER Version
    Explicit version to assign instead of incrementing the current version.
.EXAMPLE
    .\Update-ModuleVersion.ps1 -ManifestPath .\M365.Toolkit.psd1 -Bump Patch
.EXAMPLE
    .\Update-ModuleVersion.ps1 -ManifestPath .\M365.Toolkit.psd1 -Version 1.2.0.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ManifestPath,

    [Parameter(ParameterSetName = 'Bump')]
    [ValidateSet('Major', 'Minor', 'Patch', 'Build')]
    [string]$Bump = 'Build',

    [Parameter(Mandatory, ParameterSetName = 'Version')]
    [ValidateScript({
        $parsedVersion = $null
        [version]::TryParse($_, [ref]$parsedVersion)
    })]
    [string]$Version
)

if (-not (Test-Path -Path $ManifestPath)) {
    throw "Manifest not found at path: $ManifestPath"
}

$manifest = Import-PowerShellDataFile -Path $ManifestPath
[version]$currentVersion = $manifest.ModuleVersion

$newVersion = if ($PSCmdlet.ParameterSetName -eq 'Version') {
    [version]$Version
}
else {
    $build = [Math]::Max(0, $currentVersion.Build)
    $revision = [Math]::Max(0, $currentVersion.Revision)

    switch ($Bump) {
        'Major' { [version]::new($currentVersion.Major + 1, 0, 0, 0) }
        'Minor' { [version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0, 0) }
        'Patch' { [version]::new($currentVersion.Major, $currentVersion.Minor, $build + 1, 0) }
        'Build' { [version]::new($currentVersion.Major, $currentVersion.Minor, $build, $revision + 1) }
    }
}

Update-ModuleManifest -Path $ManifestPath -ModuleVersion $newVersion.ToString()

Write-Host "Bumped module version: $currentVersion -> $newVersion"

# Emit new version for GitHub Actions steps to consume.
if ($env:GITHUB_OUTPUT) {
    "new_version=$newVersion" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

return $newVersion.ToString()
