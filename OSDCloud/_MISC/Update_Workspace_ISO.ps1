$BuildFolder = "250428-2126-amd64"

$Params = @{
    MediaPath      = "C:\OSDWorkspace\build\windows-pe\$BuildFolder\WinPE-Media"
    IsoFileName    = "BootMedia.iso"
    IsoLabel       = "BCDBootTesting"
    WindowsAdkRoot = "C:\OSDWorkspace\cache\adk-versions\10.1.26100.2454"
    IsoDirectory   = "C:\OSDWorkspace\build\windows-pe\$BuildFolder\ISO"
}
New-WindowsAdkISO @Params