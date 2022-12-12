function Connect-GraphToken {
	<#
	.SYNOPSIS
		Connect to graph using a token and the on behalf of flow.
	
	.DESCRIPTION
		Connect to graph using a token and the on behalf of flow.
	
	.PARAMETER Token
		The existing token to use for the request.
	
	.PARAMETER TenantID
        The Guid of the tenant to connect to.

    .PARAMETER ClientID
        The ClientID / ApplicationID of the application to connect as.

    .PARAMETER ClientSecret
		The secret used to authorize the OBO flow.
	
	.PARAMETER Scopes
		The scopes to request
		Defaults to: 'https://graph.microsoft.com/.default'
	
	.EXAMPLE
		PS C:\> Connect-GraphToken -Token $token -TenantID $tenantID -ClientID $clientID -CLientSecret $secret

		Connect to graph using a token and the on behalf of flow.
	
	.LINK
		https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Token,

		[Parameter(Mandatory = $true)]
		[string]
		$TenantID,

		[Parameter(Mandatory = $true)]
		[string]
		$ClientID,

		[Parameter(Mandatory = $true)]
		[SecureString]
		$ClientSecret,
        
		[string[]]
		$Scopes = 'https://graph.microsoft.com/.default'
	)

	$body = @{
		grant_type          = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
		client_id           = $ClientID
		client_secret       = ([PSCredential]::new("Whatever", $ClientSecret)).GetNetworkCredential().Password
		assertion           = $Token
		scope               = @($Scopes)
		requested_token_use = 'on_behalf_of'
	}
	$param = @{
		Method = "POST"
		Uri =  "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
		Body = $body
		ContentType = 'application/x-www-form-urlencoded'
	}

	try { $script:token = Invoke-RestMethod @param -ErrorAction Stop }
	catch { $PSCmdlet.ThrowTerminatingError($_) }
}