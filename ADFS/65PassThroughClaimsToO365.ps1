#region variablen
$AnspruchsRegel=@'
@RuleName = "Issue UPN"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname"]
=> issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/claims/UPN"), query = "samAccountName={0};userPrincipalName;{1}", param = regexreplace(c.Value, "(?<domain>[^\]+)\(?<user>.+)", "${user}"), param = c.Value);

@RuleName = "Issue Immutable ID"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname"]
=> issue(store = "Active Directory", types = ("http://schemas.microsoft.com/LiveID/Federation/2008/05/ImmutableID"), query = "samAccountName={0};objectGUID;{1}", param = regexreplace(c.Value, "(?<domain>[^\]+)\(?<user>.+)", "${user}"), param = c.Value);

@RuleName = "Pass through claim - authnmethodsreferences"
c:[Type == "http://schemas.microsoft.com/claims/authnmethodsreferences"]
=> issue(claim = c);
'@
#endregion

Get-ADFSRelyingPartyTrust -Name "Microsoft Office 365 Identity Platform"| Set-ADFSRelyingPartyTrust -IssuanceTransformRules $AnspruchsRegel
