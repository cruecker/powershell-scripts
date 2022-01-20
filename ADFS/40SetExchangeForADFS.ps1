#region Variablen
$uris = @("https://<owa.domain.tld>/owa/","https://<owa.domain.tld>/ecp/")
$ADFSSigningCert = "<Thumbprint>"
$ADFSUrl= "https://<adfs.domain.tld>/adfs/ls/"
#endregion

#region script
Set-OrganizationConfig -AdfsIssuer $ADFSUrl -AdfsAudienceUris $uris -AdfsSignCertificateThumbprint $ADFSSigningCert
Get-EcpVirtualDirectory | Set-EcpVirtualDirectory -AdfsAuthentication $true -BasicAuthentication $false -DigestAuthentication $false -FormsAuthentication $false -WindowsAuthentication $false
Get-OwaVirtualDirectory | Set-OwaVirtualDirectory -AdfsAuthentication $true -BasicAuthentication $false -DigestAuthentication $false -FormsAuthentication $false -WindowsAuthentication $false
#Add ActiveSync
