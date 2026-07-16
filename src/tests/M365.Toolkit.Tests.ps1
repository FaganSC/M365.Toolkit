BeforeAll {
    $ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $ModuleName = 'M365.Toolkit'
    Import-Module (Join-Path $ModuleRoot "$ModuleName.psd1") -Force
}

Describe 'M365.Toolkit module' {
    It 'imports successfully' {
        Get-Module -Name 'M365.Toolkit' | Should -Not -BeNullOrEmpty
    }

    It 'exports all public commands' {
        $expectedCommands = @(
            'Clear-SP365List'
            'Connect-SP365'
            'Copy-SP365Nav'
            'Get-M365ToolkitInfo'
            'Move-SP365Nav'
        )
        $exportedCommands = @(Get-Command -Module 'M365.Toolkit' -CommandType Function).Name

        $exportedCommands | Should -HaveCount $expectedCommands.Count
        foreach ($command in $expectedCommands) {
            $exportedCommands | Should -Contain $command
        }
    }

    It 'Get-M365ToolkitInfo returns expected properties' {
        $result = Get-M365ToolkitInfo
        $result.ModuleName | Should -Be 'M365.Toolkit'
    }
}

AfterAll {
    Remove-Module -Name 'M365.Toolkit' -ErrorAction SilentlyContinue
}
