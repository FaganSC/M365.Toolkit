[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ModulePath,

    [Parameter(Mandatory)]
    [string]$PfxBase64,

    [Parameter(Mandatory)]
    [string]$PfxPassword,

    [Parameter()]
    [uri]$TimestampServer = 'https://timestamp.digicert.com'
)

$ErrorActionPreference = 'Stop'
$moduleRoot = (Resolve-Path -Path $ModulePath).Path
$pfxCertificates = [Security.Cryptography.X509Certificates.X509Certificate2Collection]::new()
$certificate = $null
$pfxBytes = $null

try {
    Write-Host "[$(Get-Date -Format o)] Decoding the code-signing PFX."
    $pfxBytes = [Convert]::FromBase64String($PfxBase64)

    Write-Host "[$(Get-Date -Format o)] Loading the code-signing certificate in memory."
    $pfxCertificates.Import(
        $pfxBytes,
        $PfxPassword,
        [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::EphemeralKeySet
    )

    $codeSigningOid = '1.3.6.1.5.5.7.3.3'
    $codeSigningCertificates = @(
        foreach ($candidate in $pfxCertificates) {
            $ekuExtension = $candidate.Extensions |
                Where-Object {
                    $_ -is [Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension]
                } |
                Select-Object -First 1
            $ekuOids = @(
                if ($null -ne $ekuExtension) {
                    $ekuExtension.EnhancedKeyUsages | ForEach-Object Value
                }
            )

            Write-Host (
                "Loaded certificate: Subject='{0}', Thumbprint='{1}', HasPrivateKey={2}, EKUs='{3}'" -f
                $candidate.Subject,
                $candidate.Thumbprint,
                $candidate.HasPrivateKey,
                ($ekuOids -join ',')
            )

            if ($candidate.HasPrivateKey -and $ekuOids -contains $codeSigningOid) {
                $candidate
            }
        }
    )
    $certificate = $codeSigningCertificates | Select-Object -First 1

    if ($null -eq $certificate) {
        throw 'The PFX does not contain a certificate with a private key that is valid for code signing.'
    }

    $isSelfSigned = $certificate.Subject -eq $certificate.Issuer
    if ($isSelfSigned) {
        Write-Warning 'Using a self-signed certificate. Signature trust cannot be established on the runner.'
    }

    $now = Get-Date
    if ($now -lt $certificate.NotBefore -or $now -gt $certificate.NotAfter) {
        throw 'The code-signing certificate is not currently valid.'
    }

    $moduleFiles = @(
        Get-Item -Path (
            Join-Path $moduleRoot 'M365.Toolkit.psd1'
        ), (
            Join-Path $moduleRoot 'M365.Toolkit.psm1'
        )
        Get-ChildItem -Path (
            Join-Path $moduleRoot 'src\Private'
        ), (
            Join-Path $moduleRoot 'src\Public'
        ) -Recurse -File |
            Where-Object Extension -In '.ps1', '.psm1', '.psd1', '.ps1xml', '.cdxml'
    )

    foreach ($file in $moduleFiles) {
        Write-Host "[$(Get-Date -Format o)] Signing $($file.FullName)"
        $signingParameters = @{
            FilePath      = $file.FullName
            Certificate   = $certificate
            HashAlgorithm = 'SHA256'
            IncludeChain  = 'All'
        }
        if (-not $isSelfSigned) {
            $signingParameters.TimestampServer = $TimestampServer.AbsoluteUri
        }

        $signature = Set-AuthenticodeSignature @signingParameters
        Write-Host "[$(Get-Date -Format o)] Signature status: $($signature.Status)"

        $acceptableStatus = if ($isSelfSigned) {
            $signature.Status -in @(
                [System.Management.Automation.SignatureStatus]::Valid,
                [System.Management.Automation.SignatureStatus]::UnknownError
            )
        }
        else {
            $signature.Status -eq [System.Management.Automation.SignatureStatus]::Valid
        }

        if (
            -not $acceptableStatus -or
            $null -eq $signature.SignerCertificate -or
            $signature.SignerCertificate.Thumbprint -ne $certificate.Thumbprint
        ) {
            throw "Failed to sign '$($file.FullName)': $($signature.StatusMessage)"
        }
    }

    $invalidSignatures = @(
        foreach ($file in $moduleFiles) {
            $signature = Get-AuthenticodeSignature -FilePath $file.FullName
            $acceptableStatus = if ($isSelfSigned) {
                $signature.Status -in @(
                    [System.Management.Automation.SignatureStatus]::Valid,
                    [System.Management.Automation.SignatureStatus]::UnknownError
                )
            }
            else {
                $signature.Status -eq [System.Management.Automation.SignatureStatus]::Valid
            }

            if (
                -not $acceptableStatus -or
                $null -eq $signature.SignerCertificate -or
                $signature.SignerCertificate.Thumbprint -ne $certificate.Thumbprint
            ) {
                $signature
            }
        }
    )
    if ($invalidSignatures.Count -gt 0) {
        throw "Signature validation failed for: $($invalidSignatures.Path -join ', ')"
    }

    Write-Host "Signed and validated $($moduleFiles.Count) module files."
}
finally {
    foreach ($pfxCertificate in $pfxCertificates) {
        $pfxCertificate.Dispose()
    }
    if ($null -ne $pfxBytes) {
        [Array]::Clear($pfxBytes, 0, $pfxBytes.Length)
    }
}
