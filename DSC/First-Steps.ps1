#Holen der Module der DSC Module zeigt uns alle verfügbaren Module
Get-DscResource

#Aufgabe Config des MAPS Service erstellen
Configuration StopMaps
{
    Param([String[]]$ComputerName = $env:COMPUTERNAME)
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    node $ComputerName
    {
        Service DisableMaps
        {
            Name = "MapsBroker"
            StartupType = "Disabled"
            State = "Stopped"
        }
    }
}

#Oberen Code ausführen mit F8
#dann in das Verzeichnis des MOF wechseln
cd \dsc

#Ausführen des Codes von oben um das MOF File zu erstellen
StopMaps

#Konfiguration anwenden
Start-DscConfiguration -Path stopmaps -Wait -Verbose

#Testen der aktuellen Konfiguration
Test-DscConfiguration -CimSession localhost

#Wenn man einen eindeutigen Namen möchte kann man eine GUID erstellen und die MOF-Datei umbennen
Rename-Item -path C:\DSC\StopMaps\SL81082A.mof -NewName C:\DSC\StopMaps\$(New-Guid).mof

#Datei mit einem Checksume File versehen
New-DscChecksum -Path C:\DSC\StopMaps\de1647cd-e53a-4aaa-a55f-49b1be1f4222.mof

#Config des DSC Configuraiton Manger anzeigen
Get-DscLocalConfigurationManager
