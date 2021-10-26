#Variablen definiert
$FormatEnumerationLimit =-1
$datum = Get-Date -Format "ddMMyyyyHHmm"
$foldertosave = "C:\Temp\Claudius\email-addresses_$datum.txt"

#Abfrage
get-mailbox -ResultSize unlimited | ft name, alias, emailaddresses -wrap | out-file $foldertosave
