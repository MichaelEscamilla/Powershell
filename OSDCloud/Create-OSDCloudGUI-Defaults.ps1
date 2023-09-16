# Set OSDCloudGUI Defaults
$Global:OSDCloud_Defaults = @{
    BrandName            = "Michael The Admin"
    BrandColor           = "Orange"
    OSActivation         = "Volume"
    OSEdition            = "Enterprise"
    OSLanguage           = "en-us"
    OSImageIndex         = 6
    OSName               = "Windows 11 22H2 x64"
    OSReleaseID          = "22H2"
    OSVersion            = "Windows 11"
    OSActivationValues   = @(
        "Volume",
        "Retail"
    )
    OSEditionValues      = @(
        "Enterprise",
        "Pro"
    )
    OSLanguageValues     = @(
        "ar-sa",
        "bg-bg",
        "cs-cz",
        "da-dk",
        "de-de",
        "el-gr",
        "en-gb",
        "en-us",
        "es-es",
        "es-mx",
        "et-ee",
        "fi-fi",
        "fr-ca",
        "fr-fr",
        "he-il",
        "hr-hr",
        "hu-hu",
        "it-it",
        "ja-jp",
        "ko-kr",
        "lt-lt",
        "lv-lv",
        "nb-no",
        "nl-nl",
        "pl-pl",
        "pt-br",
        "pt-pt",
        "ro-ro",
        "ru-ru",
        "sk-sk",
        "sl-si",
        "sr-latn-rs",
        "sv-se",
        "th-th",
        "tr-tr",
        "uk-ua",
        "zh-cn",
        "zh-tw"
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

# Create 'Start-OSDCloudGUI.json' - During WinPE SystemDrive will be 'X:'
$OSDCloudGUIjson = New-Item -Path "$($env:SystemDrive)\OSDCloud\Automate\Start-OSDCloudGUI.json" -Force

# Covert data to Json and export to the file created above
$Global:OSDCloud_Defaults | ConvertTo-Json -Depth 10 | Out-File -FilePath $($OSDCloudGUIjson.FullName) -Force