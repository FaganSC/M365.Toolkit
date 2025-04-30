Get-ChildItem -Recurse -Path $PSScriptRoot/src/Public/*.ps1 -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
}
Export-ModuleMember -Function '*-*'