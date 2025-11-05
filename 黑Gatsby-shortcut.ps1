Import-Module (Join-Path $PSScriptRoot 'Modules\UnicodeShortcut.psm1') -Force

$Desktop = [System.Environment]::GetFolderPath('Desktop')
New-UnicodeShortcut `
  -Path (Join-Path $Desktop '黑Gatsby.lnk') `
  -TargetPath (Join-Path $PSScriptRoot '黑Gatsby.bat') `
  -WorkingDirectory $PSScriptRoot `
  -IconLocation (Join-Path $PSScriptRoot '黑Gatsby.ico') `
  -WindowStyle 7