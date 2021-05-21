<#
.SYNOPSIS
  Dateien verschieben und gleichzeitig umbennen Script
.DESCRIPTION
  Findet alle Dateinen in einem Ordner und entfernt alles nach _11 im Dateinamen (split / trim)
.PARAMETER
    none
.INPUTS
  none
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Claudius Rücker
  Creation Date:  11.05.2021
  Purpose/Change: none
  es wird nach alles _21 gelöscht und die Datei in ein anderes Verzeichnis geschoben
  
.EXAMPLE
  .\rename-files.ps1
#>

$Quellpfad = "<pfad eintragen>"
$Zielpfad = "<pfad eintragen>"

$files = Get-ChildItem $Quellpfad
$files

ForEach ($file in $files) {
                                    $Name = ($file.name -split "_21" | Select -First 1).Trim()
                                    Move-Item -Path "$Quellpfad\$file" -Destination "$Zielpfad\$name" #-WhatIf
                                    Write-Host "moved to" $Zielpfad\$name -ForegroundColor Green
                                    }
