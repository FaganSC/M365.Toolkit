---
title: M365.Toolkit
nav_order: 1
---

# M365.Toolkit

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/M365.Toolkit?label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/M365.Toolkit)
[![GitHub Pages](https://github.com/FaganSC/M365.Toolkit/actions/workflows/pages.yml/badge.svg)](https://fagan.cloud/M365.Toolkit)
[![GitHub Issues](https://img.shields.io/github/issues/FaganSC/M365.Toolkit)](https://github.com/FaganSC/M365.Toolkit/issues)

M365.Toolkit is a PowerShell module for common Microsoft 365 administration tasks.

## Installation

```powershell
Install-Module -Name M365.Toolkit
Import-Module -Name M365.Toolkit
```

The module requires PowerShell 7.4 or later and PnP.PowerShell 3.1.0 or later.

[View M365.Toolkit on PowerShell Gallery](https://www.powershellgallery.com/packages/M365.Toolkit/){: .btn .btn-primary }

## Command reference

| Command | Description |
| --- | --- |
| [Get-M365ToolkitInfo](commands/module/Get-M365ToolkitInfo.md) | Returns information about the loaded module. |
| [Connect-SP365](commands/sharepoint/Connect-SP365.md) | Connects interactively to a saved SharePoint Online tenant. |
| [Clear-SP365List](commands/sharepoint/Clear-SP365List.md) | Deletes or recycles every item in a SharePoint list. |
| [Copy-SP365Nav](commands/sharepoint/Copy-SP365Nav.md) | Copies navigation nodes between locations or sites. |
| [Move-SP365Nav](commands/sharepoint/Move-SP365Nav.md) | Moves navigation nodes between locations or sites. |
| [Restore-SP365ListItems](commands/sharepoint/Restore-SP365ListItems.md) | Restores a list's items from the SharePoint recycle bin. |

See the [GitHub repository](https://github.com/FaganSC/M365.Toolkit) for source code and release information.
