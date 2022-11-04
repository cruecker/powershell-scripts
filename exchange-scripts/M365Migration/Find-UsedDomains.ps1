#This Skript exports all on premise used Domains to a csv
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Snapin
$boxes = Get-Mailbox -ResultSize unlimited | select Displayname, Alias, PrimarySmtpAddress, @{Name="EmailAddresses";Expression={($_.EmailAddresses | Where-Object {$_ -clike "smtp*"})}}

function get-proxydomain($praddresses){
                                       $value = @()
                                       foreach ($pra in $praddresses.EmailAddresses) {
                                                                                     $value += $pra.ToString().Split('@')[1]
                                                                                     }
                                       return $value
                                        }

$result = @()
$result = foreach ($box in $boxes) {
                                    #$box
                                    [pscustomobject] @{
                                                        DisplayName = $box.DisplayName
                                                        Alias = $box.Alias
                                                        PrimarySmtpAddress = $box.PrimarySmtpAddress
                                                        Domain = $box.PrimarySmtpAddress.Address.Split('@')[1]
                                                        AdditionalDomain = (@(get-proxydomain $box) -join ",")
                                                        }
                                  }

#$result
$result | Export-Csv D:\temp\Claudius\PowershellScripts\Find-UsedDomains\Output-Domains.txt -NoTypeInformation -Encoding UTF8
