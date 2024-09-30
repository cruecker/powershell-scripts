Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$mailboxes = get-content "D:\Temp\Claudius\Mailboxes.txt"

$perm = foreach ($box in $mailboxes) {
Write-Output $box
Get-Mailbox -Identity $box | Get-ADPermission | ? { $_.ExtendedRights -like "*send*" -and -not ($_.User -match "NT AUTHORITY")} | ft -auto User,ExtendedRights
Get-Mailbox -Identity $box | % {$_.GrantSendOnBehalfTo} | ft Name
Get-Mailbox -Identity $box | Get-MailboxPermission | ?{($_.IsInherited -eq $False) -and -not ($_.User -match "NT AUTHORITY")} | ft User,AccessRights
}

$perm | Out-File -FilePath D:\Temp\Claudius\export-permissions.txt -Encoding utf8
