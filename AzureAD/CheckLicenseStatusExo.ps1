#https://graph.microsoft.com/v1.0/me/mailboxSettings/userPurpose
#lizenzen = 'EXCHANGE_S_DESKLESS' oder 'EXCHANGE_S_ENTERPRISE'

#Connect zum Azure AD
Connect-MgGraph -ClientID <ID hier> -TenantId <ID hier> -CertificateThumbprint <Thumbprint hier>

#finde alle AAD User mit einer E-Mail Adresse 
$Users = Get-MgUser -all -Filter "userType eq 'member'" | Where-Object {$_.Mail -like "*@*"}

#Finde alle Exchange Usermailboxen
$usersWithBoxes = Foreach ($User in $Users) {
Get-MgUser -UserId $User.UserPrincipalName -Property UserPrincipalName,MailboxSettings | Select-Object UserPrincipalName, @{Name = 'userPurpose'; Expression = {$_.MailboxSettings.userPurpose}} | Where-Object {$_.userPurpose -eq "user"}
}
$usersWithBoxes.Count

#finde alle User ohne Lizenz
$lizensierteUsers = @()
foreach ($box in $usersWithBoxes) {
    $lizenz = Get-MgUserLicenseDetail -UserId $box.UserPrincipalName #| Where-Object {$_.ServicePlans.ServicePlanName -eq "EXCHANGE_S_ENTERPRISE" -or $_.ServicePlans.ServicePlanName -eq "EXCHANGE_S_DESKLESS"}
    $lizensierteUsers +=[pscustomobject]@{
        UPN = $box.UserPrincipalName
        Lizenz = $lizenz.ServicePlans.ServicePlanName.Where{$_ -eq 'EXCHANGE_S_ENTERPRISE' -or $_ -eq "EXCHANGE_S_DESKLESS"}
        }
}
$lizensierteUsers.Count

$UsersOhneLiz = ForEach ($luser in $lizensierteUsers) {
    if ($luser.Lizenz.count -eq 0) {
        Write-Host "User:" $luser.upn "besizt keine Lizenz" -ForegroundColor Magenta
        $luser.UPN
    }

}

$UsersOhneLiz
if ($UsersOhneLiz.count -eq 0) {
    $UsersOhneLiz = "Keine User gefunden. Es gibt nichts zu tun"
}


Disconnect-MgGraph
