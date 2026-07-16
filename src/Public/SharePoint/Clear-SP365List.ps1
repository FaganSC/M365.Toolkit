function Clear-SP365List {
    <#
    .SYNOPSIS
        Deletes or recycles every item in a SharePoint list.

    .DESCRIPTION
        Retrieves items from the specified SharePoint list in batches and removes
        them until the list is empty. Items are permanently deleted by default.
        Use Recycle to send items to the SharePoint recycle bin instead.

        The command requires an active SharePoint connection and prompts for
        confirmation before making changes. Enter an uppercase Y to continue.

    .PARAMETER ListName
        The name or identity of the SharePoint list to clear.

    .PARAMETER Recycle
        Sends removed items to the SharePoint recycle bin. Without this switch,
        the items are permanently deleted.

    .EXAMPLE
        Clear-SP365List -ListName 'Import Queue'

        Prompts for confirmation and permanently deletes every item in the list.

    .EXAMPLE
        Clear-SP365List -ListName 'Import Queue' -Recycle

        Prompts for confirmation and sends every item in the list to the recycle bin.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .NOTES
        This command is destructive. Confirm the current site and selected list
        before entering Y.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $ListName,
        [Parameter(Mandatory = $false)]
        [switch]$Recycle = $false
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
        if ($Recycle) {
            Write-Host -ForegroundColor Yellow "WARNING: This will Recycle all $($list.ItemCount) items in the list '$listName'."
        }
        else {
            Write-Host -ForegroundColor Yellow "WARNING: This will permanently delete all $($list.ItemCount) items in the list '$listName'."
        }
        $input = Read-Host "Are you sure you want to continue? Type 'Y' to confirm"
        if ($input -ne "Y") {
            Write-Host -ForegroundColor Yellow "Operation cancelled."
            return
        }

        $deletedCounter = 0
        $itemTotal = (Get-PnPList -Identity $listName).ItemCount
        do {
            Write-Host -NoNewline "Retrieving items from list '$listName' (Total Items: $itemTotal)"
            $items = Get-PnPListItem -List $listName -PageSize 1000 
            Write-Host -ForegroundColor Green " .....Done!"
            Write-Host -NoNewline "Processing items for $($Recycle ? 'Recycling' : 'Deleting')"
            
            $items | ForEach-Object {
                $percent = "{0:n1}" -f (($deletedCounter / $itemTotal) * 100)
                Write-Progress -Activity "$($Recycle ? 'Recycling' : 'Deleting') SharePoint List Items: $listName (Items: $itemTotal)" -Status "$percent% Complete:" -PercentComplete $percent
                if ($Recycle) {
                    Remove-PnPListItem -List $listName -Identity $_.Id -Recycle -Force | Out-Null
                }
                else {
                    Remove-PnPListItem -List $listName -Identity $_.Id -Force | Out-Null
                }
                $deletedCounter++
            }
        } until ((Get-PnPList -Identity $listName).ItemCount -eq 0)
        Write-Host -ForegroundColor Green " .....Done!"
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