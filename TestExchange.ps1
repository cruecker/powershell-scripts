#######################################
#Exchange Server Test Script
#Test all functions of an Exchange Server
#V1.5 by Claudius Rücker
#Date 27.10.2020
#Last Modified 01.12.2020
#last added:
#checkand create path for logfile if needed
#check if EMS is loaded
#check if run on an exchange server
#add multiple DAG support
#add run as admin check (powershell v4 needed)
#add MailboxDatabaseCopyStatus
#Execute .\TestExchange.ps1 if the certifcate is from a public CA else run .\TestExchange.ps1 -$trustcert:$true
#######################################

[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $trustcert
) 

#Requires -RunAsAdministrator

#clean screen
clear-host

#Logpath check
$path = "C:\temp\"
If(!(test-path $path))
    {
      New-Item -ItemType Directory -Force -Path $path
      Write-Host "Logpfad angelegt unter:" $path
    }
    else {Write-Host "Es wird in" $path "geloggt. Das Log heisst TestExFunctions.log" -ForegroundColor Magenta}

#Start Logging
Start-Transcript C:\temp\TestExFunctions.log

#Check if EMS is loaded
try {Get-ExchangeServer | Out-Null}
        Catch [System.Management.Automation.CommandNotFoundException] {
	              Write-Warning "This script must be run in the Exchange Management Shell"
                  Stop-Transcript
                  break
                  }

#check if script runs on an Exchange Server
$servers = Get-ExchangeServer
$srvcheck = $servers | where {$_.name -eq $env:COMPUTERNAME}

if (!$srvcheck) {Write-Warning "This script must run on an Exchange Server"
                #Stop-Transcript
                break
                }

#get clusternode status
$stateofnode = (Get-ClusterNode $env:COMPUTERNAME).State
if ($stateofnode -eq "Paused") {Write-Host "Cluster node is in Maintenance! Script will stop now." -ForegroundColor Red
                                Stop-Transcript
                                break
                                }

# Set Variables
$vdirews = (Get-WebServicesVirtualDirectory -Server $env:computername).InternalUrl
$servername = get-exchangeserver $env:computername
$adSiteGuidLeft13 = $servername.Site.ObjectGuid.ToString().Replace("-","").Substring(0, 13)
$UserName = "extest_" + $adSiteGuidLeft13;
$DAGServer = (Get-DatabaseAvailabilityGroup | where {$_.Servers -like "*$env:COMPUTERNAME"}).Name
$ExVersion = (Get-ExchangeServer -Identity $env:COMPUTERNAME).admindisplayversion.minor

#move testuser to a database on server which shhould be tested
#check if user is homed on the server where the script runs
#if not move the user here

$alldbs = Get-MailboxDatabaseCopyStatus | where {$_.Name -like "*$servername*" -and $_.Status -eq "Mounted"}
$userhome = (get-mailbox $UserName).Database
$userlocation = ($alldbs | where {$_.Databasename -eq "$userhome"}).MailboxServer

try {if ($userlocation -eq $env:computername) {Write-Host "`n"$username "homed on" $env:computername -ForegroundColor Green}
        else {write-host "The Testuser is not homed here but must be homed on this server!" -ForegroundColor yellow
             write-host "The Testuser will now be moved to this server:" $env:computername -ForegroundColor yellow
             New-MoveRequest $UserName -TargetDatabase ($alldbs[0]).DatabaseName | Out-Host
             while((Get-MoveRequest $username).status -notlike "Completed") {write-host "Still moveing the user:" $username; sleep -Seconds 60}
             Remove-MoveRequest $UserName -Confirm:$false
             write-host "Wait now for 60 seconds to complete the cleanup" -ForegroundColor Magenta
             sleep -Seconds 120
        }
    }
    catch [System.Management.Automation.RuntimeException] {Write-host "No active Database on the server found! Please redistribute Databases" -ForegroundColor Red
                                                            Stop-Transcript
                                                            break
                                                            }

##### Start Tests

#Show Message Queue
$mqueue = @()
$mqueue = Get-ExchangeServer $env:computername | Get-Queue | where {$_.MessageCount -gt 0 -and $_.Identity -notlike "*shadow*"}
if (!$mqueue) {Write-Host "`nMessagequeue ok. No mails in the Queue!" -ForegroundColor Green}
   else {Write-host "`nMessagequeue is not ok!" -ForegroundColor Red
         $mqueue | Out-Host
}

#get healthreport
$HealthReport = $null
$HealthReport = Get-HealthReport -Server $env:computername | where { $_.alertvalue -ne "Healthy" }
if (!$HealthReport) {Write-Host "`nGet-HealthReport ok. All Healthsets are ok!" -ForegroundColor Green}
   else {Write-host "`nGet-HealthReport is not ok!" -ForegroundColor Red
         $HealthReport | Out-Host}

#test ReplicationHealth
$ReplicationHealth = $null
$ReplicationHealth = Test-ReplicationHealth -DatabaseAvailabilityGroup $DAGServer | Where {$_.Result.Value -ne "Passed"}
if (!$ReplicationHealth) {Write-Host "`nTest-ReplicationHealth ok. All DB replications are ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-ReplicationHealth not ok!" -ForegroundColor Red
           $ReplicationHealth | Out-Host}

#test service health
$Servicehealth = $null
$Servicehealth = Test-ServiceHealth $env:computername | where {$_.RequiredServicesRunning -eq $false}
if (!$Servicehealth) {Write-Host "`nTest-ServiceHealth ok. Needed Services up and running!" -ForegroundColor Green}
   else {Write-Host "`nTest-ServiceHealth not ok!" -ForegroundColor Red
           $Servicehealth | Out-Host}
 
