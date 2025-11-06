Import-Module (Join-Path $PSScriptRoot 'Modules\UnicodeShortcut.psm1') -Force

$Desktop = [System.Environment]::GetFolderPath('Desktop')
New-UnicodeShortcut `
  -Path (Join-Path $Desktop 'Gatsby.lnk') `
  -TargetPath (Join-Path $PSScriptRoot 'Gatsby.bat') `
  -WorkingDirectory $PSScriptRoot `
  -IconLocation (Join-Path $PSScriptRoot 'Gatsby.ico') `
  -WindowStyle 7