<#
.SYNOPSIS
  Windows Server Security Log Script
.DESCRIPTION
  Find all users who haved loged on this server in the last 7 days
.PARAMETER $trustcert
    none
.INPUTS
  none
.OUTPUTS
  direct on screen
.NOTES
  Version:        1.0
  Author:         Claudius Rücker
  Creation Date:  16.02.2021
  Purpose/Change: none
  
.EXAMPLE
  .\get-last7dayslogon.ps1
#>

$logs = get-eventlog system -ComputerName $env:COMPUTERNAME -source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-7)
$res = @()

ForEach ($log in $logs) {
                        if($log.instanceid -eq 7001) {$type = "Logon"} 
                            Elseif ($log.instanceid -eq 7002){$type="Logoff"} 
                                Else {Continue} 
                                $res += New-Object PSObject -Property @{
                                                                        Time = $log.TimeWritten
                                                                        Event = $type 
                                                                        User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
                                                                        }
                        }

$res
