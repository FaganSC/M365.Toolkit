---
title: Get-M365ToolkitInfo
parent: Module
grand_parent: Command reference
nav_order: 1
---

# Get-M365ToolkitInfo

Returns basic information about the loaded M365.Toolkit module.

## Syntax

```powershell
Get-M365ToolkitInfo
```

## Description

`Get-M365ToolkitInfo` returns the module name, the version of the loaded module, and the time at which the command was run.

## Examples

### Get module information

```powershell
Get-M365ToolkitInfo
```

```text
ModuleName   Version Loaded
----------   ------- ------
M365.Toolkit 1.0.0.6 7/16/2026 12:00:00 PM
```

## Inputs

None.

## Outputs

`System.Management.Automation.PSCustomObject`

The returned object contains `ModuleName`, `Version`, and `Loaded` properties.

## Related links

- [Module commands](index.md)
