function Connect-GraphCertificate {
	<#
	.SYNOPSIS
		Connect to graph as an application using a certificate

    .DESCRIPTION
        Connect to graph as an application using a certificate

    .PARAMETER Certificate
        The certificate to use for authentication.
        
    .PARAMETER TenantID
        The Guid of the tenant to connect to.

    .PARAMETER ClientID
        The ClientID / ApplicationID of the application to connect as.

    .EXAMPLE
        PS C:\> $cert = Get-Item -Path 'Cert:\CurrentUser\My\082D5CB4BA31EED7E2E522B39992E34871C92BF5'
        PS C:\> Connect-GraphCertificate -TenantID '0639f07d-76e1-49cb-82ac-abcdefabcdefa' -ClientID '0639f07d-76e1-49cb-82ac-1234567890123' -Certificate $cert

        Connect to graph with the specified cert stored in the current user's certificate store.
	
	.LINK
		https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-certificate-credentials
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({
			if (-not $_.HasPrivateKey) { throw "Certificate has no private key!" }
			$true
		})]
		[System.Security.Cryptography.X509Certificates.X509Certificate2]
		$Certificate,

		[Parameter(Mandatory = $true)]
		[string]
		$TenantID,

		[Parameter(Mandatory = $true)]
		[string]
		$ClientID
	)

	$jwtHeader = @{
		alg = "RS256"
		typ = "JWT"
		x5t = [Convert]::ToBase64String($Certificate.GetCertHash()) -replace '\+', '-' -replace '/', '_' -replace '='
	}
	$encodedHeader = $jwtHeader | ConvertTo-Json | ConvertTo-Base64
	$claims = @{
		aud = "https://login.microsoftonline.com/$TenantID/v2.0"
		exp = ((Get-Date).AddMinutes(5) - (Get-Date -Date '1970.1.1')).TotalSeconds -as [int]
		iss = $ClientID
		jti = "$(New-Guid)"
		nbf = ((Get-Date) - (Get-Date -Date '1970.1.1')).TotalSeconds -as [int]
		sub = $ClientID
	}
	$encodedClaims = $claims | ConvertTo-Json | ConvertTo-Base64
	$jwtPreliminary = $encodedHeader, $encodedClaims -join "."
	$jwtSigned = ($jwtPreliminary | ConvertTo-SignedString -Certificate $Certificate) -replace '\+', '-' -replace '/', '_' -replace '='
	$jwt = $jwtPreliminary, $jwtSigned -join '.'

	$body = @{
		client_id             = $ClientID
		client_assertion      = $jwt
		client_assertion_type = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
		scope                 = 'https://graph.microsoft.com/.default'
		grant_type            = 'client_credentials'
	}
	$header = @{
		Authorization = "Bearer $jwt"
	}
	$uri = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
	try { $script:token = (Invoke-RestMethod -Uri $uri -Method Post -Body $body -Headers $header -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop).access_token }
    catch { $PSCmdlet.ThrowTerminatingError($_) }
}