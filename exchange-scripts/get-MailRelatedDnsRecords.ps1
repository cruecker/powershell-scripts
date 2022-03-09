$domains = Get-Content -Path C:\Temp\scripts\domains.txt
#$domains.Count

############Abfrage der MX Records aus dem DNS
Write-host "Start MX Lookup" -ForegroundColor Magenta

$MxEntrys = $domains | resolve-dnsname -Type MX -Server 8.8.8.8 | where {$_.QueryType -eq "MX"} | Select Name, NameExchange, Preference, TTL | Sort Name


if ($domains.Count -gt $MxEntrys.Count) {Write-host "Domain lost!" -ForegroundColor Yellow
                                        Compare-Object $domains $MxEntrys.Name | Where-Object { $_.SideIndicator -eq '<=' } | Foreach-Object { $_.InputObject }
                                        }

write-host "`nFollowing MX Entrys Found:" -ForegroundColor Green
$MxEntrys | Out-Host


############Abfrage der A Records aus dem MX
Write-host "Start A Record from MX Lookup" -ForegroundColor Magenta

$ARecords = $MxEntrys.NameExchange  | resolve-dnsname -Type A -Server 8.8.8.8 | Select Name, IPAddress, TTL | Sort Name

if ($MxEntrys.Count -gt $ARecords.Count) {Write-host "Domain lost!" -ForegroundColor Yellow
                                        Compare-Object $MxEntrys.NameExchange $ARecords.Name | Where-Object { $_.SideIndicator -eq '<=' } | Foreach-Object { $_.InputObject }
                                        }

$ARecords | Out-Host


############Abfrage der TXT Records mit SPF aus dem DNS
Write-host "Start SPF Lookup" -ForegroundColor Magenta

$spfrecords = $domains | resolve-dnsname -Type TXT -Server 8.8.8.8 | where {$_.Strings -like "v=spf*"} | Select Name, Strings, TTL | Sort Name

if ($domains.Count -gt $spfrecords.Count) {Write-host "Domain lost!" -ForegroundColor Yellow
                                           Compare-Object $domains $spfrecords.Name | Where-Object { $_.SideIndicator -eq '<=' } | Foreach-Object { $_.InputObject }
                                          }

write-host "`nFollowing SPF Entrys Found:" -ForegroundColor Green
$spfrecords | Out-Host


############Abfrage der Autodiscover A-Record aus dem DNS
$ErrorActionPreference = "Stop"
Write-host "`nStart Autodiscover A-Record Lookup" -ForegroundColor Magenta
$autoddomains = $domains | foreach {"autodiscover.$_"}
$autodrecords = foreach ($autoddomain in $autoddomains) {
                                                        try {
                                                             resolve-dnsname -name $autoddomain -Type A -Server 8.8.8.8 | Select Name, IP4Address, TTL, QueryType | Sort Name
                                                             }
                                                        catch [System.ComponentModel.Win32Exception] {Write-Host "`nDer DNS-Name $autoddomain ist nicht vorhanden" -ForegroundColor Yellow}
                                                         }

$autodrecords | Out-Host

############Abfrage der Autodiscover SRV-Record aus dem DNS
Write-host "`nStart Autodiscover SRV Lookup" -ForegroundColor Magenta
$autodSRVdomains = $domains | foreach {"_autodiscover._tcp.$_"}
$AutoDSRVRecords = foreach ($autodSRVdomain in $autodSRVdomains) {
                                                        try {
                                                             resolve-dnsname -name $autodSRVdomain -Type SRV -Server 8.8.8.8 | Select Name, IP4Address, TTL, QueryType | Sort Name
                                                             }
                                                        catch [System.ComponentModel.Win32Exception] {Write-Host "`nDer DNS-SRV Eintrag $autodSRVdomain ist nicht vorhanden" -ForegroundColor Yellow}
                                                         }
$AutoDSRVRecords | Out-Host

############Abfrage der Autodiscover CNAME-Record aus dem DNS
Write-host "`nStart Autodiscover CNAME Lookup" -ForegroundColor Magenta
$AutoDCNAMERecords = foreach ($autoddomain in $autoddomains) {
                                                        try {
                                                             resolve-dnsname -name $autoddomain -Type CNAME -Server 8.8.8.8 | Select Name, NameHost, TTL, QueryType | Sort Name
                                                             }
                                                        catch [System.ComponentModel.Win32Exception] {Write-Host "`nDer DNS-CNAME Eintrag $autoddomain ist nicht vorhanden" -ForegroundColor Yellow}
                                                         }

$AutoDCNAMERecords | Out-Host
