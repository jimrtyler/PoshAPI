# PoshAPI

PoshAPI is a PowerShell module template designed for creating API integration suites. It provides a consistent structure and interface for working with multiple API sources, making it easy to build standardized modules for various service categories.

## Features

- Multi-source API support with a unified interface
- Easy API key management
- Standardized command structure across all derived modules
- Support for common REST API operations (GET, POST, PUT, DELETE)
- Automatic response format normalization

## Installation

```powershell
# Clone the repository
git clone https://github.com/JimRTyler/PoshAPI.git

# Import the module
Import-Module .\PoshAPI\PoshAPI.psd1
```

## Basic Usage

### Setting API Keys and Authentication Requirements

```powershell
# Set API key for a specific source
Set-PoshAPIKey -Source 'Source1' -ApiKey 'your-api-key-here'

# Set default source
Set-PoshAPIDefaultSource -Source 'Source1'

# Configure whether a source requires authentication
# For APIs that don't require keys/authentication:
Set-PoshAPIAuthRequirement -Source 'Source3' -RequiresAuthentication $false
```

### Working with Resources

```powershell
# Get resources (uses default source if -Source not specified)
Get-PoshAPIResource [-Source 'Source1'] [-ResourceId 'id123'] [-QueryParameters @{param1 = 'value1'}]

# Create a new resource
New-PoshAPIResource [-Source 'Source1'] -ResourceData @{
    name = 'Resource Name'
    description = 'Resource Description'
}

# Update an existing resource
Update-PoshAPIResource [-Source 'Source1'] -ResourceId 'id123' -ResourceData @{
    name = 'Updated Name'
    status = 'active'
}

# Delete a resource
Remove-PoshAPIResource [-Source 'Source1'] -ResourceId 'id123'

# Perform a custom action
Invoke-PoshAPIAction [-Source 'Source1'] -Action 'customAction' [-ResourceId 'id123'] [-ActionParameters @{param1 = 'value1'}]
```

## Customizing for Your API Suite

This template is designed to be easily adaptable to different API suites. To create your own API module based on PoshAPI:

1. Copy the module files to a new directory with your module name (e.g., PSSocialSuite)
2. Update the module manifest (.psd1) with your module details
3. Modify the API source names and base URLs in the .psm1 file to match your target APIs
4. Customize the resource endpoints and parameter transformations for each API source
5. Add additional functions specific to your API suite

## Creating an API Suite

The PoshAPI template is designed to serve as a foundation for building consistent API integration suites such as:

- PSSocialSuite (Twitter, Facebook, LinkedIn, Instagram)
- PSPaymentSuite (Stripe, PayPal, Square, Braintree)
- PSMessagingSuite (Twilio, Nexmo, Plivo, MessageBird)
- And many more!

Each suite follows the same pattern, allowing users to seamlessly switch between different API sources within the same category.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
