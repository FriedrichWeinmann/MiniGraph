function Get-GraphToken {
	<#
	.SYNOPSIS
		Retrieve the currently used graph token.
	
	.DESCRIPTION
		Retrieve the currently used graph token.
		Use one of the Connect-Graph* commands to first establish a connection.
		The token retrieved is a static copy of the current token - it will not be automatically refreshed once expired.
	
	.EXAMPLE
		PS C:\> Get-GraphToken
		
		Retrieve the currently used graph token.
	#>
	[CmdletBinding()]
	param (
		
	)
	process {
		[PSCustomObject]@{
			Token = $script:token
			Created = $script:lastConnect.When
			HasRefresh = $script:lastConnect.Refresh -as [bool]
			Endpoint = $script:baseEndpoint
		}
	}
}