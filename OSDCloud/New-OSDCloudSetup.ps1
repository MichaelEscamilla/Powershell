<#
.SYNOPSIS
    Setup the basics of OSDCloud

.DESCRIPTION
    Install the WinPE Environment pre-reqs before running
    https://osdcloud.com

.NOTES
    Author:  Michael Escamilla
    Website: https://michaeltheadmin.com
    Twitter: @eskimoruler
#>

### Require that the scrip RunAsAdmin
#Requires -RunAsAdministrator

### Setup an OSDCloudTemplate: Include WinRE and the CU for SecureBoot Vulnerability
$TemplateName = "WinRE-KB5026372"
New-OSDCloudTemplate -Name $TemplateName -WinRE -CumulativeUpdate C:\_OSDCloud\KB5026372\windows11.0-kb5026372-x64_d2e542ce70571b093d815adb9013ed467a3e0a85.msu

### Create an OSDCloudWorkspace - default is located 'C:\OSDCloud'
# Just incase, set the template to the one created above
Set-OSDCloudTemplate -Name $TemplateName
New-OSDCloudWorkspace

### Setup OSDCloudWinPE
# Set a Brand Name to Display
$BrandName = "Michael the Admin"
# Will use the default wallpaper for now, and include some drivers
Edit-OSDCloudWinPE -StartOSDCloudGUI -Brand "$($BrandName)" -UseDefaultWallpaper -CloudDriver WiFi, HP, USB

### Setup the Hyper-V VM Settings
Set-OSDCloudVMSettings -CheckpointVM:$false -Generation 2 -MemoryStartupGB 4 -ProcessorCount 4 -SwitchName "Default Switch" -VHDSizeGB 50