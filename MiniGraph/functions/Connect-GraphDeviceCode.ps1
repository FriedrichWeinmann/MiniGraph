function Connect-GraphDeviceCode {
	<#
	.SYNOPSIS
		Connects to Azure AD using the Device Code authentication workflow.
	
	.DESCRIPTION
		Connects to Azure AD using the Device Code authentication workflow.

	.PARAMETER ClientID
		The ID of the registered app used with this authentication request.
	
	.PARAMETER TenantID
		The ID of the tenant connected to with this authentication request.

    .PARAMETER Scopes
        Generally doesn't need to be changed from the default 'https://graph.microsoft.com/.default'

	.PARAMETER Resource
		The resource the token grants access to.
		Generally doesn't need to be changed from the default 'https://graph.microsoft.com/'
		Only needed when connecting to another service.

	.PARAMETER NoReconnect
		Disables automatic reconnection.
		By default, MiniGraph will automatically try to reaquire a new token before the old one expires.
	
	.EXAMPLE
		PS C:\> Connect-GraphDeviceCode -ClientID '<ClientID>' -TenantID '<TenantID>'
	
		Connects to the specified tenant using the specified client, prompting the user to authorize via Browser.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
	[CmdletBinding()]
	param (

		[Parameter(Mandatory = $true)]
		[string]
		$ClientID,
        
		[Parameter(Mandatory = $true)]
		[string]
		$TenantID,
        
		[string[]]
		$Scopes = 'https://graph.microsoft.com/.default',

		[Uri]
		$Resource = 'https://graph.microsoft.com/',

		[switch]
		$NoReconnect
	)

	$actualScopes = foreach ($scope in $Scopes) {
		if ($scope -like 'https://*/*') { $scope }
		else { "{0}://{1}/{2}" -f $Resource.Scheme, $Resource.Host, $scope }
	}

	try {
		$initialResponse = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/devicecode" -Body @{
			client_id = $ClientID
			scope     = @($actualScopes) + 'offline_access' -join " "
		} -ErrorAction Stop
	}
	catch {
		throw
	}

	Write-Host $initialResponse.message

	$paramRetrieve = @{
		Uri    = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
		Method = "POST"
		Body   = @{
			grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
			client_id   = $ClientID
			device_code = $initialResponse.device_code
		}
		ErrorAction = 'Stop'
	}
	$limit = (Get-Date).AddSeconds($initialResponse.expires_in)
	while ($true) {
		if ((Get-Date) -gt $limit) {
			Invoke-TerminatingException -Cmdlet $PSCmdlet -Message "Timelimit exceeded, device code authentication failed" -Category AuthenticationError
		}
		Start-Sleep -Seconds $initialResponse.interval
		try { $authResponse = Invoke-RestMethod @paramRetrieve }
		catch {
			if ($_ -match '"error":\s*"authorization_pending"') { continue }
			$PSCmdlet.ThrowTerminatingError($_)
		}
		if ($authResponse) {
			break
		}
	}

	$script:token = $authResponse.access_token

	Set-ReconnectInfo -BoundParameters $PSBoundParameters -NoReconnect:$NoReconnect -RefreshToken $authResponse.refresh_token
}