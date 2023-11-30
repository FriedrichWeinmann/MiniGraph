function Update-Token {
	<#
	.SYNOPSIS
		Automatically reconnects if necessary, using the previous method of connecting.
	
	.DESCRIPTION
		Automatically reconnects if necessary, using the previous method of connecting.
		Called from within Invoke-GraphRequest, it ensures that tokens don't expire, especially during long-running queries.

		Will not cause errors directly, but the reconnection attempt might fail.
	
	.EXAMPLE
		PS C:\> Update-Token
		
		Automatically reconnects if necessary, using the previous method of connecting.
	#>
	[CmdletBinding()]
	param (
		
	)
	
	process {
		# If no reconnection data is set, terminate
		if (-not $script:lastConnect) { return }
		if (-not $script:lastConnect.When) { return }
		# If the last connection is less than 50 minutes ago, terminate
		if ($script:lastConnect.When -gt (Get-Date).AddMinutes(-50)) { return }

		if ($script:lastConnect.Refresh) {
			Connect-GraphRefreshToken
			return
		}

		$command = $script:lastConnect.Command
		$param = $script:lastConnect.Parameters
		& $command @param
	}
}