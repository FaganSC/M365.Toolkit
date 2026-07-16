---
title: Restore-SP365ListItems
parent: SharePoint
grand_parent: Command reference
nav_order: 5
---

# Restore-SP365ListItems

Restores a SharePoint list's items from the recycle bin.

## Syntax

```powershell
Restore-SP365ListItems [-ListName] <Object> [<CommonParameters>]
```

## Description

`Restore-SP365ListItems` finds recycle-bin items whose directory matches the root folder of the specified SharePoint list and restores each item.

The command displays the number of matching items and requires confirmation before restoring them. Enter an uppercase `Y` to continue.

An active SharePoint connection is required.

## Examples

### Restore recycled list items

```powershell
Connect-SP365 -Url 'https://contoso.sharepoint.com/sites/operations'
Restore-SP365ListItems -ListName 'Import Queue'
```

Prompts for confirmation and restores matching items from the recycle bin to **Import Queue**.

## Parameters

### `-ListName`

The name or identity of the SharePoint list whose recycled items should be restored.

| Property | Value |
| --- | --- |
| Type | `System.Object` |
| Required | Yes |
| Position | 0 |
| Pipeline input | No |

## Inputs

None.

## Outputs

The command may emit output returned by `Restore-PnPRecycleBinItem`.

## Notes

Only items currently available in the SharePoint recycle bin and associated with the list's root folder can be restored.

## Related links

- [Connect-SP365](Connect-SP365.md)
- [Clear-SP365List](Clear-SP365List.md)
