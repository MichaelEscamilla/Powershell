<#
.SYNOPSIS
    Setup the basics of OSDCloud

.DESCRIPTION
    Install the WinPE Environment pre-reqs before running
    https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
    https://osdcloud.com

.NOTES
    Author:  Michael Escamilla
    Website: https://michaeltheadmin.com
    Twitter: @eskimoruler
#>

### Require that the scrip RunAsAdmin
#Requires -Modules OSD -RunAsAdministrator

#region Functions
#endregion

# Get Current Date
$ScriptDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

### Setup an OSDCloudTemplate
$TemplateName = "$($ScriptDate)"
New-OSDCloudTemplate -Name $TemplateName -WinRE

### Create an OSDCloudWorkspace - default is located 'C:\OSDCloud'
# Just incase, set the template to the one created above
Set-OSDCloudTemplate -Name $TemplateName
New-OSDCloudWorkspace -WorkspacePath "$($env:SystemDrive)\OSDCloud_$($TemplateName)"

### Cleanup Workspace
# Cleanup Languages
$KeepTheseDirs = @('boot','efi','en-us','sources','fonts','resources')
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media" | Where {$_.PSIsContainer} | Where {$_.Name -notin $KeepTheseDirs} | Remove-Item -Recurse -Force
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\Boot" | Where {$_.PSIsContainer} | Where {$_.Name -notin $KeepTheseDirs} | Remove-Item -Recurse -Force
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\EFI\Microsoft\Boot" | Where {$_.PSIsContainer} | Where {$_.Name -notin $KeepTheseDirs} | Remove-Item -Recurse -Force

### Setup OSDCloudWinPE
# Download Wallpaper
$SaveLocation = "C:\_OSDCloud\Wallpaper"
$FileURL = "https://raw.githubusercontent.com/MichaelEscamilla/MichaelTheAdmin/257cbdca6cc130f104d8cf00b91e662ca115a17d/OSD/BootImage/MtA_Wallpaper_1024x768.jpg"
$FileURL_PMPC = "https://raw.githubusercontent.com/MichaelEscamilla/MichaelTheAdmin/refs/heads/main/OSD/BootImage/PatchMyPC_1024x768.jpg"
$FileName = $(($FileURL -split "/")[-1])
$SavedFile = Save-WebFile -SourceUrl $FileURL -DestinationName $FileName -DestinationDirectory $SaveLocation -Overwrite

# Set a Brand Name to Display
$BrandName = "Michael the Admin"
# Will use the default wallpaper for now, and include some drivers
Edit-OSDCloudWinPE -StartOSDCloudGUI -Brand "$($BrandName)" -Wallpaper "$($SavedFile.FullName)" -CloudDriver WiFi, USB, HP, Dell

### Setup the Hyper-V VM Settings using the 'Default Switch'
#Set-OSDCloudVMSettings -CheckpointVM:$false -Generation 2 -MemoryStartupGB 4 -ProcessorCount 4 -SwitchName "Default Switch" -VHDSizeGB 50
#Set-OSDCloudVMSettings -CheckpointVM:$false -Generation 2 -MemoryStartupGB 4 -ProcessorCount 4 -SwitchName "VM-Switch" -VHDSizeGB 50
