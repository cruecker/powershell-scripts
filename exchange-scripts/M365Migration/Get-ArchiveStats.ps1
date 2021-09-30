#Messen der Grösse der Archive und Itemanzahl und export in eine CSV
$datum = Get-Date -Format "ddMMyyyyHHmm"
Get-Mailbox -resultsize unlimited -Archive | Select-Object name,RecipientTypeDetails,@{n="Primary Size";e={(Get-MailboxStatistics $_.identity -Archive).totalItemsize}},@{n="Primary Item Count";e={(Get-MailboxStatistics $_.identity -Archive).ItemCount}} | export-csv -NoTypeInformation -Encoding UTF8 -Delimiter "," -Path C:\Temp\Archivstats$Datum.txt
