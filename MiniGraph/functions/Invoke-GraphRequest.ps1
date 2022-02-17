function Invoke-GraphRequest {
    <#
    .SYNOPSIS
        Execute a request against the graph API
    
    .DESCRIPTION
        Execute a request against the graph API
    
    .PARAMETER Query
        The relative graph query with all conditions appended.
    
    .PARAMETER Method
        Which rest method to use.
        Defaults to GET.
    
    .PARAMETER ContentType
        Which content type to specify.
        Defaults to "Application/Json"
    
    .PARAMETER Body
        Any body to specify.
        Anything not a string, will be converted to json.
    
    .PARAMETER Raw
        Return the raw response, rather than processing the output.
    
    .PARAMETER NoPaging
        Only return the first set of data, rather than paging through the entire set.

	.PARAMETER Header
		Additional header entries to include beside authentication
    
    .EXAMPLE
        PS C:\> Invoke-GraphRequest -Query me

        Returns information about the current user.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Query,

        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = 'GET',

        [string]
        $ContentType = 'application/json',

        $Body,

        [switch]
        $Raw,

        [switch]
        $NoPaging,

		[hashtable]
		$Header = @{ }
    )

    begin {
        Assert-GraphConnection -Cmdlet $PSCmdlet
    }
    process {
        $parameters = @{
            Uri         = "$($script:baseEndpoint)/$($Query.TrimStart("/"))"
            Method      = $Method
            Headers     = @{ Authorization = "Bearer $($script:Token)" } + $Header
            ContentType = $ContentType
        }
        if ($Body) {
			if ($Body -is [string]) { $parameters.Body = $Body }
			else { $parameters.Body = $Body | ConvertTo-Json -Compress -Depth 99 }
		}
        do {
            try { $data = Invoke-RestMethod @parameters -ErrorAction Stop }
            catch { throw }
            if ($Raw) { $data }
            elseif ($data.Value) { $data.Value }
            elseif ($data -and $null -eq $data.Value) { $data }
            $parameters.Uri = $data.'@odata.nextLink'
        }
        until (-not $data.'@odata.nextLink' -or $NoPaging)
    }
}