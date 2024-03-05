# Changelog

## 1.3.16 (2024-03-05)

+ New: Get-GraphToken - retrieve the currently used token
+ Upd: Connect-GraphBrowser - opens logon screen in the default browser by default
+ Fix: Invoke-GraphRequestBatch - retries stop failing

## 1.3.13 (2023-12-03)

+ Upd: Invoke-GraphRequestBatch - simplified requests specification

## 1.3.12 (2023-12-01)

+ New: Connect-GraphBrowser - Interactive logon using the Authorization flow and browser. Supports SSO.
+ New: Invoke-GraphRequestBatch - allows executing batch requests (thanks @nyanhp)
+ Upd: Added support for automatic token refresh once tokens expire
+ Upd: Connect-GraphCertificate - added -Scopes parameter to allow retrieving token for other service than graph
+ Fix: DeviceCode flow fails due to change in error message (thanks @nyanhp)

## 1.2.7 (ancient times)

+ All the previous features
