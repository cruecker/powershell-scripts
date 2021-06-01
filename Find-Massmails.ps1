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

#Zurücksetzten der Errorpreference
$ErrorActionPreference = 'Continue'

#Prüfen des MessageTrackinglogs
#Setzten des Start und des End Datums von Gestern
$Start = (Get-Date -Hour 00 -Minute 00 -Second 00).AddDays(-1)
$End = (Get-Date -Hour 23 -Minute 59 -Second 59).AddDays(-1)

#Holen aller Exchange Server
$exserver = Get-ExchangeServer | Where-Object {$_.ServerRole -eq "Mailbox"}
#$exserver

#-Source "Agent" -EventID "Agentinfo" sollten dafür sorgen das nur eine Mail im Messagetracking erscheint
$messages = $exserver | ForEach-Object {get-messagetrackinglog -server $_ -Start $Start -End $End -Source "Agent" -EventID "Agentinfo" -ResultSize Unlimited | where {$_.Recipients -NotLike "*PublicFolder*" -and $_.RecipientCount -gt "100"}} 

<#Nachrichten sortieren und einzigartig machen
($messagessend).Count
#$sortmessagesend =  $messagessend | Sort-Object -Property messageid

#$uniquemessagesend = Get-Unique -InputObject $sortmessagesend
#($uniquemessagesend).count
#>

$messages | Select-Object Sender, Recipients, RecipientCount, MessageId, ClientHostName, ClientHostName, OriginalClientIp | Out-GridView

