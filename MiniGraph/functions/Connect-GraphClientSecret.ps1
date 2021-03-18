function Connect-GraphClientSecret {
    <#
		.SYNOPSIS
			Connects using a client secret.
		
		.DESCRIPTION
			Connects using a client secret.
		
		.PARAMETER ClientID
			The ID of the registered app used with this authentication request.
		
		.PARAMETER TenantID
			The ID of the tenant connected to with this authentication request.
		
		.PARAMETER ClientSecret
			The actual secret used for authenticating the request.

        .PARAMETER Scopes
            Generally doesn't need to be changed from the default 'https://graph.microsoft.com/.default'
            
		.EXAMPLE
			PS C:\> Connect-GraphClientSecret -ClientID '<ClientID>' -TenantID '<TenantID>' -ClientSecret $secret
		
			Connects to the specified tenant using the specified client and secret.
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ClientID,
			
        [Parameter(Mandatory = $true)]
        [string]
        $TenantID,
			
        [Parameter(Mandatory = $true)]
        [securestring]
        $ClientSecret,

        [string[]]
        $Scopes = 'https://graph.microsoft.com/.default'
    )
		
    process {
        $body = @{
            client_id     = $ClientID
            client_secret = [PSCredential]::new('NoMatter', $ClientSecret).GetNetworkCredential().Password
            scope         = $Scopes -join " "
            grant_type    = 'client_credentials'
        }
        try { $authResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" -Body $body -ErrorAction Stop }
        catch { throw }
		$script:token = $authResponse.access_token
    }
}