---
title: Move-SP365Nav
parent: SharePoint
grand_parent: Command reference
nav_order: 4
---

# Move-SP365Nav

Moves SharePoint navigation nodes between navigation locations or sites.

## Syntax

```powershell
Move-SP365Nav
    [-SourceSite] <String>
    [[-TargetSite] <String>]
    [[-SameSite] <Boolean>]
    [[-ClearTargetNav] <Boolean>]
    [[-SourceNavigationLocation] <NavigationType>]
    [[-TargetNavigationLocation] <NavigationType>]
    [<CommonParameters>]
```

## Description

`Move-SP365Nav` reads the navigation hierarchy from a source location, recreates it in a target location, and then clears the source navigation. The target navigation is cleared first by default.

For a cross-site move, provide both `SourceSite` and `TargetSite`. To move navigation between locations in the same site, set `SameSite` to `$true`.

## Examples

### Move navigation between sites

```powershell
Move-SP365Nav `
    -SourceSite 'https://contoso.sharepoint.com/sites/source' `
    -TargetSite 'https://contoso.sharepoint.com/sites/target' `
    -SourceNavigationLocation QuickLaunch `
    -TargetNavigationLocation QuickLaunch
```

Copies Quick Launch navigation to the target site, then removes the source site's Quick Launch navigation.

### Move navigation within one site

```powershell
Move-SP365Nav `
    -SourceSite 'https://contoso.sharepoint.com/sites/operations' `
    -SameSite $true `
    -SourceNavigationLocation QuickLaunch `
    -TargetNavigationLocation TopNavigationBar
```

Moves navigation from Quick Launch to the top navigation bar in the same site.

## Parameters

### `-SourceSite`

The absolute URL of the SharePoint site from which navigation is read.

| Property | Value |
| --- | --- |
| Type | `System.String` |
| Required | Yes |
| Position | 0 |
| Pipeline input | No |

### `-TargetSite`

The absolute URL of the destination SharePoint site. Provide this parameter unless `SameSite` is `$true`.

| Property | Value |
| --- | --- |
| Type | `System.String` |
| Required | No |
| Position | 1 |
| Pipeline input | No |

### `-SameSite`

Indicates that the source and target navigation locations belong to the source site. When `$true`, the command does not establish a separate target-site connection.

| Property | Value |
| --- | --- |
| Type | `System.Boolean` |
| Required | No |
| Position | 2 |
| Default value | `False` |
| Pipeline input | No |

### `-ClearTargetNav`

Controls whether existing target navigation nodes are removed before the source nodes are added.

| Property | Value |
| --- | --- |
| Type | `System.Boolean` |
| Required | No |
| Position | 3 |
| Default value | `True` |
| Pipeline input | No |

### `-SourceNavigationLocation`

The PnP navigation location from which nodes are read, such as `QuickLaunch` or `TopNavigationBar`.

| Property | Value |
| --- | --- |
| Type | `PnP.Framework.Enums.NavigationType` |
| Required | No |
| Position | 4 |
| Pipeline input | No |

### `-TargetNavigationLocation`

The PnP navigation location to which nodes are added, such as `QuickLaunch` or `TopNavigationBar`.

| Property | Value |
| --- | --- |
| Type | `PnP.Framework.Enums.NavigationType` |
| Required | No |
| Position | 5 |
| Pipeline input | No |

## Inputs

None.

## Outputs

None.

## Notes

This command clears the source navigation after populating the target. Use `Copy-SP365Nav` to preserve the source navigation.

## Related links

- [Connect-SP365](Connect-SP365.md)
- [Copy-SP365Nav](Copy-SP365Nav.md)
