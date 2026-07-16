function Restore-SP365ListItems {
    <#
    .SYNOPSIS
        Restores a SharePoint list's items from the recycle bin.

    .DESCRIPTION
        Finds recycle-bin items whose directory matches the root folder of the
        specified SharePoint list and restores each item.

        The command requires an active SharePoint connection and prompts for
        confirmation before restoring items. Enter an uppercase Y to continue.

    .PARAMETER ListName
        The name or identity of the SharePoint list whose recycled items should
        be restored.

    .EXAMPLE
        Restore-SP365ListItems -ListName 'Import Queue'

        Prompts for confirmation and restores matching recycle-bin items to the
        Import Queue list.

    .INPUTS
        None.

    .OUTPUTS
        The command may emit output returned by Restore-PnPRecycleBinItem.

    .NOTES
        Only items currently available in the SharePoint recycle bin and
        associated with the list's root folder can be restored.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $ListName
    )
    try {

        $privatePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath "private"
        @(Get-ChildItem -Path $privatePath -Recurse -Filter "*.ps1") | ForEach-Object {
            try {
                . $_.FullName
            }
            catch {
                exit
            }
        }

        Test-ForModuleUpdate

        $list = Get-PnPList -Identity $listName
        if (-not $list) {
            Write-Error "List '$listName' not found."
            return
        }
        Write-Host "Looking for items in the Recycle Bin that belong to the list '$listName'..."

        $items = Get-PnPRecycleBinItem | Where-Object { $_.DirName -eq $list.RootFolder.ServerRelativeUrl.TrimStart('/') } 
        Write-Host -ForegroundColor Yellow "WARNING: This will Restore all $($items.Count) items in the list '$listName'."
        $input = Read-Host "Are you sure you want to continue? Type 'Y' to confirm"
        if ($input -ne "Y") {
            Write-Host -ForegroundColor Yellow "Operation cancelled."
            return
        }

        $items | ForEach-Object {
            Write-Host -NoNewline "Restoring item: $($_.Title)"
            Restore-PnPRecycleBinItem -Identity $_.Id -Force
            Write-Host -ForegroundColor Green " .....Done!"
        }

    }
    catch {
        if ($_.Exception.Message -eq "The current connection holds no SharePoint context. Please use one of the Connect-PnPOnline commands which uses the -Url argument to connect.") {
            Write-Error "The current connection holds no SharePoint context. Please use one of the Connect-SP365 commands which uses the -Url argument to connect."
        }
        else {
            Write-Error $_.Exception.Message
        }
    }
}
Export-ModuleMember -Function *
