#Requires -Version 5.1

# Dot-source all Private and Public function scripts
$SourceRoot = Join-Path $PSScriptRoot 'src'
$Private = @(Get-ChildItem -Path (Join-Path $SourceRoot 'Private') -Filter '*.ps1' -Recurse -ErrorAction Stop)
$Public  = @(Get-ChildItem -Path (Join-Path $SourceRoot 'Public')  -Filter '*.ps1' -Recurse -ErrorAction Stop)

foreach ($file in @($Private + $Public)) {
    try {
        . $file.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($file.FullName): $_"
    }
}

# Only the functions in Public\ are exported to consumers of the module.
Export-ModuleMember -Function $Public.BaseName
