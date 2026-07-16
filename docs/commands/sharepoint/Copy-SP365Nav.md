---
title: Copy-SP365Nav
parent: SharePoint
grand_parent: Command reference
nav_order: 3
---

# Copy-SP365Nav

Copies SharePoint navigation nodes between navigation locations or sites.

## Syntax

```powershell
Copy-SP365Nav
    [-SourceSite] <String>
    [[-TargetSite] <String>]
    [[-SameSite] <Boolean>]
    [[-ClearTargetNav] <Boolean>]
    [[-SourceNavigationLocation] <NavigationType>]
    [[-TargetNavigationLocation] <NavigationType>]
    [<CommonParameters>]
```

## Description

`Copy-SP365Nav` reads the navigation hierarchy from a source location and recreates it in a target location. The target navigation is cleared first by default.

For a cross-site copy, provide both `SourceSite` and `TargetSite`. To copy between navigation locations in the same site, set `SameSite` to `$true`.

## Examples

### Copy navigation between sites

```powershell
Copy-SP365Nav `
    -SourceSite 'https://contoso.sharepoint.com/sites/source' `
    -TargetSite 'https://contoso.sharepoint.com/sites/target' `
    -SourceNavigationLocation QuickLaunch `
    -TargetNavigationLocation QuickLaunch
```

Copies the source site's Quick Launch navigation to the target site after clearing the target's Quick Launch navigation.

### Copy navigation within one site

```powershell
Copy-SP365Nav `
    -SourceSite 'https://contoso.sharepoint.com/sites/operations' `
    -SameSite $true `
    -SourceNavigationLocation QuickLaunch `
    -TargetNavigationLocation TopNavigationBar `
    -ClearTargetNav $false
```

Appends the Quick Launch nodes to the top navigation bar without clearing existing target nodes.

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

The source navigation is not modified. Use `Move-SP365Nav` when the source navigation should be removed after the target is populated.

## Related links

- [Connect-SP365](Connect-SP365.md)
- [Move-SP365Nav](Move-SP365Nav.md)
