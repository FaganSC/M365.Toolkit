BeforeAll {
    $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $ModuleName = 'M365.Toolkit'
    $ManifestPath = Join-Path $ModuleRoot "$ModuleName.psd1"
    $PublicPath = Join-Path $ModuleRoot 'src\Public'
    $ExpectedCommands = @(Get-ChildItem -Path $PublicPath -Filter '*.ps1' -Recurse).BaseName | Sort-Object
    $ManifestCommands = @(Import-PowerShellDataFile -Path $ManifestPath).FunctionsToExport | Sort-Object

    Import-Module $ManifestPath -Force
}

Describe 'M365.Toolkit module' {
    It 'imports successfully' {
        Get-Module -Name 'M365.Toolkit' | Should -Not -BeNullOrEmpty
    }

    It 'exports all public commands' {
        $exportedCommands = @(Get-Command -Module 'M365.Toolkit' -CommandType Function).Name | Sort-Object

        Compare-Object $ExpectedCommands $ManifestCommands | Should -BeNullOrEmpty
        Compare-Object $ExpectedCommands $exportedCommands | Should -BeNullOrEmpty
    }

    It 'Get-M365ToolkitInfo returns expected properties' {
        $result = Get-M365ToolkitInfo
        $result.ModuleName | Should -Be 'M365.Toolkit'
    }
}

AfterAll {
    Remove-Module -Name 'M365.Toolkit' -ErrorAction SilentlyContinue
}
