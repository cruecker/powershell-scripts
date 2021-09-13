[System.Collections.ArrayList]$datei = import-csv "<path to CSV>" -Delimiter ";" -Header "Name","RecipientType","RecipientTypeDetails","PrimarySize","PrimaryItemCount"
$datei.Removeat(0)
#$datei.primarysize[0]

$newsize = @()
$newsize = foreach ($Size in $datei.primarysize | where {$_ -gt $datei.primarysize[0]}) {
                                        #$Size
                                        $firstsplit = $Size.split('(')[1]
                                        $firstsplit = $firstsplit.split(' ')[0]
                                        $firstsplit.replace(',','')
}
#$newsize
$sum = 0
$newsize | foreach {$sum += $_}
#Write-Host $sum "Bytes" -ForegroundColor Cyan
$byteswithseperator = "{0:n0}" -f $sum
Write-Host $byteswithseperator "Bytes" -ForegroundColor Green
