Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010

#Variablen
#mailversand
$From = "$env:COMPUTERNAME@<domain.tld>"
$To = "<empfaenger@domain.tld>"
$Subject = "Free Diskspace Report Exchange Server"
$SMTPServer = "$env:COMPUTERNAME"
$htmlhead = "<html>
				<style>
				BODY{font-family: Arial; font-size: 8pt;}
				H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
				TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
				TD{border: 1px solid #969595; padding: 5px; }
				td.pass{background: #B7EB83;}
				td.warn{background: #FFF275;}
				td.fail{background: #FF2626; color: #ffffff;}
				td.info{background: #85D4FF;}
				</style>
				<body>
                <H1>Free Diskspace Report Exchange Server</H1>
                <H2 style='color:red;'>Please check that the Free Diskspace is lager than 500 GB</H2>"
$htmltail = "</body></html>"

$servers = Get-ExchangeServer | Sort-Object

$allvolumes = @()
foreach ($server in $servers) {
                               $allvolumes += Invoke-Command -ComputerName $server -ScriptBlock {Get-Volume | where {$_.FileSystemLabel -like "<label der Disks>" }}
                                }
$allvolumes | select PSComputerName, FilesystemLabel, @{Name="Size (GB)";Expression={[math]::round($_.size/1GB, 2)}}, @{Name="Free Diskspce (GB)";Expression={[math]::round($_.SizeRemaining/1GB, 2)}}

#Byte to TB rechnen
$allvolumes = $allvolumes | select PSComputerName, FilesystemLabel, @{Name="Size (GB)";Expression={[math]::round($_.size/1GB, 2)}}, @{Name="Free Diskspce (GB)";Expression={[math]::round($_.SizeRemaining/1GB, 2)}} | ConvertTo-Html -Fragment

$body = $htmlhead + $allvolumes + $htmltail

Send-MailMessage -From $From -to $To -Subject $Subject -Body $body -BodyAsHtml -SmtpServer $SMTPServer
