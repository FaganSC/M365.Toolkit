function Clear-SP365List {
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

        $deletedCounter = 0
        $itemTotal = (Get-PnPList -Identity $listName).ItemCount
        do {
            Get-PnPListItem -List $listName -PageSize 4500 | ForEach-Object {
                $percent = "{0:n1}" -f (($deletedCounter / $itemTotal) * 100)
                Write-Progress -Activity "Truncating SharePoint List: $listName (Items: $itemTotal)" -Status "$percent% Complete:" -PercentComplete $percent
                Remove-PnPListItem -List $listName -Identity $_.Id -Force
                $deletedCounter++
            }
        } until ((Get-PnPList -Identity $listName).ItemCount -eq 0)
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