#test Mailflow funktioniert nur wenn DB's gemountet und aktive auf dem Server sind. testet den lokaen server
$mailflow = $null
$mailflow = Test-Mailflow | where {$_.TestMailflowResult -notlike "Success"}
if (!$mailflow) {Write-Host "`nTest-mailflow ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-MAPIConnectivity not ok!" -ForegroundColor red
           $mailflow | Out-Host}

#test MAPIConnectivity
$MAPIConnectivity = $null
$MAPIConnectivity = Test-MAPIConnectivity | where {$_.Result -notlike "Success"}
if (!$MAPIConnectivity) {Write-Host "`nTest-MAPIConnectivity ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-MAPIConnectivity not ok!" -ForegroundColor red
           $MAPIConnectivity | Out-Host}

 

#Test ImapConnectivity
$ImapConnectivity = $null
$ImapConnectivity = Test-ImapConnectivity | where {$_.Result -notlike "Success"}
if (!$ImapConnectivity) {Write-Host "`nTest-ImapConnectivity ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-ImapConnectivity not ok!" -ForegroundColor red
           $ImapConnectivity | Out-Host}

#Test PopConnectivity
$popConnectivity = $null
$popConnectivity = Test-ImapConnectivity | where {$_.Result -notlike "Success"}
if (!$popConnectivity) {Write-Host "`nTest-PopConnectivity ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-PopConnectivity not ok!" -ForegroundColor red
           $popConnectivity | Out-Host}

#test SmtpConnectivity
$SmtpConnectivity = $null
$SmtpConnectivity = Test-SmtpConnectivity | where {$_.StatusCode -notlike "Success"}
if (!$SmtpConnectivity) {Write-Host "`nTest-SmtpConnectivity ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-SmtpConnectivity not ok!" -ForegroundColor red
           $SmtpConnectivity | Out-Host}

#test WebServicesConnectivity
$WebServicesConnectivity = $null
$WebServicesConnectivity = Test-WebServicesConnectivity | where {$_.Result -notlike "Success"}
if (!$WebServicesConnectivity) {Write-Host "`nTest-WebServicesConnectivity ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-WebServicesConnectivity not ok!" -ForegroundColor red
           $WebServicesConnectivity | Out-Host}

#test ActiveSyncConnectivity
$ActiveSyncConnectivity = $null
$ActiveSyncConnectivity = Test-ActiveSyncConnectivity -TrustAnySSLCertificate:$trustcert | where {$_.Result -notlike "Success"}
if (!$ActiveSyncConnectivity) {Write-Host "`nTest-ActiveSyncConnectivity ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-ActiveSyncConnectivity not ok!" -ForegroundColor red
           $ActiveSyncConnectivity | Out-Host}

#test OutlookWebServices
$OutlookWebServices = $null
$OutlookWebServices = Test-OutlookWebServices | where {$_.Result -notlike "Success"}
if (!$OutlookWebServices) {Write-Host "`nTest-OutlookWebServices ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-OutlookWebServices not ok!" -ForegroundColor red
           $OutlookWebServices | Out-Host}

#Test MRS Health
$MRSHealth = $null
$MRSHealth = Test-MRSHealth | where {$_.Passed -notlike "True"}
if (!$MRSHealth) {Write-Host "`nTest-MRS Health ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-MRS Health not ok!" -ForegroundColor red
           $MRSHealth | Out-Host}
           
#Test PowerShellConnectivity
$PowerShellConnectivity = $null
$PowerShellConnectivity = Test-PowerShellConnectivity | where {$_.Result -notlike "Success"}
if (!$PowerShellConnectivity) {Write-Host "`nTest-PowerShellConnectivity ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-PowerShellConnectivity not ok!" -ForegroundColor red
           $PowerShellConnectivity | Out-Host}

#Test OAuth
$OAuthConnectivity = $null
$OAuthConnectivity = Test-OAuthConnectivity -Service ews -TargetUri $vdirews -Mailbox $UserName | where {$_.ResultType -notlike "Success"}
if (!$OAuthConnectivity) {Write-Host "`nTest-OAuthConnectivity against EWS ok!" -ForegroundColor Green}
   else {Write-Host "`nTest-OAuthConnectivity against EWS not ok!" -ForegroundColor red
           $OAuthConnectivity | Out-Host}

#Checking Mailbox Database Copy Status of Exchange Server
[bool]$AllOk = $true
$DBOutput = @()
$DBCopy = Get-MailboxDatabaseCopyStatus -Server $env:COMPUTERNAME
if ($ExVersion -lt "2") {
            ForEach ($DB in $DBCopy){
            
                if ($DB.Status -ne "Mounted" -and $DB.Status -ne "Healthy" -and $DB.ContentIndexState -ne "Healthy")
                           {
                               $DBOutput += $DB
                               $AllOk=$false
                           } 

                            else {
                               $DBOutput += $DB
                                    }
                        }
                      }
    else {ForEach ($DB in $DBCopy){
    
                    if ($DB.Status -ne "Mounted" -and $DB.Status -ne "Healthy")
                           {
                               $DBOutput += $DB
                               $AllOk = $false
                           } 

                            else {
                               $DBOutput += $DB
                                    }
                        }
         }

If ($AllOk -eq $false){
    Write-Host "`nTest-Mailbox Database Copy Status failed:" -ForegroundColor Red
    $DBOutput | Select Name, Status, CopyQueueLength, ReplayQueueLength, LastInspectedLogTime, ContentIndexState | Ft
                        } 
    Else {
    Write-Host "`nTest-Mailbox Database Copy Status ok!" -ForegroundColor Green
            }


Stop-Transcript
