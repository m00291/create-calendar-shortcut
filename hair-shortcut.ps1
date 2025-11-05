Import-Module (Join-Path $PSScriptRoot 'Modules\UnicodeShortcut.psm1') -Force

$Desktop = [System.Environment]::GetFolderPath('Desktop')
New-UnicodeShortcut `
  -Path (Join-Path $Desktop 'hair.lnk') `
  -TargetPath (Join-Path $PSScriptRoot 'hair.bat') `
  -WorkingDirectory $PSScriptRoot `
  -IconLocation (Join-Path $PSScriptRoot 'hair.ico') `
  -WindowStyle 7