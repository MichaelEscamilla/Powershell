# Current Build Wim
$buildMediaSourcesBootwimPath = "C:\OSDWorkspace\build\windows-pe\250420-2223-arm64\WinPE-Media\sources\boot.wim"

# Driver Path
$DriverPaths = "C:\SWSetup\sp157878\src\Driver"

# Mount the Windows Image
Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Source)] Mounting Windows Image: $buildMediaSourcesBootwimPath"
$WindowsImage = Mount-MyWindowsImage $buildMediaSourcesBootwimPath

# Set a Variable for the Mount Path
$MountPath = $WindowsImage.Path

#=================================================
#region Inject Drivers
Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] WinPEDriver: Add-WindowsDriver"
if (Test-Path $DriverPath) {
	Write-Host -ForegroundColor DarkGray "$DriverPath"
        
	try {
		# PowerShell
		$WindowsImage | Add-WindowsDriver -Driver $DriverPath -ForceUnsigned -Recurse -ErrorAction Stop
	}
	catch {
		Write-Error -Message 'Driver failed to install. Root cause may be found in the following Dism Log'
		Write-Error -Message "$CurrentLog"
	}
}
else {
	Write-Warning "WinPEDriver $DriverPath (not found)"
}
#endregion
#=================================================

# Unmount the Windows Image
$WindowsImage | Dismount-WindowsImage -Save | Out-Null