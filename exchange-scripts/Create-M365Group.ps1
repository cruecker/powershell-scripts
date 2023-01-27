#Claudius creates M365 Groups via Graph
Connect-MgGraph -Scopes Group.ReadWrite.All, GroupMember.ReadWrite.All, User.Read.All
$GroupOwner = (Get-MgUser -UserId "claudius.ruecker@itnetx.ch").Id
$Owner = "https://graph.microsoft.com/v1.0/users/" + $GroupOwner
$NewGroupParams = @{
    "displayName" = "Housi Test Group1"
    "mailNickname"= "HousiTestGroup1"
    "description" = "People who like to discuss how Housi works"
    "owners@odata.bind" = @($Owner)
    "groupTypes" =  @(
                       "Unified"
                     )
    "mailEnabled" =  "true"
    "securityEnabled" = "true"
    "Visibility" = "private"
} 
$Group = New-MgGroup -BodyParameter $NewGroupParams
