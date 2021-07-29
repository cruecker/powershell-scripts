#pagefile anpassen
#entfernen der OS Vorgabe
$pagefile = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
$pagefile.AutomaticManagedPagefile = $false
$pagefile.put() #| Out-Null
Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges | select AutomaticManagedPagefile

<#setzten der Pagefile-Groesse Ex2016
$pagefileset = Get-WmiObject Win32_pagefilesetting
$pagefileset.InitialSize = 16202
$pagefileset.MaximumSize = 16202
$pagefileset.Put() | Out-Null
Get-WmiObject Win32_pagefilesetting | select Name, InitialSize, MaximumSize
#>

#setzten der Pagefile-Groesse Ex2019
$pagefileset = Get-WmiObject Win32_pagefilesetting
$pagefileset.InitialSize = 4096
$pagefileset.MaximumSize = 4096
$pagefileset.Put() | Out-Null
Get-WmiObject Win32_pagefilesetting | select Name, InitialSize, MaximumSize

#powersettings setzten
powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

#keepalive setzten in der registry
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "KeepAliveTime" -Value ”1800000”  -PropertyType "Dword"

#SMB1 deaktivieren
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Confirm:$false


<#TLS fuer Exchange 2016
#For More Information on how to properly set TLS follow these blog posts:
#Exchange Server TLS guidance Part 1: Getting Ready for TLS 1.2: https://techcommunity.microsoft.com/t5/Exchange-Team-Blog/Exchange-Server-TLS-guidance-part-1-Getting-Ready-for-TLS-1-2/ba-p/607649
#Exchange Server TLS guidance Part 2: Enabling TLS 1.2 and Identifying Clients Not Using It: https://techcommunity.microsoft.com/t5/Exchange-Team-Blog/Exchange-Server-TLS-guidance-Part-2-Enabling-TLS-1-2-and/ba-p/607761
#Exchange Server TLS guidance Part 3: Turning Off TLS 1.0/1.1: https://techcommunity.microsoft.com/t5/Exchange-Team-Blog/Exchange-Server-TLS-guidance-Part-3-Turning-Off-TLS-1-0-1-1/ba-p/607898

#TLS Folder Testen und erstellen wenn nicht vorhanden
$paths = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client", "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client", "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client"

foreach ($path in $paths) {
                            If(!(test-path $path))
                            {
                                  New-Item -Path $path #-WhatIf
                            }
                           }



#TLS 1.2 fuer Schannel aktivieren
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "DisabledByDefault" -Value "00000000" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -Value "00000001" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "DisabledByDefault" -Value "00000000" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value "00000001" -Type "Dword"

#TLS 1.0 und 1.1 fuer Schannel aktivieren
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -Value "00000000" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -Value "00000001" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Value "00000000" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value "00000001" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -Value "00000000" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -Value "00000001" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -Value "00000000" -Type "Dword"
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value "00000001" -Type "Dword"

#TLS 1.2 fuer .Net 4.x auf OS / schannel vererbung einstellen
Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value "00000001" -Type "Dword"
Set-Itemproperty -path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SystemDefaultTlsVersions" -Value "00000001" -Type "Dword"
#>

#vcredist update vorher letzte Version herunterladen
#latest C++ Redistributeable please visit: https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads

cd C:\Install\
.\en_visual_cpp_redistributable_for_visual_studio_2012_update_4_x64_3161523.exe
.\vcredist_x64-2013.exe
