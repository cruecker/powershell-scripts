## Script will deliver Name, RecipientType, RecipientTypeDetails, MailboxSize, ItemCount in a CSV File
## Script V1.2
## Creation Date 07.06.2021
## Code from Claudius Rücker
## Change Date / Change Log:
## 22.05.2020
## Add logging
## Load EMS

#vorbereiten und starten des Transscriptes
$datum = Get-Date -Format "ddMMyyyyHHmm"

$logname = "Mailboxstats$datum.log"
$path = "D:\temp\claudius\Log"

If(!(test-path $path))
    {
      New-Item -ItemType Directory -Force -Path $path
      Write-Host "Logpfad angelegt unter:" $path
    }
    else {Write-Host "Es wird in" $path "geloggt. Das Log heist $logname" -ForegroundColor Magenta}

Start-Transcript D:\temp\Claudius\Log\$logname


#laden der EMS
$ErrorActionPreference = 'SilentlyContinue'
[bool]$emsloaded = $false
[bool]$emsloadedcheck = $false

if(get-mailbox -ResultSize 1 -WarningAction SilentlyContinue){$emsloaded = $true}
    else{$emsloaded = $false} 

If ($emsloaded) {
                 Write-Host "Exchange Snapin is already loaded...." -ForegroundColor Green
                 }

        else {
              Write-Host "Loading Exchange Snapin. Please Wait...." -ForegroundColor Yellow
              $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<Servername>/PowerShell/ -Authentication Kerberos
              Import-PSSession $Session -DisableNameChecking

              $emsloadedcheck = if(get-mailbox -ResultSize 1 -WarningAction SilentlyContinue){$emsloadedcheck = $true}
                                else{$emsloadedcheck = $false} 
                
                if ($emsloadedcheck -eq $true) {
                                       Write-Host "Exchange Snapin was successfully loaded!" -ForegroundColor Green
                                       }
                    else {
                          Write-Host "Exchange Snapin was not loaded!" -ForegroundColor Red
                          Stop
                          }
              }

#Zurücksetzten der Errorpreference auf default
$ErrorActionPreference = 'Continue'
$ErrorActionPreference


Get-Mailbox -resultsize unlimited | Select-Object name,RecipientType,RecipientTypeDetails,@{n="Primary Size";e={(Get-MailboxStatistics $_.identity).totalItemsize}},@{n="Primary Item Count";e={(Get-MailboxStatistics $_.identity).ItemCount}} | export-csv -NoTypeInformation -Delimiter "," -Path D:\Temp\Claudius\Mailboxstats.txt

#Stop Logging
Stop-Transcript
