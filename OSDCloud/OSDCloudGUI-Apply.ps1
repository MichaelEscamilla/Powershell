# Open the smsts.log with CMTrace
cmtrace x:\windows\temp\smstslog\smsts.log
Write-Output "--------------------------------------"
Write-Output ""
Write-Output "OSDCloud Apply OS Step"
Write-Output ""
Write-Output "--------------------------------------"

#Set OSDCloud Params
$OSName = "Windows 11 22H2 x64"
Write-Output "OSName: $OSName"
$OSEdition = "Enterprise"
Write-Output "OSEdition: $OSEdition"
$OSActivation = "Volume"
Write-Output "OSActivation: $OSActivation"
$OSLanguage = "en-us"
Write-Output "OSLanguage: $OSLanguage"

$Global:MyOSDCloud = [ordered]@{
    Restart           = [bool]$False
    RecoveryPartition = [bool]$True
    SkipAllDiskSteps  = [bool]$True
    #DriverPackName = "None"
}
$Global:OSDCloud_MTA = @{
    BrandName            = "Five11OSD"
    BrandColor           = "Orange"
    OSActivation         = "Volume"
    OSEdition            = "Enterprise"
    OSLanguage           = "en-us"
    OSImageIndex         = 6
    OSName               = "Windows 11 22H2 x64"
    OSReleaseID          = "22H2"
    OSVersion            = "Windows 11"
    OSActivationValues   = @(
        "Volume"
    )
    OSEditionValues      = @(
        "Enterprise",
        "Pro"
    )
    OSLanguageValues     = @(
        "en-us"
    )
    OSNameValues         = @(
        "Windows 11 22H2 x64",
        "Windows 10 22H2 x64"
    )
    OSReleaseIDValues    = @(
        "22H2"
    )
    OSVersionValues      = @(
        "Windows 11",
        "Windows 10"
    )
    captureScreenshots   = $false
    ClearDiskConfirm     = $false
    restartComputer      = $true
    updateDiskDrivers    = $true
    updateFirmware       = $false
    updateNetworkDrivers = $true
    updateSCSIDrivers    = $true
}
      

Write-Output "Global:MyOSDCloud"
$Global:MyOSDCloud

#Update Files in Module that have been updated since last PowerShell Gallery Build (Testing Only)
$ModulePath = (Get-ChildItem -Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules\osd" | Where-Object { $_.Attributes -match "Directory" } | select -Last 1).fullname
import-module "$ModulePath/OSD.psd1" -Force

#Launch OSDCloud
Write-Output "Launching OSDCloud"
Write-Output ""
Write-Output "Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage"
Write-Output ""
Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage
Write-Output ""
Write-Output "---------------------------"