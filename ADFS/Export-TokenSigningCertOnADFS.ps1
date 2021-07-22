$certRefs = Get-AdfsCertificate -CertificateType Token-Signing | Where-Object {$_.IsPrimary -eq $true}
$certBytes=$certRefs[0].Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
[System.IO.File]::WriteAllBytes(“C:\Install\adfs-token-signing.cer”, $certBytes)
