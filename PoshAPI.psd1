# PoshAPI.psd1
@{
    RootModule = 'PoshAPI.psm1'
    ModuleVersion = '0.1.0'
    GUID = 'b4e5dbf0-cde5-4a3c-9e07-5c288fe6dcaf'
    Author = 'Jim Tyler'
    CompanyName = '@PowerShellEngineer'
    Copyright = '(c) 2025 Your Name. All rights reserved.'
    Description = 'A template PowerShell module for building API integration suites'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Set-PoshAPIKey',
        'Set-PoshAPIDefaultSource',
        'Get-PoshAPIResource',
        'New-PoshAPIResource',
        'Update-PoshAPIResource',
        'Remove-PoshAPIResource',
        'Invoke-PoshAPIAction'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('API', 'Template', 'REST', 'Web')
            LicenseUri = 'https://github.com/JimRTyler/PoshAPI/blob/main/LICENSE'
            ProjectUri = 'https://github.com/JimRTyler/PoshAPI'
            ReleaseNotes = 'Initial release of PoshAPI template module'
        }
    }
}