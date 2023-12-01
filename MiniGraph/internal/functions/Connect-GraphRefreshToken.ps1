function Connect-GraphRefreshToken {
	<#
	.SYNOPSIS
		Connect with the refresh token provided previously.
	
	.DESCRIPTION
		Connect with the refresh token provided previously.
		Used mostly for delegate authentication flows to avoid interactivity.
	
	.EXAMPLE
		PS C:\> Connect-GraphRefreshToken
		
		Connect with the refresh token provided previously.
	#>
	[CmdletBinding()]
	param (
		
	)
	process {
		if (-not $script:lastConnect.Refresh) {
			throw "No refresh token found!"
		}

		$scopes = 'https://graph.microsoft.com/.default'
		if ($script:lastConnect.Parameters.Scopes) {
			$scopes = $script:lastConnect.Parameters.Scopes
		}

		$body = @{
			client_id = $script:lastConnect.Parameters.ClientID
			scope = $scopes -join " "
			refresh_token = [PSCredential]::new("whatever", $script:lastConnect.Refresh).GetNetworkCredential().Password
			grant_type = 'refresh_token'
		}
		$uri = "https://login.microsoftonline.com/$($script:lastConnect.Parameters.TenantID)/oauth2/v2.0/token"
		$authResponse = Invoke-RestMethod -Method Post -Uri $uri -Body $body
		$script:token = $authResponse.access_token
		$script:lastConnect.Refresh = $authResponse.refresh_token
	}
}