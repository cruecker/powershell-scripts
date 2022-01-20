#Falls das Modul MSOnline noch nicht installiert ist muss dieses zuerst installiert werden. Dann bitte die zweite Zeile aktiv schalten
#Find-Module -Name 'Msonline' | Install-Module
#region Module laden und verbinden ins O365
Import-Module MSOnline
Connect-MsolService
#Endregion

#region variablen setzen
$User = '<upn des benutzers>'
$MFASetting = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement -Property @{
    RelyingParty = "*"
    State        = "Enabled"
}
#endregion

#region start script
#MFA aktivieren
Set-MsolUser -UserPrincipalName $User -StrongAuthenticationRequirements $MFASetting

#prüfen ob MFA aktiviert wurde
$ThisUser = Get-msoluser -UserPrincipalName $User | Select-Object -ExpandProperty StrongAuthenticationRequirements
$ThisUser.State
#endregion
