<#
.SYNOPSIS
  Durchsuchen aller Exchange Server Trackinglogs nach Massenemails
.DESCRIPTION
  Durchsuchen aller Exchange Server Trackinglogs nach Massenemails.
.PARAMETER
 keine
.INPUTS
  keine
.OUTPUTS
  im Gridview und auf der Disk unter C:\temp\find-massmail-output.txt
.NOTES
  Version:        1.0
  Author:         Claudius Rücker
  Creation Date:  01.06.2021
.last change
  Change Exchange Connect
  Add Logging
  Add measureing
.EXAMPLE
  .\Find-Massmails.ps1
#>

#vorbereiten und starten des Transscriptes
$datum = Get-Date -Format "ddMMyyyyHHmm"
$start = Get-Date

$logname = "MassMails$datum.log"
$path = "D:\temp\claudius\Log"
$outfile = "D:\temp\claudius\find-massmail-output-$datum.txt"

If(!(test-path $path))
    {
      New-Item -ItemType Directory -Force -Path $path
      Write-Host "Logpfad angelegt unter:" $path
    }
    else {Write-Host "Es wird in" $path "geloggt. Das Log heist $logname" -ForegroundColor Magenta}

Start-Transcript D:\temp\Claudius\Log\$logname

#laden der EMS
$ErrorActionPreference = 'SilentlyContinue'
Write-Host "Setzen der ErrorActionPreference auf Leise: " $ErrorActionPreference -ForegroundColor Magenta

[bool]$emsloaded = $false
[bool]$emsloadedcheck = $false

if(get-mailbox -ResultSize 1 -WarningAction SilentlyContinue){$emsloaded = $true}
    else{$emsloaded = $false} 

If ($emsloaded) {
                 Write-Host "Exchange Snapin is already loaded...." -ForegroundColor Green
                 }

        else {
              Write-Host "Loading Exchange Snapin. Please Wait...." -ForegroundColor Yellow
              $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<servername>/PowerShell/ -Authentication Kerberos
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
Write-Host "Setzen der ErrorActionPreference auf Standard: " $ErrorActionPreference -ForegroundColor Magenta


#Prüfen des MessageTrackinglogs
#Setzten des Start und des End Datums
$Start = (Get-Date -Hour 00 -Minute 00 -Second 00).AddDays(-29)
$End = (Get-Date -Hour 23 -Minute 59 -Second 59).AddDays(-1)

#Holen aller Exchange Server
$exserver = Get-ExchangeServer | Where-Object {$_.ServerRole -eq "Mailbox"}

#Hauptteil des Skriptes
$messages = @()
$messages = $exserver.Name | ForEach-Object {
                                        #-Source "Agent" -EventID "Agentinfo" sollten dafür sorgen das nur eine Mail im Messagetracking erscheint 
                                        get-messagetrackinglog -server $_ -Start $Start -End $End -Source "Agent" -EventID "Agentinfo" -ResultSize Unlimited | where {$_.Recipients -NotLike "*PublicFolder*" -and $_.RecipientCount -gt "100"}
                                        }

$messages | Select-Object Sender, Recipients, RecipientCount, MessageId, ClientHostName, OriginalClientIp | Out-GridView
$messages | Select-Object Sender, Recipients, RecipientCount, MessageId, ClientHostName, OriginalClientIp | export-csv -NoTypeInformation -Encoding UTF8 -Delimiter "," -Path  $outfile

$end = Get-Date
($end-$start).TotalHours

#Stop Logging
Stop-Transcript
