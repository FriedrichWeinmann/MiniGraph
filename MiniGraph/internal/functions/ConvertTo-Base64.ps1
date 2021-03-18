function ConvertTo-Base64 {
    <#
    .SYNOPSIS
        Converts input string to base 64.
    
    .DESCRIPTION
        Converts input string to base 64.
    
    .PARAMETER Text
        The text to encode.
    
    .PARAMETER Encoding
        The encoding of the input text.
    
    .EXAMPLE
        PS C:\> "Hello World" | ConvertTo-Base64

        Converts the string "Hello World" to base 64.
    #>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]]
		$Text,

		[System.Text.Encoding]
		$Encoding = [System.Text.Encoding]::UTF8
	)

	process {
		foreach ($entry in $Text) {
			$bytes = $Encoding.GetBytes($entry)
			[Convert]::ToBase64String($bytes)
		}
	}
}