[CmdletBinding()]
param(
    [Parameter()]
    [string]$ManifestPath = './M365.Toolkit.psd1',

    [Parameter()]
    [ValidateSet('major', 'minor', 'patch', 'build')]
    [string]$Bump = 'build',

    [Parameter()]
    [string]$Version
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Module manifest not found at path: $ManifestPath"
}

$manifestData = Import-PowerShellDataFile -Path $ManifestPath
$currentVersion = [version]$manifestData.ModuleVersion

if ($PSBoundParameters.ContainsKey('Version') -and -not [string]::IsNullOrWhiteSpace($Version)) {
    $newVersion = [version]$Version
}
else {
    switch ($Bump) {
        'major' { $newVersion = [version]::new($currentVersion.Major + 1, 0, 0, 0) }
        'minor' { $newVersion = [version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0, 0) }
        'patch' { $newVersion = [version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1, 0) }
        'build' { $newVersion = [version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build, $currentVersion.Revision + 1) }
    }
}

if ($newVersion -le $currentVersion) {
    throw "New version ($newVersion) must be greater than current version ($currentVersion)."
}

$manifestContent = Get-Content -LiteralPath $ManifestPath -Raw
$updatedContent = [regex]::Replace(
    $manifestContent,
    "(?m)^(\s*ModuleVersion\s*=\s*)'[^']+'",
    "`$1'$newVersion'"
)

if ($updatedContent -eq $manifestContent) {
    throw 'Failed to update ModuleVersion in manifest. Expected key was not found.'
}

Set-Content -LiteralPath $ManifestPath -Value $updatedContent -Encoding utf8

# Validate after update so broken versions fail fast.
Test-ModuleManifest -Path $ManifestPath | Out-Null

Write-Output $newVersion