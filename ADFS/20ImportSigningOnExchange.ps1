#region variablen
$Server1 = "<hostname server1>"
$Server2 = "<hostname server2>"
$Server3 = "<hostname server3>"
$Server4 = "<hostname server4>"
$CertificatePath = "C:\Temp\adfs-token-signing.cer"
$ExCertThumbprint = "<Thumbprint>"
#endregion


#region import exchange certificate to local certstore
Invoke-Command -ComputerName $Server1 -ScriptBlock {Import-Certificate -FilePath $using:CertificatePath -CertStoreLocation Cert:\LocalMachine\Root}
Invoke-Command -ComputerName $Server2 -ScriptBlock {Import-Certificate -FilePath $using:CertificatePath -CertStoreLocation Cert:\LocalMachine\Root}
Invoke-Command -ComputerName $Server3 -ScriptBlock {Import-Certificate -FilePath $using:CertificatePath -CertStoreLocation Cert:\LocalMachine\Root}
Invoke-Command -ComputerName $Server4 -ScriptBlock {Import-Certificate -FilePath $using:CertificatePath -CertStoreLocation Cert:\LocalMachine\Root}
#endregion
