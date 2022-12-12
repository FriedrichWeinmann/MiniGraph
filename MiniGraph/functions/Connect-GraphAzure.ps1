function Connect-GraphAzure {
	<#
	.SYNOPSIS
		Connect to graph using your current Az session.
	
	.DESCRIPTION
		Connect to graph using your current Az session.
		Requires the Az.Accounts module and for the current session to already be connected via Connect-AzAccount.

	.PARAMETER Authority
		Authority to connect to.
		Defaults to: "https://graph.microsoft.com"
	
	.EXAMPLE
		PS C:\> Connect-GraphAzure

		Connect to graph via the current Az session
	#>
	[CmdletBinding()]
	param (
		[string]
		$Authority = "https://graph.microsoft.com"
	)

	try { $azContext = Get-AzContext -ErrorAction Stop }
	catch { $PSCmdlet.ThrowTerminatingError($_) }

	try {
		$result = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
			$azContext.Account,
			$azContext.Environment,
			"$($azContext.Tenant.id)",
			$null,
			[Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never,
			$null,
			$Authority
		)
	
	}
	catch { $PSCmdlet.ThrowTerminatingError($_) }

	$script:token = $result.AccessToken
}