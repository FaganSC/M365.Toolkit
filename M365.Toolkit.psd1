@{
    RootModule        = 'M365.Toolkit.psm1'
    ModuleVersion     = '1.0.0.5'
    GUID              = '34818f54-8e33-4e01-8db0-905b02cf7b76'
    Author            = 'Shawn Fagan'
    CompanyName       = 'Unknown'
    Copyright         = '(c) 2026 Shawn Fagan. All rights reserved.'
    Description       = 'Common tasks used when administrating Microsoft 365. This PowerShell module has been put together to help save time on some of the common tasks preformed. Over time, this Toolkit will have more functions added to it to help Administrators with some of the common actions.'
    PowerShellVersion = '7.4'
    RequiredModules   = @(
        @{ ModuleName = 'PnP.PowerShell'; ModuleVersion = '3.1.0' }
    )
    FunctionsToExport = @('Clear-SP365List','Connect-SP365','Copy-SP365Nav','Move-SP365Nav')
    CmdletsToExport   = '*'
    VariablesToExport = '*'
    AliasesToExport   = '*'
    PrivateData       = @{
        PSData = @{
            Tags       = @('Microsoft365', 'Office365', 'AzureAD', 'EntraId', 'O365', 'M365', 'ExchangeOnline', 'Exchange', 'SharePoint', 'SharePointOnline')
            LicenseUri = 'https://raw.githubusercontent.com/FaganSC/M365.Toolkit/master/LICENSE'
            ProjectUri = 'https://fagan.cloud/M365.Toolkit'
        } 
    } 
}