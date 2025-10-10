# Current Build Wim
#$buildMediaSourcesBootwimPath = "C:\OSDWorkspace\build\windows-pe\250910-2329-amd64\WinPE-Media\sources\boot.wim"
$buildMediaSourcesBootwimPath = "C:\OSDCloud-IssueTest\Media\sources\boot.wim"
$buildMediaSourcesBootwimPath = "C:\OSDWorkspace\build\windows-pe\250913-2300-amd64\WinPE-Media\sources\boot.wim"
$buildMediaSourcesBootwimPath = "C:\OSDCloud_25H2\Media\sources\boot.wim"

# Mount the Windows Image
Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Source)] Mounting Windows Image: $buildMediaSourcesBootwimPath"
$WindowsImage = Mount-MyWindowsImage $buildMediaSourcesBootwimPath

 # Set a Variable for the Mount Path
$MountPath = $WindowsImage.Path

#=================================================
# Startnet.cmd
$Content = @'
@echo off
::title OSDCloud Pilot WinPE Startup
title OSDCloud ODT Testing
wpeinit
wpeutil DisableFirewall
wpeutil UpdateBootInfo
::powershell.exe -w h -c Invoke-OSDCloudPEStartup OSK
powershell.exe -w h -c Invoke-OSDCloudPEStartup DeviceHardware
powershell.exe -w h -c Invoke-OSDCloudPEStartup WiFi
powershell.exe -w h -c Invoke-OSDCloudPEStartup IPConfig
::powershell.exe -w h -c Invoke-OSDCloudPEStartup UpdateModule -Value OSD
powershell.exe -w h -c Invoke-OSDCloudPEStartup UpdateModule -Value OSDCloud
start /wait PowerShell -NoL -c $Global:MyOSDCloud = [ordered]@{ SkipODT = [bool]$true; ODTFile = (Get-Item 'X:\OSDCloud\ODT\O365ProPlusRetail\MonthlyEnterprise\OSD M365 Monthly Enterprise.xml'); OSDCloudUnattend = [bool]$true }; $Global:MyOSDCloud; Start-OSDCloudGUI
::wpeutil Reboot
pause
'@
$Content = @'
@echo off
title OSDCloud Pilot WinPE Startup
wpeinit
wpeutil DisableFirewall
wpeutil UpdateBootInfo
powershell.exe -w h -c Invoke-OSDCloudPEStartup OSK
powershell.exe -w h -c Invoke-OSDCloudPEStartup DeviceHardware
powershell.exe -w h -c Invoke-OSDCloudPEStartup WiFi
powershell.exe -w h -c Invoke-OSDCloudPEStartup IPConfig
::powershell.exe -w h -c Invoke-OSDCloudPEStartup UpdateModule -Value OSD
powershell.exe -w h -c Invoke-OSDCloudPEStartup UpdateModule -Value OSDCloud
powershell.exe -w h -c Invoke-OSDCloudPEStartup Info
wpeutil Reboot
pause
'@
$Content = @'
@ECHO OFF
wpeinit
cd\
title OSD TESTING
PowerShell -Nol -C Initialize-OSDCloudStartnet
::PowerShell -Nol -C Initialize-OSDCloudStartnetUpdate
@ECHO OFF
start PowerShell -NoL
'@
Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Source)] Adding $MountPath\Windows\System32\startnet.cmd"
$Content | Out-File -FilePath "$MountPath\Windows\System32\startnet.cmd" -Encoding ascii -Width 2000 -Force
#=================================================

# Unmount the Windows Image
$WindowsImage | Dismount-WindowsImage -Save | Out-Null
