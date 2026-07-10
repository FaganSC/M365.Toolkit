function Get-SiteNav {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PnP.Framework.Enums.NavigationType] $NavigationNodeLocation
    )
    $nav = New-Object System.Collections.ArrayList
    Get-PnPNavigationNode -Location $NavigationNodeLocation | ForEach-Object {
        Write-Verbose "Processing navigation node $($_.Title)"
        $ParentNode = Get-PnPNavigationNode -Id $_.Id
        $ParentNode | Add-Member NoteProperty -Name "ParentNode" -Value $null
        $ParentNode | Add-Member NoteProperty -Name "NodeLevel" -Value 1
        $nav.Add($ParentNode) | Out-Null
        $ParentNode.Children | ForEach-Object {
            Write-Verbose "     Processing navigation node $($_.Title)"
            $Node = Get-PnPNavigationNode -Id $_.Id
            $Node | Add-Member NoteProperty -Name "ParentNode" -Value $ParentNode.Id    
            $Node | Add-Member NoteProperty -Name "NodeLevel" -Value 2
            $nav.Add($Node) | Out-Null
            $Node.Children | ForEach-Object {
                Write-Verbose "          Processing navigation node $($_.Title)"
                $SecondNode = Get-PnPNavigationNode -Id $_.Id
                $SecondNode | Add-Member NoteProperty -Name "ParentNode" -Value $Node.Id    
                $SecondNode | Add-Member NoteProperty -Name "NodeLevel" -Value 3
                $nav.Add($SecondNode) | Out-Null
            }
        }
    }
    Write-Host ""
    return $nav  
}
    
function Add-SiteNav($newNavNodes, [PnP.Framework.Enums.NavigationType] $Location) {
    Write-Host -NoNewline "Creating New Nav Nodes"
    $nodeParentMatch = @{}
    $nodeChildMatch = @{}
    $newNavNodes | ForEach-Object {
        $node = $_
        if ($node.NodeLevel -eq 1) {
            $newNode = Add-PnPNavigationNode -Location $Location -Title $node.Title -Url $node.Url
            $nodeParentMatch[$node.Id] = $newNode.Id
        }
        elseif ( $node.NodeLevel -eq 2) {
            $parentId = $nodeParentMatch[$node.ParentNode]
            $newNode = Add-PnPNavigationNode -Location $Location -Title $node.Title -Url $node.Url -Parent $parentId -External
            $nodeChildMatch[$node.Id] = $newNode.Id
        }
        elseif ( $node.NodeLevel -eq 3) {
            $parentId = $nodeChildMatch[$node.ParentNode]
            $newNode = Add-PnPNavigationNode -Location $Location -Title $node.Title -Url $node.Url -Parent $parentId -External
        }
    }
    Write-Host -f Green ".....Done!"
}
    
function Clear-SiteNav([PnP.Framework.Enums.NavigationType] $Location) {
    Write-Host -NoNewline "Clearing Current Nav Nodes"
    Get-PnPNavigationNode -Location $Location | ForEach-Object {
        Remove-PnPNavigationNode $_ -Force
    }
    Write-Host -f Green ".....Done!"
}
    