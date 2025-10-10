# Current Build Wim
#$buildMediaSourcesBootwimPath = "C:\OSDWorkspace\build\windows-pe\250910-2329-amd64\WinPE-Media\sources\boot.wim"
$buildMediaSourcesBootwimPath = "C:\OSDCloud-IssueTest\Media\sources\boot.wim"
$buildMediaSourcesBootwimPath = "C:\OSDWorkspace\build\windows-pe\251003-2141-amd64\WinPE-Media\sources\boot.wim"

# Mount the Windows Image
Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Source)] Mounting Windows Image: $buildMediaSourcesBootwimPath"
$WindowsImage = Mount-MyWindowsImage $buildMediaSourcesBootwimPath

 # Set a Variable for the Mount Path
$MountPath = $WindowsImage.Path

#=================================================
#region Copy PowerShell Modules
#$ModuleNames = @('OSDCloud.Michael')
$ModuleNames = @('OSD', 'OSDCloud')
$ModuleNames | ForEach-Object {
	$ModuleName = $_
	Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Source)] Copy PowerShell Module to BootImage: $ModuleName"
	Copy-PSModuleToWindowsImage -Name $ModuleName -Path $MountPath | Out-Null
}
#endregion
#=================================================

# Unmount the Windows Image
$WindowsImage | Dismount-WindowsImage -Save | Out-Null