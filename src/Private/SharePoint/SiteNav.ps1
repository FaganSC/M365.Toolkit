function Get-SiteNav {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PnP.Framework.Enums.NavigationType] $NavigationNodeLocation
    )

    $nav = New-Object System.Collections.ArrayList
    Get-PnPNavigationNode -Location $NavigationNodeLocation | ForEach-Object {
        Write-Host -NoNewline "$($_.Title)"
        Write-Verbose "Node ID: $($_.Id), Node URL: $($_.Url), Node Title: $($_.Title)"
        $ParentNode = Get-PnPNavigationNode -Id $_.Id
        $ParentNode | Add-Member NoteProperty -Name "ParentNode" -Value $null
        $ParentNode | Add-Member NoteProperty -Name "NodeLevel" -Value 1
        $nav.Add($ParentNode) | Out-Null
        Write-Host -ForegroundColor Green " .....Done!"
        $ParentNode.Children | ForEach-Object {
            Write-Host -NoNewline "     $($_.Title)"
            Write-Verbose "     Node ID: $($_.Id), Node URL: $($_.Url), Node Title: $($_.Title)"
            $Node = Get-PnPNavigationNode -Id $_.Id
            $Node | Add-Member NoteProperty -Name "ParentNode" -Value $ParentNode.Id    
            $Node | Add-Member NoteProperty -Name "NodeLevel" -Value 2
            $nav.Add($Node) | Out-Null
            Write-Host -ForegroundColor Green " .....Done!"
            $Node.Children | ForEach-Object {
                Write-Host -NoNewline "          $($_.Title)"
                Write-Verbose "          Node ID: $($_.Id), Node URL: $($_.Url), Node Title: $($_.Title)"
                $SecondNode = Get-PnPNavigationNode -Id $_.Id
                $SecondNode | Add-Member NoteProperty -Name "ParentNode" -Value $Node.Id    
                $SecondNode | Add-Member NoteProperty -Name "NodeLevel" -Value 3
                $nav.Add($SecondNode) | Out-Null
                Write-Host -ForegroundColor Green " .....Done!"
            }
        }
    }
    Write-Host ""
    return $nav  
}
    
function Add-SiteNav($newNavNodes, [PnP.Framework.Enums.NavigationType] $Location) {
    try {
        $blHasErrors = $false
        Write-Host "Starting Process to create New Nav Nodes in Target Site"
        $nodeParentMatch = @{}
        $nodeChildMatch = @{}
        $newNavNodes | ForEach-Object {
            try {
                $node = $_
                Write-Host -NoNewline "Adding navigation node (Level $($node.NodeLevel)): $($node.Title)"
                if ($node.NodeLevel -eq 1) {
                    Write-Verbose "Node ID: $($node.Id), Node URL: $($node.Url), Node Title: $($node.Title)"
                    $newNode = Add-PnPNavigationNode -Location $Location -Title $node.Title -Url $node.Url
                    $nodeParentMatch[$node.Id] = $newNode.Id
                }
                elseif ( $node.NodeLevel -eq 2) {
                    Write-Verbose "Node ID: $($node.Id), Node URL: $($node.Url), Node Title: $($node.Title), Parent Node ID: $($node.ParentNode)"
                    $parentId = $nodeParentMatch[$node.ParentNode]
                    $newNode = Add-PnPNavigationNode -Location $Location -Title $node.Title -Url $node.Url -Parent $parentId -External
                    $nodeChildMatch[$node.Id] = $newNode.Id
                }
                elseif ( $node.NodeLevel -eq 3) {
                    Write-Verbose "Node ID: $($node.Id), Node URL: $($node.Url), Node Title: $($node.Title), Parent Node ID: $($node.ParentNode)"
                    $parentId = $nodeChildMatch[$node.ParentNode]
                    $newNode = Add-PnPNavigationNode -Location $Location -Title $node.Title -Url $node.Url -Parent $parentId -External
                }
                Write-Host -ForegroundColor Green " .....Done!"
            }
            catch {
                $blHasErrors = $true
                Write-Host -ForegroundColor Red " .....Failed!"
                Write-Error "An error occurred while adding navigation node $($node.Title): $($_.Exception.Message)"
                Write-Verbose "An error occurred while adding navigation node $($node.Title): $($_.Exception.Message)"
            }
        }
        if ($blHasErrors) {
            Write-Host -ForegroundColor Yellow "Some navigation nodes failed to be added. Please check the error messages above."
        }
        else {
            Write-Host -ForegroundColor Green "All navigation nodes added successfully."
        }
    }
    catch {
        Write-error "An error occurred while adding navigation nodes: $($_.Exception.Message)"
        Write-Verbose "An error occurred while adding navigation nodes: $($_.Exception.Message)"
    }
}
    
function Clear-SiteNav([PnP.Framework.Enums.NavigationType] $Location) {
    Write-Host -NoNewline "Clearing Current Nav Nodes"
    Get-PnPNavigationNode -Location $Location | ForEach-Object {
        Remove-PnPNavigationNode $_ -Force
    }
    Write-Host -f Green " .....Done!"
}
    