Import-Module (Join-Path $PSScriptRoot 'Modules\UnicodeShortcut.psm1') -Force

$Desktop = [System.Environment]::GetFolderPath('Desktop')
New-UnicodeShortcut `
  -Path (Join-Path $Desktop 'Adidas.lnk') `
  -TargetPath (Join-Path $PSScriptRoot 'Adidas.bat') `
  -WorkingDirectory $PSScriptRoot `
  -IconLocation (Join-Path $PSScriptRoot 'Adidas.ico') `
  -WindowStyle 7