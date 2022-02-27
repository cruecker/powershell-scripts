#hole die vorhandenen Azure AD Default Domain
Get-AzureADDomain | select name, isdefault

#hinzufügen einer domain zum azure AD
New-AzureADDomain -Name shellup.ch

#Auslesen des TXT Records zur Domain Validierung
Get-AzureADDomainVerificationDnsRecord -name shellup.ch | where {$_.recordtype -eq "txt"} | select text

#Den TXT Einrtag im DNS des Providers hinzufügen

#Validierung des DNS Eintrags im Azure AD
Confirm-AzureADDomain -Name shellup.ch

#setzten der default domain
Set-AzureADDomain -name shellup.ch -IsDefault $true

#Prüfen ob die Domain default und validiert ist
Get-AzureADDomain -name shellup.ch | fl
