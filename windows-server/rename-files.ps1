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
  
.EXAMPLE
  .\rename-files.ps1
#>

$Quellpfad = "<ursprungspfad>"
$Zielpfad = "<zielpfad>"

$files = Get-ChildItem $Quellpfad
$files

ForEach ($file in $files) {
                                    $Name = ($file.name -split "_11" | Select -First 1).Trim()
                                    Move-Item -Path "$Quellpfad\$file" -Destination "$Zielpfad\$name" #-WhatIf
                                    }

