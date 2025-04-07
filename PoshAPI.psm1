# PoshAPI.psm1

# Module variables
$script:ConfigPath = Join-Path -Path $env:USERPROFILE -ChildPath '.poshapi'
$script:ConfigFile = Join-Path -Path $script:ConfigPath -ChildPath 'config.json'
$script:APISourceNames = @('Source1', 'Source2', 'Source3', 'Source4')

#region Helper Functions

function Initialize-Configuration {
    [CmdletBinding()]
    param()
    
    if (-not (Test-Path -Path $script:ConfigPath)) {
        New-Item -Path $script:ConfigPath -ItemType Directory -Force | Out-Null
    }
    
    if (-not (Test-Path -Path $script:ConfigFile)) {
        $defaultConfig = @{
            DefaultSource = $script:APISourceNames[0]
            ApiKeys = @{}
        }
        
        $script:APISourceNames | ForEach-Object {
            $defaultConfig.ApiKeys[$_] = ''
        }
        
        $defaultConfig | ConvertTo-Json | Out-File -FilePath $script:ConfigFile -Force
    }
}

function Get-Configuration {
    [CmdletBinding()]
    param()
    
    if (-not (Test-Path -Path $script:ConfigFile)) {
        Initialize-Configuration
    }
    
    Get-Content -Path $script:ConfigFile -Raw | ConvertFrom-Json
}

function Set-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$Config
    )
    
    $Config | ConvertTo-Json | Out-File -FilePath $script:ConfigFile -Force
}

function Invoke-ApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,
        
        [Parameter(Mandatory = $false)]
        [string]$Method = 'GET',
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Headers = @{},
        
        [Parameter(Mandatory = $false)]
        [hashtable]$QueryParameters = @{},
        
        [Parameter(Mandatory = $false)]
        [object]$Body
    )
    
    $config = Get-Configuration
    $apiKey = $config.ApiKeys[$Source]
    
    if ([string]::IsNullOrEmpty($apiKey)) {
        throw "API key for $Source is not configured. Please use Set-PoshAPIKey -Source $Source -ApiKey <your-api-key>"
    }
    
    # Define base URLs for each source
    $baseUrls = @{
        'Source1' = 'https://api.source1.com/v1'
        'Source2' = 'https://api.source2.com/v2'
        'Source3' = 'https://api.source3.com/v3'
        'Source4' = 'https://api.source4.com/v1'
    }
    
    # Add API key to headers or query parameters based on the source
    switch ($Source) {
        'Source1' { $Headers['Authorization'] = "Bearer $apiKey" }
        'Source2' { $Headers['X-Api-Key'] = $apiKey }
        'Source3' { $QueryParameters['apikey'] = $apiKey }
        'Source4' { $Headers['Authorization'] = "Token $apiKey" }
    }
    
    $uri = "$($baseUrls[$Source])/$Endpoint"
    
    # Build query string if parameters are provided
    if ($QueryParameters.Count -gt 0) {
        $queryString = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        foreach ($param in $QueryParameters.GetEnumerator()) {
            $queryString.Add($param.Key, $param.Value)
        }
        $uriBuilder = New-Object System.UriBuilder($uri)
        $uriBuilder.Query = $queryString.ToString()
        $uri = $uriBuilder.Uri.ToString()
    }
    
    $params = @{
        Uri     = $uri
        Method  = $Method
        Headers = $Headers
    }
    
    # Add body if provided
    if ($Body) {
        $params['Body'] = if ($Body -is [hashtable] -or $Body -is [PSCustomObject]) {
            $Body | ConvertTo-Json -Depth 5
        } else {
            $Body
        }
        
        # Default content type if not specified
        if (-not $Headers.ContainsKey('Content-Type')) {
            $params.Headers['Content-Type'] = 'application/json'
        }
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        Write-Error "API request failed: $_"
        throw $_
    }
}

#endregion

#region Public Functions

function Set-PoshAPIKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Source1', 'Source2', 'Source3', 'Source4')]
        [string]$Source,
        
        [Parameter(Mandatory = $true)]
        [string]$ApiKey
    )
    
    $config = Get-Configuration
    $config.ApiKeys[$Source] = $ApiKey
    Set-Configuration -Config $config
    
    Write-Output "API key for $Source has been set."
}

function Set-PoshAPIDefaultSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Source1', 'Source2', 'Source3', 'Source4')]
        [string]$Source
    )
    
    $config = Get-Configuration
    $config.DefaultSource = $Source
    Set-Configuration -Config $config
    
    Write-Output "Default API source set to $Source."
}

