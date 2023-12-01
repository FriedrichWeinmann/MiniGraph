# Graph Token used for connections
$script:token = $null

# Endpoint used for queries
$script:baseEndpoint = 'https://graph.microsoft.com/v1.0'

# Cached Connection Data
$script:lastConnect = @{
	When       = $null
	Command    = $null
	Parameters = $null
	Refresh    = $null
}

# Used for Browser-Based interactive logon
$script:browserPath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'