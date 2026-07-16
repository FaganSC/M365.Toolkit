param(
    [string]$OutputDirectory = "$HOME\M365.Toolkit-Certificate",
    [string]$Subject = 'CN=M365.Toolkit Code Signing'
)

$ErrorActionPreference = 'Stop'
New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null

$password = Read-Host 'Enter a PFX password' -AsSecureString
$pfxPath = Join-Path $OutputDirectory 'M365.Toolkit-CodeSigning.pfx'
$base64Path = "$pfxPath.base64"

$certificate = New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -Subject $Subject `
    -CertStoreLocation 'Cert:\CurrentUser\My' `
    -KeyAlgorithm RSA `
    -KeyLength 3072 `
    -HashAlgorithm SHA256 `
    -KeyExportPolicy Exportable `
    -NotAfter (Get-Date).AddYears(1)

Export-PfxCertificate `
    -Cert $certificate `
    -FilePath $pfxPath `
    -Password $password | Out-Null

$base64 = [Convert]::ToBase64String(
    [IO.File]::ReadAllBytes($pfxPath)
)
[IO.File]::WriteAllText($base64Path, $base64)

Write-Host "PFX:        $pfxPath"
Write-Host "Base64:     $base64Path"
Write-Host "Thumbprint: $($certificate.Thumbprint)"