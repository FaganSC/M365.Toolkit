<#
.SYNOPSIS
    Bumps the ModuleVersion in a PowerShell module manifest (.psd1).
.DESCRIPTION
    Reads the current ModuleVersion from the manifest, increments the requested
    semver component (Major, Minor, or Patch), and writes the new version back
    to the manifest in place. Prints the new version to the pipeline so it can
    be captured by CI (e.g. GitHub Actions $GITHUB_OUTPUT).
.PARAMETER ManifestPath
    Path to the .psd1 manifest file to update.
.PARAMETER Bump
    Which semver component to increment: Major, Minor, or Patch. Defaults to Patch.
.EXAMPLE
    .\Update-ModuleVersion.ps1 -ManifestPath .\M365.Toolkit.psd1 -Bump Patch
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ManifestPath,

    [Parameter()]
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$Bump = 'Patch'
)

if (-not (Test-Path -Path $ManifestPath)) {
    throw "Manifest not found at path: $ManifestPath"
}

$manifest = Import-PowerShellDataFile -Path $ManifestPath
[version]$currentVersion = $manifest.ModuleVersion

$newVersion = switch ($Bump) {
    'Major' { [version]::new($currentVersion.Major + 1, 0, 0) }
    'Minor' { [version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0) }
    'Patch' {
        $build = if ($currentVersion.Build -lt 0) { 0 } else { $currentVersion.Build }
        [version]::new($currentVersion.Major, $currentVersion.Minor, $build + 1)
    }
}

Update-ModuleManifest -Path $ManifestPath -ModuleVersion $newVersion.ToString()

Write-Host "Bumped module version: $currentVersion -> $newVersion"

# Emit new version for GitHub Actions steps to consume.
if ($env:GITHUB_OUTPUT) {
    "new_version=$newVersion" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

return $newVersion.ToString()