function Get-PoshAPIResource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Source1', 'Source2', 'Source3', 'Source4')]
        [string]$Source,
        
        [Parameter(Mandatory = $false)]
        [string]$ResourceId,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$QueryParameters = @{}
    )
    
    if (-not $Source) {
        $config = Get-Configuration
        $Source = $config.DefaultSource
    }
    
    # Common parameter transformation logic (if needed)
    $transformedParams = $QueryParameters.Clone()
    
    # Source-specific parameter adjustments
    switch ($Source) {
        'Source1' {
            $endpoint = "resources"
            if ($ResourceId) {
                $endpoint += "/$ResourceId"
            }
        }
        'Source2' {
            $endpoint = "resource"
            if ($ResourceId) {
                $transformedParams['id'] = $ResourceId
            }
        }
        'Source3' {
            $endpoint = "resources"
            if ($ResourceId) {
                $endpoint += "/$ResourceId"
            }
        }
        'Source4' {
            $endpoint = "resources"
            if ($ResourceId) {
                $endpoint += "/$ResourceId"
            }
        }
    }
    
    $response = Invoke-ApiRequest -Source $Source -Endpoint $endpoint -QueryParameters $transformedParams
    
    # Transform response to a common format if needed
    switch ($Source) {
        'Source1' { 
            # Transform Source1 response to common format
            return $response 
        }
        'Source2' { 
            # Transform Source2 response to common format
            return $response 
        }
        'Source3' { 
            # Transform Source3 response to common format
            return $response 
        }
        'Source4' { 
            # Transform Source4 response to common format
            return $response 
        }
    }
}

function New-PoshAPIResource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Source1', 'Source2', 'Source3', 'Source4')]
        [string]$Source,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$ResourceData
    )
    
    if (-not $Source) {
        $config = Get-Configuration
        $Source = $config.DefaultSource
    }
    
    # Source-specific endpoint and parameter adjustments
    switch ($Source) {
        'Source1' { $endpoint = "resources" }
        'Source2' { $endpoint = "resource" }
        'Source3' { $endpoint = "resources" }
        'Source4' { $endpoint = "resources" }
    }
    
    $response = Invoke-ApiRequest -Source $Source -Endpoint $endpoint -Method 'POST' -Body $ResourceData
    
    # Transform response to a common format if needed
    return $response
}

function Update-PoshAPIResource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Source1', 'Source2', 'Source3', 'Source4')]
        [string]$Source,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceId,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$ResourceData
    )
    
    if (-not $Source) {
        $config = Get-Configuration
        $Source = $config.DefaultSource
    }
    
    # Source-specific endpoint and parameter adjustments
    switch ($Source) {
        'Source1' { $endpoint = "resources/$ResourceId" }
        'Source2' { 
            $endpoint = "resource"
            $ResourceData['id'] = $ResourceId
        }
        'Source3' { $endpoint = "resources/$ResourceId" }
        'Source4' { $endpoint = "resources/$ResourceId" }
    }
    
    $method = switch ($Source) {
        'Source1' { 'PUT' }
        'Source2' { 'POST' }
        'Source3' { 'PATCH' }
        'Source4' { 'PUT' }
    }
    
    $response = Invoke-ApiRequest -Source $Source -Endpoint $endpoint -Method $method -Body $ResourceData
    
    # Transform response to a common format if needed
    return $response
}

function Remove-PoshAPIResource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Source1', 'Source2', 'Source3', 'Source4')]
        [string]$Source,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceId
    )
    
    if (-not $Source) {
        $config = Get-Configuration
        $Source = $config.DefaultSource
    }
    
    # Source-specific endpoint and parameter adjustments
    switch ($Source) {
        'Source1' { $endpoint = "resources/$ResourceId" }
        'Source2' { 
            $endpoint = "resource"
            $queryParams = @{ id = $ResourceId }
            $response = Invoke-ApiRequest -Source $Source -Endpoint $endpoint -Method 'DELETE' -QueryParameters $queryParams
            return $response
        }
        'Source3' { $endpoint = "resources/$ResourceId" }
        'Source4' { $endpoint = "resources/$ResourceId" }
    }
    
    $response = Invoke-ApiRequest -Source $Source -Endpoint $endpoint -Method 'DELETE'
    
    # Transform response to a common format if needed
    return $response
}

function Invoke-PoshAPIAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Source1', 'Source2', 'Source3', 'Source4')]
        [string]$Source,
        
        [Parameter(Mandatory = $true)]
        [string]$Action,
        
        [Parameter(Mandatory = $false)]
        [string]$ResourceId,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$ActionParameters = @{}
    )
    
    if (-not $Source) {
        $config = Get-Configuration
        $Source = $config.DefaultSource
    }
    
    # Source-specific endpoint and parameter adjustments
    switch ($Source) {
        'Source1' { 
            if ($ResourceId) {
                $endpoint = "resources/$ResourceId/$Action"
            } else {
                $endpoint = "actions/$Action"
            }
        }
        'Source2' { 
            $endpoint = "resource/action"
            $ActionParameters['action'] = $Action
            if ($ResourceId) {
                $ActionParameters['id'] = $ResourceId
            }
        }
        'Source3' { 
            if ($ResourceId) {
                $endpoint = "resources/$ResourceId/actions/$Action"
            } else {
                $endpoint = "actions/$Action"
            }
        }
        'Source4' { 
            if ($ResourceId) {
                $endpoint = "resources/$ResourceId/$Action"
            } else {
                $endpoint = "$Action"
            }
        }
    }
    
    $response = Invoke-ApiRequest -Source $Source -Endpoint $endpoint -Method 'POST' -Body $ActionParameters
    
    # Transform response to a common format if needed
    return $response
}

#endregion

# Initialize module on import
Initialize-Configuration

# Export functions
Export-ModuleMember -Function @(
    'Set-PoshAPIKey',
    'Set-PoshAPIDefaultSource',
    'Get-PoshAPIResource',
    'New-PoshAPIResource',
    'Update-PoshAPIResource',
    'Remove-PoshAPIResource',
    'Invoke-PoshAPIAction'
)