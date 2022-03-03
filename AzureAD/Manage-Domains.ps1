#definieren der Funktionen
function Show-CustomMenu
{
    param (
        [string]$menuname
    )
    Clear-Host
    Write-Host "================ $menuname ================"
    
    Write-Host "1: Wähle '1' um die aktuellen Domains anzuzeigen"
    Write-Host "2: Wähle '2' um die Domains hinzuzufügen und den TXT Record zu erhalten"
    Write-Host "3: Wähle '3' um die Domains zu valdieren"
    Write-Host "4: Wähle '4' um die Domains zu entfernen"
    Write-Host "Q: Wähle 'Q' um das Programm zu beenden."
    Write-Host ""
}

#Hinzufügen der Domain zum Tenant
function AddDomain {
                   $domains | ForEach-Object {New-AzureADDomain -Name $_}
                   }

function GetDomainDNSRecord {
                            $domains | ForEach-Object {Get-AzureADDomainVerificationDnsRecord -name $_ | where {$_.recordtype -eq "txt"} | select label, text}
                            }
function ConfrimDomain {
                        $domains | ForEach-Object {Confirm-AzureADDomain -Name $_}
                        }
                            
function RemoveDomain {
                   $domains | ForEach-Object {remove-AzureADDomain -Name $_}
                   }

#Laden der Domains
$domains = Get-Content -Path C:\Temp\scripts\domains.txt
#$domains

#Verbinden mit Azure
Connect-AzureAD

# Menue aufrufen und Titel uebergeben
Show-CustomMenu –menuname 'Azure Domain Menue'

# Eingabe /Auswahl des Benutzers
$auswahl = Read-Host "Bitte die gewünschte Option wählen"

# Optionen wählen
switch ($auswahl){
     '1' {Get-AzureADDomain | select name, isdefault}

     '2' {AddDomain $domains; GetDomainDNSRecord}

     '3' {ConfrimDomain $domains}

     '4' {RemoveDomain $domains}
     
     'q' {exit}

 }
