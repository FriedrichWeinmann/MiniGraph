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