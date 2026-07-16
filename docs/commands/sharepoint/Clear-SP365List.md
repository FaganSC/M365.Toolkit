---
title: Clear-SP365List
parent: SharePoint
grand_parent: Command reference
nav_order: 2
---

# Clear-SP365List

Deletes or recycles every item in a SharePoint list.

## Syntax

```powershell
Clear-SP365List [-ListName] <Object> [-Recycle] [<CommonParameters>]
```

## Description

`Clear-SP365List` retrieves items from the specified SharePoint list in batches and removes them until the list is empty. By default, items are permanently deleted. Use `Recycle` to send the items to the SharePoint recycle bin instead.

The command displays the number of affected items and requires confirmation before making changes. Enter an uppercase `Y` to continue.

An active SharePoint connection is required.

## Examples

### Permanently delete all list items

```powershell
Connect-SP365 -Url 'https://contoso.sharepoint.com/sites/operations'
Clear-SP365List -ListName 'Import Queue'
```

Prompts for confirmation and permanently deletes every item in **Import Queue**.

### Recycle all list items

```powershell
Clear-SP365List -ListName 'Import Queue' -Recycle
```

Prompts for confirmation and sends every item in **Import Queue** to the recycle bin.

## Parameters

### `-ListName`

The name or identity of the SharePoint list to clear.

| Property | Value |
| --- | --- |
| Type | `System.Object` |
| Required | Yes |
| Position | 0 |
| Pipeline input | No |

### `-Recycle`

Sends removed items to the SharePoint recycle bin. Without this switch, the items are permanently deleted.

| Property | Value |
| --- | --- |
| Type | `System.Management.Automation.SwitchParameter` |
| Required | No |
| Position | Named |
| Default value | `False` |
| Pipeline input | No |

## Inputs

None.

## Outputs

None.

## Notes

This command is destructive. Confirm the selected site and list before entering `Y`. Items removed without `Recycle` cannot be restored with `Restore-SP365ListItems`.

## Related links

- [Connect-SP365](Connect-SP365.md)
- [Restore-SP365ListItems](Restore-SP365ListItems.md)
