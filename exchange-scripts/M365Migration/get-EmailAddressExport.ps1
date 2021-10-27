#Variablen definiert
$FormatEnumerationLimit =-1
$datum = Get-Date -Format "ddMMyyyyHHmm"
$foldertosave = "C:\Temp\Claudius\email-addresses-export_$datum.txt"

#Abfrage und export
get-mailbox -ResultSize unlimited | select name, alias, @{Name='EmailAddresses'; Expression={$_.EmailAddresses -join ","}} | export-csv $foldertosave -NoTypeInformation -Delimiter ";" -Encoding "UTF8"
