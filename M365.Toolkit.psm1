$publicFunctionFiles = @()
$publicSearchPaths = @(
    (Join-Path -Path $PSScriptRoot -ChildPath 'src/Public/*.ps1'),
    (Join-Path -Path $PSScriptRoot -ChildPath 'Public/*.ps1')
)

foreach ($path in $publicSearchPaths) {
    $publicFunctionFiles += Get-ChildItem -Recurse -Path $path -ErrorAction SilentlyContinue
}

$publicFunctionFiles | Sort-Object -Property FullName -Unique | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function '*-*'