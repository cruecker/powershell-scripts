<#
.SYNOPSIS
  Exchange Mailbox Folder Permission Script
.DESCRIPTION
  Set a user permission to a mailbox folder
.PARAMETER Add-MailboxFolderPermissions.ps1
  none
.INPUTS
  none
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Claudius Rücker
  Creation Date:  21.07.2021
  Purpose/Change: none
  Keep in mind the target is a networkpath
  
.EXAMPLE
  .\Add-MailboxFolderPermissions.ps1
#>

$MailboxToAddPerm = "<emailaddress>"
$UserToAdd = "<emailaddress>"

ForEach($f in (Get-MailboxFolderStatistics $MailboxToAddPerm | Where { $_.FolderPath.Contains("/Posteingang") -eq $True } ) ) {
    $fname = $MailboxToAddPerm + ":" + $f.FolderPath.Replace("/","\").Replace([char]63743,"/"); Add-MailboxFolderPermission $fname -User $UserToAdd -AccessRights ReadItems, CreateItems, EditOwnedItems, CreateSubfolders, FolderVisible
    Write-Host $fname
    Start-Sleep -Milliseconds 1000
}
