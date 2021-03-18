# MiniGraph

## Introduction

The MiniGraph module is designed as a minimal overhead Microsoft Graph client implementation.
It is intended for lean environments such as Azure Functions where a maximum performance in all aspects is required.

## Installation

The module has been published to the PowerShell Gallery.
To install it, run:

```powershell
Install-Module MiniGraph
```

## Use

> Authenticate

First you need to authenticate.
Three authentication workflows are provided:

+ Application: Certificate
+ Application: Secret
+ Delegate: Username & Password

For example, the connection with a certificate object could work like this:

```powershell
$cert = Get-Item -Path 'Cert:\CurrentUser\My\082D5CB4BA31EED7E2E522B39992E34871C92BF5'
Connect-GraphCertificate -TenantID '0639f07d-76e1-49cb-82ac-abcdefabcdefa' -ClientID '0639f07d-76e1-49cb-82ac-1234567890123' -Certificate $cert
```

> Execute

After connecting to graph, execute queries like this:

```powershell
# Return all groups
Invoke-GraphRequest -Query groups
```

You can now basically follow the guidance in the graph api reference and take it from there.

> Graph Beta Endpoint

If you need to work against the beta endpoint, switching to that for the current session can be done like this:

```powershell
Set-GraphEndpoint -Type beta
```

## Common Issues

> Scopes

Make sure you verify the scopes (permissions) needed for a request.
They must be assigned as Api Permission in the registered application in the Azure portal.
Admin Consent must be given for Application permissions.
For delegate permissions, either Admin Consent or User Consent must have been granted, as `Connect-GraphCredential` does not support any mechanisms to request Consent.

> Must contain client_assertion or client_secret

This usually happens when trying to connect with credentials.
The registered application must be configured for this authentication type in the authentication tab:

+ In Platform configurations, add a Web Platform with redirect URI "http://localhost"
+ In Advanced settings, enable "Allow public client flows"
