  
<#
.SYNOPSIS
  Exchange Server File Copy Script
.DESCRIPTION
  Find all Exchange Server and copies files to a special folder
.PARAMETER $itemssource, $itemtarget
    Both are madatory
.INPUTS
  none
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Claudius Rücker
  Creation Date:  09.03.2021
  Purpose/Change: none
  Keep in mind the target is a networkpath
  
.EXAMPLE
  .\Copy-Files.ps1 -itemssource "C:\Users\username\Downloads\*" -itemtarget "c$\temp\"
#>


[CmdletBinding()]
param (
    [parameter(Mandatory=$true)]
    [String[]]$itemssource,

    [parameter(Mandatory=$true)]
    [String[]]$itemtarget
    )

#definition der Pfade
#$itemssource = "C:\Users\username\Downloads\*"
#$itemtarget = 'c$\temp\'


#get the Exchange Servers
$servers = @()
$servers = Get-ADGroup -Identity "Exchange Servers" | Get-ADGroupMember | where {$_.name -ne "Exchange Install Domain Servers"}

#Check if source path is exsisting
$testresultsourcefolder = test-path $itemssource

if ($testresultsourcefolder -eq $False) {
                                        Write-host "Quellpfad nicht gefunden. Script endet hier!" -ForegroundColor Red
                                        exit
                                        }

#copy items
foreach ($server in $servers.name) {
                                    $testresulttargetfolder = test-path $itemssource
                                    if ($testresulttargetfolder -eq $False) {
                                        Write-host "Zielpfad nicht gefunden auf" $server -ForegroundColor Red
                                        }
                                    else {Copy-Item -Path $itemssource -Destination "\\$server\$itemtarget" -Recurse -Confirm}
                                    }
