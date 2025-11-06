# UnicodeShortcut.psm1
# Create Windows .lnk files using Unicode-safe Shell Link APIs (IShellLinkW + IPersistFile)

# Only add types once per session
if (-not ('ShortcutHelper' -as [type])) {
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;

[ComImport, Guid("00021401-0000-0000-C000-000000000046")]
class ShellLink { }

[ComImport, InterfaceType(ComInterfaceType.InterfaceIsIUnknown),
 Guid("000214F9-0000-0000-C000-000000000046")]
interface IShellLinkW
{
    void GetPath([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszFile, int cch, IntPtr pfd, int fFlags);
    void GetIDList(out IntPtr ppidl);
    void SetIDList(IntPtr pidl);
    void GetDescription([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName, int cch);
    void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string pszName);
    void GetWorkingDirectory([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszDir, int cch);
    void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string pszDir);
    void GetArguments([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszArgs, int cch);
    void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string pszArgs);
    void GetHotkey(out short pwHotkey);
    void SetHotkey(short wHotkey);
    void GetShowCmd(out int piShowCmd);
    void SetShowCmd(int iShowCmd);
    void GetIconLocation([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszIconPath, int cch, out int piIcon);
    void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string pszIconPath, int iIcon);
    void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string pszPathRel, int dwReserved);
    void Resolve(IntPtr hwnd, int fFlags);
    void SetPath([MarshalAs(UnmanagedType.LPWStr)] string pszFile);
}

[ComImport, InterfaceType(ComInterfaceType.InterfaceIsIUnknown),
 Guid("0000010b-0000-0000-C000-000000000046")]
interface IPersistFile
{
    void GetClassID(out Guid pClassID);
    [PreserveSig] int IsDirty();
    void Load([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, uint dwMode);
    void Save([MarshalAs(UnmanagedType.LPWStr)] string pszFileName, bool fRemember);
    void SaveCompleted([MarshalAs(UnmanagedType.LPWStr)] string pszFileName);
    void GetCurFile([MarshalAs(UnmanagedType.LPWStr)] out string ppszFileName);
}

public static class ShortcutHelper
{
    public static void Create(string shortcutPath, string targetPath, string workingDir, string iconPath, int iconIndex, int showCmd, string description, string arguments)
    {
        var link = (IShellLinkW)new ShellLink();
        if (!string.IsNullOrEmpty(targetPath)) link.SetPath(targetPath);
        if (!string.IsNullOrEmpty(workingDir)) link.SetWorkingDirectory(workingDir);
        if (!string.IsNullOrEmpty(iconPath)) link.SetIconLocation(iconPath, iconIndex);
        if (!string.IsNullOrEmpty(description)) link.SetDescription(description);
        if (!string.IsNullOrEmpty(arguments)) link.SetArguments(arguments);
        link.SetShowCmd(showCmd);
        ((IPersistFile)link).Save(shortcutPath, true);
    }
}
"@
}

function New-UnicodeShortcut {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetPath,

        [Parameter(Position=2)]
        [string]$WorkingDirectory,

        [Parameter(Position=3)]
        [string]$IconLocation,

        [int]$IconIndex = 0,

        # 1=Normal, 3=Maximized, 7=Minimized. Common values used by shortcuts.
        [ValidateSet(0,1,3,4,5,7)]
        [int]$WindowStyle = 1,

        [string]$Description,

        [string]$Arguments
    )

    # Ensure destination folder exists
    $destDir = Split-Path -Path $Path -Parent
    if ($destDir -and -not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($Path, "Create Unicode shortcut")) {
        [ShortcutHelper]::Create($Path, $TargetPath, $WorkingDirectory, $IconLocation, $IconIndex, $WindowStyle, $Description, $Arguments)
    }
}

Export-ModuleMember -Function New-UnicodeShortcut