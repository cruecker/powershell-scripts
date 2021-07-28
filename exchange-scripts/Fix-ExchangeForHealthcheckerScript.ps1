#pagefile anpassen
#entfernen der OS Vorgabe
$pagefile = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
$pagefile.AutomaticManagedPagefile = $false
$pagefile.put() #| Out-Null
Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges | select AutomaticManagedPagefile

#setzten der Pagefile-Groesse
$pagefileset = Get-WmiObject Win32_pagefilesetting
$pagefileset.InitialSize = 16202
$pagefileset.MaximumSize = 16202
$pagefileset.Put() | Out-Null
Get-WmiObject Win32_pagefilesetting | select Name, InitialSize, MaximumSize

#powersettings setzten
powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

#keepalive setzten in der registry
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "KeepAliveTime" -Value ”1800000”  -PropertyType "Dword"

#SMB1 deaktivieren
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol
Set-SmbServerConfiguration -EnableSMB1Protocol $false

#TLS 1.2 fuer Schannel aktivieren
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "DisabledByDefault" -Value "00000000"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -Value "00000001"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "DisabledByDefault" -Value "00000000"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value "00000001"

#TLS 1.0 und 1.1 fuer Schannel aktivieren
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -Value "00000000"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -Value "00000001"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Value "00000000"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value "00000001"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -Value "00000000"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -Value "00000001"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -Value "00000000"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value "00000001"

#TLS 1.2 fuer .Net 4.x auf OS / schannel vererbung einstellen
Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value "00000001"
Set-Itemproperty -path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value "00000001"
