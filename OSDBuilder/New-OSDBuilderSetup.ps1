<#
.SYNOPSIS
    Setup the basics of OSDBuilder

.DESCRIPTION
    https://osdbuilder.osdeploy.com/

.NOTES
    Author:  Michael Escamilla
    Website: https://michaeltheadmin.com
    Twitter: @eskimoruler
#>

### Require that the scrip RunAsAdmin
#Requires -Modules OSDBuilder -RunAsAdministrator

# Get Current Date
$ScriptDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# OSDBuilder Global Settings
$Global:OSDBuilder_Global = [ordered]@{
    ImportOSMediaEditionId = "Enterprise"
    ImportOSMediaUpdate    = $false
    NewOSBuildSkipUpdates  = $true
}
$OSDBuilderjson = New-Item -Path "$($env:ProgramData)\OSDeploy\OSDBuilder.json" -Force
$Global:OSDBuilder_Global | ConvertTo-Json -Depth 10 | Out-File -FilePath $($OSDBuilderjson.FullName) -Force

# Initialize to Import Setting
Get-OSDBuilder -Initialize -Verbose

# Set OSDBuilder Path
#OSDBuilder -SetPath E:\_OSDBuilder

# Mount ISO for Import
$ISOPath = "D:\_ISO\Windows\SW_DVD9_Win_Pro_11_23H2_64BIT_English_Pro_Ent_EDU_N_MLF_X23-59562.ISO"
$ISOPath = "D:\_ISO\Windows\SW_DVD9_Win_Server_STD_CORE_2022_2108.27_64Bit_English_DC_STD_MLF_X23-64869.ISO"
$DiskImage_Mount = Mount-DiskImage -ImagePath $ISOPath

# Import-OSMedia - Should Auto Import the 'Enterprise' index based on our Setting above
#$OSImport = Import-OSMedia -SkipGrid -BuildNetFX
Import-OSMedia -BuildNetFX

# Dismount ISO
$DiskImage_Mount | Dismount-DiskImage

# Avaialble OSMedia
#$OSMedia = Get-OSMedia -GridView

<# # Copy WIM to ConfigMgr OS Image Path
$FileNameOriginal = "install.wim"
$FileNameNew = "$($TaskCustomname)_$($ScriptDate).wim"
$FilePathSource = ""
$FilePathDestination = "\\SCVM2\SourcePackages\OSD\OperatingSystemImages"
Copy-Item -Path $(Join-Path $FilePathSource $FileNameOriginal) -Destination $(Join-Path $FilePathDestination $FileNameNew) #>

# Get

<# # Create a OSBuildTask
$TaskName = "Windows11Enterprise23H2"
$TaskCustomname = "WIN11ENTX6423H2"
New-OSBuildTask -TaskName $TaskName -CustomName $TaskCustomname -EnableNetFX3

# OSBuild
New-OSBuild -ByTaskName $TaskName -Execute

# Copy WIM to ConfigMgr OS Image Path
$FileNameOriginal = "install.wim"
$FileNameNew = "$($TaskCustomname)_$($ScriptDate).wim"
$FilePathSource = ""
$FilePathDestination = "\\SCVM2\SourcePackages\OSD\OperatingSystemImages"
Copy-Item -Path $(Join-Path $FilePathSource $FileNameOriginal) -Destination $(Join-Path $FilePathDestination $FileNameNew)
 #>