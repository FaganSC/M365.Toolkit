# PS.Microsoft365.Toolkit
PowerShell Module for Microsoft 365 Toolkit

## Versioning Process For Publishing

Use the GitHub workflow `.github/workflows/version-bump.yml` to update the module version in `M365.Toolkit.psd1`.

1. Open Actions and run **Bump Module Version**.
2. Select `bump_type` (`build`, `patch`, `minor`, or `major`) or provide `explicit_version`.
3. The workflow updates `ModuleVersion`, commits the change, and pushes to the current branch.
4. After merge/push to the target branch, the publish workflow uses the new manifest version for release tagging and PowerShell Gallery publish.
