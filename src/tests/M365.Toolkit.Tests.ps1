Install-Module -Name PSScriptAnalyzer -Force -WarningAction SilentlyContinue
describe 'Module Level Tests' {
    <# it 'Module Imports' {
        { 
            try {
                Import-Module "$parentFolder\M365.Toolkit.psm1"
            } catch {
                throw $_
            }
        } | should -not throw
    }
#>
    it 'Module has an Associated Manifest' {
        Test-Path "$($pwd)\M365.Toolkit.psd1" | should -Be $true
    }
    <#
    it 'Passes all default PSScriptAnalyzer rules' {
        Invoke-ScriptAnalyzer -Path "$parentFolder\M365.Toolkit.psm1" | should -BeNullOrEmpty
    }
        #>
}