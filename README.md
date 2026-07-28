# PS.Microsoft365.Toolkit
PowerShell Module for Microsoft 365 Toolkit

## Versioning Process For Publishing

M365.Toolkit follows the PnP.PowerShell numeric version pattern:

- Develop prereleases increment the third component and use the `preview` label, for example `1.1.12-preview`.
- A pull request to `main` increments the minor component, resets the third component to zero, and removes the prerelease label, for example `1.1.12-preview` becomes `1.2.0`.
- A new major starts at `<major>.0.0` and is released only by pushing a matching tag, for example `v2.0.0`. The tag must point to a commit whose manifest version is `2.0.0`.

The manual **Bump Module Version** workflow can update build, patch, or minor versions within the current major. It rejects explicit versions that change the major component.

## Production Code Signing

Production releases use Authenticode signatures for the module manifest, root module, and all public and private function scripts. Configure these GitHub Actions repository secrets before running the production workflow:

| Secret | Value |
| --- | --- |
| `CODESIGNINGPFXBASE64` | Base64-encoded PFX containing a valid code-signing certificate and private key |
| `CODESIGNINGPFXPASSWORD` | Password for the PFX |

Convert a PFX to Base64 in PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('M365.Toolkit-CodeSigning.pfx'))
```

The production workflow signs with SHA-256, adds a trusted timestamp for CA-issued certificates, validates every signature, and removes the temporary certificate before publishing to PowerShell Gallery.

A self-signed certificate is signed without an external timestamp. The workflow validates the embedded signer and rejects missing, mismatched, or hash-invalid signatures, but it cannot establish certificate trust. Use a publicly trusted code-signing certificate for production distribution.

## Automated Versioning

Each non-bot push to `develop` increments the three-part module build version, applies the `preview` prerelease label, and publishes the signed package to PowerShell Gallery. The workflow commits the new version to `develop` without triggering another build.

When a pull request is opened or reopened against `main`, the workflow increments the minor version, resets the third component to zero, and removes the prerelease label. Version labels do not override this behavior.
