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
  keiner
.EXAMPLE
  .\Find-Massmails.ps1
#>

#laden der EMS
$ErrorActionPreference = 'SilentlyContinue'
[bool]$emsloaded = $false

if(get-mailbox -ResultSize 1 -WarningAction SilentlyContinue){$emsloaded = $true}
    else{$emsloaded = $false} 

If ($emsloaded) {
                 Write-Host "Exchange Snapin is already loaded...." -ForegroundColor Green
                 }

        else {
              Write-Host "Loading Exchange Snapin. Please Wait...." -ForegroundColor Yellow
              Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
              $emsloadedcheck = Get-PSSnapin | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"}
                
                if ($emsloadedcheck) {
                                       Write-Host "Exchange Snapin was successfully loaded!" -ForegroundColor Green
                                       }
              }

#Zurücksetzten der Errorpreference auf default
$ErrorActionPreference = 'Continue'

#Prüfen des MessageTrackinglogs
#Setzten des Start und des End Datums
$Start = (Get-Date -Hour 00 -Minute 00 -Second 00).AddDays(-29)
$End = (Get-Date -Hour 23 -Minute 59 -Second 59).AddDays(-1)

#Holen aller Exchange Server
$exserver = Get-ExchangeServer | Where-Object {$_.ServerRole -eq "Mailbox"}

#Hauptteil des Skriptes
$messages = @()
$messages = $exserver | ForEach-Object {
                                        #-Source "Agent" -EventID "Agentinfo" sollten dafür sorgen das nur eine Mail im Messagetracking erscheint 
                                        get-messagetrackinglog -server $_ -Start $Start -End $End -Source "Agent" -EventID "Agentinfo" -ResultSize Unlimited | where {$_.Recipients -NotLike "*PublicFolder*" -and $_.RecipientCount -gt "100"}
                                        }

$messages | Select-Object Sender, Recipients, RecipientCount, MessageId, ClientHostName, OriginalClientIp | Out-GridView
$messages | Select-Object Sender, Recipients, RecipientCount, MessageId, ClientHostName, OriginalClientIp | Out-File C:\temp\find-massmail-output.txt
