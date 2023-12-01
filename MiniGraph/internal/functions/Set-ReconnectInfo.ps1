function Set-ReconnectInfo {
	<#
	.SYNOPSIS
		Helper Utility to set the automatic reconnection information.
	
	.DESCRIPTION
		Helper Utility to set the automatic reconnection information.
		Registers the connection time, parameters used and command for ease of reuse.
	
	.PARAMETER BoundParameters
		The parameters the Connect-Graph* command was called with
	
	.PARAMETER NoReconnect
		Whether to not reconnect after all.

	.PARAMETER RefreshToken
		The refresh token returned after the calling command's connection.
		When provided, will be used to do the refreshing when possible.
	
	.EXAMPLE
		PS C:\> Set-ReconnectInfo -BoundParameters $PSBoundParameters -NoReconnect:$NoReconnect
		
		Called from within a Connect-Graph* command, this will set itself to auto-reconnect.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		$BoundParameters,

		[switch]
		$NoReconnect,

		[string]
		$RefreshToken
	)
	process {
		if ($NoReconnect) {
			$script:lastConnect = @{
				When       = $null
				Command    = $null
				Parameters = $null
				Refresh    = $null
			}
			return
		}
		$script:lastConnect = @{
			When       = Get-Date
			Command    = Get-Command (Get-PSCallStack)[1].InvocationInfo.MyCommand
			Parameters = $BoundParameters
			Refresh    = $null
		}
		if ($RefreshToken) {
			$script:lastConnect.Refresh = $RefreshToken | ConvertTo-SecureString -AsPlainText -Force
		}
	}
}