function Invoke-GraphRequestBatch {
	<#
    .SYNOPSIS
        Invoke a batch request against the graph API

    .DESCRIPTION
        Invoke a batch request against the graph API in batches of twenty.

    .PARAMETER Request
        A list of requests to batch.
		Each entry should either be ...
		- A relative uri to query (what you would send to Invoke-GraphRequest)
		- A hashtable consisting of url (mandatory), method (optional), id (optional), body (optional), headers (optional) and dependsOn (optional).

	.PARAMETER Method
		The method to use with requests, that do not specify their method.
		Defaults to "GET"

	.PARAMETER Body
		The body to add to requests that do not specify their own body.

	.PARAMETER Header
		The header to add to requests that do not specify their own header.

	.EXAMPLE
		$servicePrincipals = Invoke-GraphRequest -Query "servicePrincipals?&`$filter=accountEnabled eq true"
		$requests = @($servicePrincipals).ForEach{ "/servicePrincipals/$($_.id)/appRoleAssignments" }
		Invoke-GraphRequestBatch -Request $requests

		Retrieve the role assignments for all enabled service principals

	.EXAMPLE
		$servicePrincipals = Invoke-GraphRequest -Query "servicePrincipals?&`$filter=accountEnabled eq false"
		$requests = @($servicePrincipals).ForEach{ "/servicePrincipals/$($_.id)" }
		Invoke-GraphRequestBatch -Request $requests -Body { accountEnabled = $true } -Method PATCH

		Enables all disabled service principals

    .EXAMPLE
        $servicePrincipals = Invoke-GraphRequest -Query "servicePrincipals?&`$filter=accountEnabled eq true"
        $araCounter = 1
        $idToSp = @{}
        $appRoleAssignmentsRequest = foreach ($sp in $servicePrincipals)
        {
            @{
                url    = "/servicePrincipals/$($sp.id)/appRoleAssignments"
                method = "GET"
                id     = $araCounter
            }
            $idToSp[$araCounter] = $sp
            $araCounter++
        }
		Invoke-GraphRequestBatch -Request $appRoleAssignmentsRequest

		Retrieve the role assignments for all enabled service principals
    #>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[object[]]
		$Request,

		[Microsoft.PowerShell.Commands.WebRequestMethod]
		$Method = 'Get',

		[hashtable]
		$Body,

		[hashtable]
		$Header
	)

	begin {
		function ConvertTo-BatchRequest {
			[CmdletBinding()]
			param (
				[object[]]
				$Request,

				[Microsoft.PowerShell.Commands.WebRequestMethod]
				$Method,

				$Cmdlet,

				[AllowNull()]
				[hashtable]
				$Body,
		
				[AllowNull()]
				[hashtable]
				$Header
			)
			$defaultMethod = "$Method".ToUpper()

			$results = @{}
			$requests = foreach ($entry in $Request) {
				$newRequest = @{
					url = ''
					method = $defaultMethod
					id = 0
				}
				if ($Body) { $newRequest.body = $Body }
				if ($Header) { $newRequest.headers = $Header }
				if ($entry -is [string]) {
					$newRequest.url = $entry
					$newRequest
					continue
				}

				if (-not $entry.url) {
					Invoke-TerminatingException -Cmdlet $Cmdlet -Message "Invalid batch request: No Url found! $entry" -Category InvalidArgument
				}
				$newRequest.url = $entry.url
				if ($entry.Method) {
					$newRequest.method = "$($entry.Method)".ToUpper()
				}
				if ($entry.id -as [int]) {
					$newRequest.id = $entry.id -as [int]
					$results[($entry.id -as [int])] = $newRequest
				}
				if ($entry.body) {
					$newRequest.body = $entry.body
				}
				if ($entry.headers) {
					$newRequest.headers = $entry.headers
				}
				if ($entry.dependsOn) {
					$newRequest.dependsOn
				}
				$newRequest
			}

			$index = 1
			$finalList = foreach ($requestItem in $requests) {
				$requestItem.id = $requestItem.id -as [string]
				if ($requestItem.id) {
					$requestItem
					continue
				}

				while ($results[$index]) {
					$index++
				}
				$requestItem.id = $index
				$results[$index] = $requestItem
				$requestItem
			}

			$finalList | Sort-Object { $_.id -as [int] }
		}
	}

	process {
		$batchSize = 20 # Currently hardcoded API limit
		$counter = [pscustomobject] @{ Value = 0 }
		$batches = ConvertTo-BatchRequest -Request $Request -Method $Method -Cmdlet $PSCmdlet -Body $Body -Header $Header | Group-Object -Property { [math]::Floor($counter.Value++ / $batchSize) } -AsHashTable

		foreach ($batch in ($batches.GetEnumerator() | Sort-Object -Property Key)) {
			[array] $innerResult = try {
				$jsonbody = @{requests = [array]$batch.Value } | ConvertTo-Json -Depth 42 -Compress
            (MiniGraph\Invoke-GraphRequest -Query '$batch' -Method Post -Body $jsonbody -ErrorAction Stop).responses
			}
			catch {
				Write-Error -Message "Error sending batch: $($_.Exception.Message)" -TargetObject $jsonbody
				continue
			}

			$throttledRequests = $innerResult | Where-Object status -EQ 429
			$failedRequests = $innerResult | Where-Object { $_.status -ne 429 -and $_.status -in (400..499) }
			$successRequests = $innerResult | Where-Object status -In (200..299)

			foreach ($failedRequest in $failedRequests) {
				Write-Error -Message "Error in batch request $($failedRequest.id): $($failedRequest.body.error.message)"
			}

			if ($successRequests) {
				$successRequests
			}

			if ($throttledRequests) {
				$interval = ($throttledRequests.Headers | Sort-Object 'Retry-After' | Select-Object -Last 1).'Retry-After'
				Write-Verbose -Message "Throttled requests detected, waiting $interval seconds before retrying"

				Start-Sleep -Seconds $interval
				$retry = $Request | Where-Object id -In $throttledRequests.id

				if (-not $retry) {
					continue
				}

				try {
                (MiniGraph\Invoke-GraphRequestBatch -Name $Name -Request $retry -NoProgress -ErrorAction Stop).responses
				}
				catch {
					Write-Error -Message "Error sending retry batch: $($_.Exception.Message)" -TargetObject $retry
				}
			}
		}
	}
}