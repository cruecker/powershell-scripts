#Script can be user if you have a foldername containing the "/" example: "Claudius c/o Gummibaeren"
#created by Claudius Ruecker
#Date: 21.07.2021

$MailboxToAddPerm = "<emailaddress>"
$UserToAdd = "<emailaddress>"

ForEach($f in (Get-MailboxFolderStatistics $MailboxToAddPerm | Where { $_.FolderPath.Contains("/Posteingang") -eq $True } ) ) {
    $fname = $MailboxToAddPerm + ":" + $f.FolderPath.Replace("/","\").Replace([char]63743,"/"); Add-MailboxFolderPermission $fname -User $UserToAdd -AccessRights ReadItems, CreateItems, EditOwnedItems, CreateSubfolders, FolderVisible
    Write-Host $fname
    Start-Sleep -Milliseconds 1000
}
