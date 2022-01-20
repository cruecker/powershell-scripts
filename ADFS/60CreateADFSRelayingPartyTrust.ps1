
#region Variablen
$OWA = "https://<sub.domain.tld>/owa/"
$ECP = "https://<sub.domain.tld>/ecp/"
$EAS = "https://<sub.domain.tld>/Microsoft-Server-ActiveSync/"
$AusstellerRegel=@'
    @RuleTemplate = "AllowAllAuthzRule"

    => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit",
    Value = "true");
'@

$AnspruchsRegel=@'
    @RuleName = "ActiveDirectoryUserSID"
    c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]

    => issue(store = "Active Directory", types = ("http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid"), query = ";objectSID;{0}", param = c.Value); 

    @RuleName = "ActiveDirectoryGroupSID"
    c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] 

    => issue(store = "Active Directory", types = ("http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid"), query = ";tokenGroups(SID);{0}", param = c.Value); 

    @RuleName = "ActiveDirectoryUPN"
    c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] 

    => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"), query = ";userPrincipalName;{0}", param = c.Value);
'@

#endregion
#region Script
Add-ADFSRelyingPartyTrust -Name "Outlook on the Web" -Enabled $true -Notes "Vertrauensstellung für $OWA" -WSFedEndpoint $OWA -Identifier $OWA -IssuanceTransformRules $AnspruchsRegel -IssuanceAuthorizationRules $AusstellerRegel    
Add-ADFSRelyingPartyTrust -Name "Exchange Systemsteuerung" -Enabled $true -Notes "Vertrauensstellung für $ECP" -WSFedEndpoint $ECP -Identifier $ECP -IssuanceTransformRules $AnspruchsRegel -IssuanceAuthorizationRules $AusstellerRegel

#Nur für ADFS Server 2016:
Add-AdfsNonClaimsAwareRelyingPartyTrust -Name "Active Sync" -Notes "Vertrauensstellung fuer EAS" -Identifier $EAS -IssuanceAuthorizationRules '=>issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "true");'

Write-host "ADFS Konfiguration ausgeführt."
