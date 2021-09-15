function Set-GraphEndpoint {
    <#
    .SYNOPSIS
        Specify which graph endpoint to use for subsequent requests.
    
    .DESCRIPTION
        Specify which graph endpoint to use for subsequent requests.
    
    .PARAMETER Type
        Which kind of endpoint to use.
        v1 or beta

    .PARAMETER Url
        Specify a custom Url as endpoint.
        Used to switch to a government cloud.
    
    .EXAMPLE
        PS C:\> Set-GraphEndpoint -Type beta

        Switch to using the beta graph endpoint
    #>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [ValidateSet('v1','beta')]
        [string]
        $Type,

        [Parameter(Mandatory = $true, ParameterSetName = 'Url')]
        [string]
        $Url
    )

    if ($Type) {
        switch ($Type) {
            'v1' { $script:baseEndpoint = 'https://graph.microsoft.com/v1.0' }
            'beta' { $script:baseEndpoint = 'https://graph.microsoft.com/beta' }
        }
    }
    if ($Url) { $script:baseEndpoint = $Url.Trim("/") }
}