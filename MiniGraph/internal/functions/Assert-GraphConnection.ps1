function Assert-GraphConnection
{
<#
	.SYNOPSIS
		Asserts a valid graph connection has been established.
	
	.DESCRIPTION
		Asserts a valid graph connection has been established.
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling command.
	
	.EXAMPLE
		PS C:\> Assert-GraphConnection -Cmdlet $PSCmdlet
	
		Asserts a valid graph connection has been established.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	process
	{
		if ($script:token) { return }
		
		$exception = [System.InvalidOperationException]::new('Not yet connected to MSGraph. Use Connect-Graph* to establish a connection!')
		$errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, "NotConnected", 'InvalidOperation', $null)
		
		$Cmdlet.ThrowTerminatingError($errorRecord)
	}
}