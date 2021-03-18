function ConvertTo-SignedString {
    <#
    .SYNOPSIS
        Signs a string.
    
    .DESCRIPTION
        Signs a string.
        Used for certificate authentication.
    
    .PARAMETER Text
        The text to sign.
    
    .PARAMETER Certificate
        The certificate to sign with.
        Must have private key.
    
    .PARAMETER Padding
        The padding mechanism to use while signing.
        Defaults to "Pkcs1"
    
    .PARAMETER Algorithm
        The signing algorithm to use.
        Defaults to "SHA256"
    
    .PARAMETER Encoding
        Encoding of the source text.
        Defaults to UTF8
    
    .EXAMPLE
        PS C:\> $token | ConvertTo-SignedString -Certificate $cert

        Signs the text stored in $token with the certificate stored in $cert
    #>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]]
		$Text,

		[System.Security.Cryptography.X509Certificates.X509Certificate2]
		$Certificate,

		[Security.Cryptography.RSASignaturePadding]
		$Padding = [Security.Cryptography.RSASignaturePadding]::Pkcs1,

		[Security.Cryptography.HashAlgorithmName]
		$Algorithm = [Security.Cryptography.HashAlgorithmName]::SHA256,

		[System.Text.Encoding]
		$Encoding = [System.Text.Encoding]::UTF8
	)

	process {
		foreach ($entry in $Text) {
			$inBytes = $Encoding.GetBytes($entry)
			$outBytes = $Certificate.PrivateKey.SignData($inBytes, $Algorithm, $Padding)
			[convert]::ToBase64String($outBytes)
		}
	}
}