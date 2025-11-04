Import-Module (Join-Path $PSScriptRoot 'Modules\UnicodeShortcut.psm1') -Force

$Desktop = [System.Environment]::GetFolderPath('Desktop')
New-UnicodeShortcut `
  -Path (Join-Path $Desktop ' .lnk') `
  -TargetPath (Join-Path $PSScriptRoot 'shit.bat') `
  -WorkingDirectory $PSScriptRoot `
  -IconLocation (Join-Path $PSScriptRoot 'shit.ico') `
  -WindowStyle 7