#Script shows Schema Version for Exchange to check before and after a schema update
#Exchange Schema Version auslesen
$snc = (Get-ADRootDSE).SchemaNamingContext
$sncesv = "CN=ms-Exch-Schema-Version-Pt," + $snc
Write-Host "RangeUpper: $((Get-ADObject $sncesv -pr rangeUpper).rangeUpper)"

 
#Exchange Object Version (Domain)
$dnc = (Get-ADRootDSE).DefaultNamingContext
$mesobdnc = "CN=Microsoft Exchange System Objects," + $dnc
Write-Host "ObjectVersion (Domain): $((Get-ADObject $mesobdnc -pr objectVersion).objectVersion)"

 
# Exchange Object Version (Forest)
$cnc = (Get-ADRootDSE).ConfigurationNamingContext
$meoc = "(objectClass=msExchOrganizationContainer)"
Write-Output "ObjectVersion (Configuration): $((Get-ADObject -LDAPFilter $meoc -SearchBase $cnc -pr objectVersion).objectVersion)"
