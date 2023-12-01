# Changelog

## 1.3.12 (2023-12-01)

+ New: Connect-GraphBrowser - Interactive logon using the Authorization flow and browser. Supports SSO.
+ New: Invoke-GraphRequestBatch - allows executing batch requests (thanks @nyanhp)
+ Upd: Added support for automatic token refresh once tokens expire
+ Upd: Connect-GraphCertificate - added -Scopes parameter to allow retrieving token for other service than graph
+ Fix: DeviceCode flow fails due to change in error message (thanks @nyanhp)

## 1.2.7 (ancient times)

+ All the previous features
