---
title: Connect-SP365
parent: SharePoint
grand_parent: Command reference
nav_order: 1
---

# Connect-SP365

Connects to SharePoint Online using a saved tenant configuration.

## Syntax

```powershell
Connect-SP365 [[-Url] <Object>] [<CommonParameters>]
```

## Description

`Connect-SP365` uses PnP.PowerShell interactive authentication to connect to SharePoint Online. Tenant connection settings are stored in `Apps\M365.Toolkit\tenants.json` under the current user's OneDrive folder.

When `Url` is omitted, the command displays the saved tenants and prompts you to select, add, update, or remove a connection. When `Url` is supplied, the command selects the saved tenant associated with that URL.

If the active PnP connection already uses the requested URL, the existing connection is retained.

## Examples

### Select a saved tenant interactively

```powershell
Connect-SP365
```

Displays saved SharePoint tenants and prompts for the tenant to connect to.

### Connect to a specific site

```powershell
Connect-SP365 -Url 'https://contoso.sharepoint.com/sites/operations'
```

Connects to the site using the matching saved tenant configuration.

## Parameters

### `-Url`

The absolute URL of the SharePoint Online site. The URL must correspond to a saved tenant configuration.

| Property | Value |
| --- | --- |
| Type | `System.Object` |
| Required | No |
| Position | 0 |
| Default value | `null` |
| Pipeline input | No |

## Inputs

None.

## Outputs

None. The command establishes or retains the current PnP.PowerShell connection.

## Notes

- Interactive authentication may open a browser or authentication dialog.
- Use `-Verbose` to display connection diagnostics.

## Related links

- [Clear-SP365List](Clear-SP365List.md)
- [Copy-SP365Nav](Copy-SP365Nav.md)
- [Move-SP365Nav](Move-SP365Nav.md)
- [Restore-SP365ListItems](Restore-SP365ListItems.md)
