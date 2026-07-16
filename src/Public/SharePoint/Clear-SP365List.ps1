function Clear-SP365List {
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