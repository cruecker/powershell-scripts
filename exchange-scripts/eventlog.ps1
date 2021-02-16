<#
.SYNOPSIS
  Exchange Server Eventlog Script
.DESCRIPTION
  Find all Exchange Server and greps the eventlog and show the output in a html file
.PARAMETER $trustcert
    none
.INPUTS
  none
.OUTPUTS
  Log file stored in the foler from where you run the script
.NOTES
  Version:        1.0
  Author:         Claudius Rücker
  Creation Date:  16.02.2021
  Purpose/Change: none
  
.EXAMPLE
  .\eventlog.ps1
#>

### 
#hole die Exchange Server
$exservers = @()
$exservers = Get-ADGroup -Identity "Exchange Servers" |Get-ADGroupMember
$exservertoconect = $exservers[0].name

#load EMS
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exservertoconect/PowerShell/ -Authentication Kerberos
Import-PSSession $Session -DisableNameChecking


$time = (Get-Date) - (New-TimeSpan -Day 1)
$Ergebnisse = @()
$serverliste = get-exchangeserver


$serverliste | foreach {
                        Invoke-Command -ComputerName $_ -Command {Get-WinEvent –FilterHashtable @{logname='application'; Level=1; starttime=$using:time}} -AsJob
                        Invoke-Command -ComputerName $_ -Command {Get-WinEvent –FilterHashtable @{logname='application'; Level=2; starttime=$using:time}} -AsJob
                        Invoke-Command -ComputerName $_ -Command {Get-WinEvent –FilterHashtable @{logname='application'; Level=3; starttime=$using:time}} -AsJob
                        Invoke-Command -ComputerName $_ -Command {Get-WinEvent –FilterHashtable @{logname='system'; Level=1; starttime=$using:time}} -AsJob
                        Invoke-Command -ComputerName $_ -Command {Get-WinEvent –FilterHashtable @{logname='system'; Level=2; starttime=$using:time}} -AsJob
                        Invoke-Command -ComputerName $_ -Command {Get-WinEvent –FilterHashtable @{logname='system'; Level=3; starttime=$using:time}} -AsJob
                        }

#auf Abarbeitung des Jobs warten
Get-Job | Wait-Job

Get-Job | ForEach-Object {Try
                          {$Ergebnisse += Receive-Job -Job $_ -ErrorAction:Stop }
                          
                          catch [System.Management.Automation.RemoteException] {
                                                                                write-host "On server:" $Error[0].OriginInfo.PSComputerName $Error[0].Exception.Message -ForegroundColor yellow                                                                               }
                                                                                }

#Jobs entfernen
get-job | remove-job

#Fehler aufbereiten und Gruppieren
$fehler = $ergebnisse | select PSComputerName, TimeCreated, LevelDisplayName, LogName, Id, ProviderName, Message 
$fehlerAnzahl = ($fehler).count
$GruppierteFehler = $fehler | Group-Object -Property ID, PSComputername

#Fehler Zusammenfassen
$outputfehler = @()
foreach ($Gfehler in $GruppierteFehler) {
                                            $outputfehler += [PSCustomObject]@{
                                                'Anzahl' = $Gfehler.Count
                                                'ComputerName' = $GFehler[0].Group[0].PSComputerName
                                                'Time' = $GFehler[0].Group[0].TimeCreated
                                                'Name' = $GFehler[0].Group[0].LevelDisplayName
                                                'Log' = $GFehler[0].Group[0].LogName
                                                'ID' = $GFehler[0].Group[0].ID
                                                'Message' = $GFehler[0].Group[0].Message
                                                }
                                        }
$outputfehler | ft

$precontent = “List of Errrors on Exchange Eventlog”
$htmlParams = @{
  Body = Get-Date
  PreContent = $precontent
  PostContent = "Es wurden seit dem " + "$time " + "$fehlerAnzahl " + "Fehler auf den Exchange Servern gefunden"
  Head = “<title>Applog Errors</title><style>table, th, td {border: 1px solid;}</style >”
}

$outputfehler | select |ConvertTo-Html @htmlParams | Out-File Eventlog.htm
Invoke-Item Eventlog.htm
