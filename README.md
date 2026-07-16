# PS.Microsoft365.Toolkit
PowerShell Module for Microsoft 365 Toolkit

## Versioning Process For Publishing

Use the GitHub workflow `.github/workflows/version-bump.yml` to update the module version in `M365.Toolkit.psd1`.

1. Open Actions and run **Bump Module Version**.
2. Select `bump_type` (`build`, `patch`, `minor`, or `major`) or provide `explicit_version`.
3. The workflow updates `ModuleVersion`, commits the change, and pushes to the current branch.
4. After merge/push to the target branch, the publish workflow uses the new manifest version for release tagging and PowerShell Gallery publish.

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

A self-signed certificate is trusted temporarily by the build runner so its signatures can be validated and is signed without an external timestamp. It is not automatically trusted on consumer systems; use a publicly trusted code-signing certificate for production distribution.
