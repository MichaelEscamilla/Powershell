# Set OSDCloudGUI Defaults
$Global:OSDCloud_Defaults = @{
    BrandName            = "Michael The Admin"
    BrandColor           = "Orange"
    ClearDiskConfirm     = $false
    restartComputer      = $true
}

# Create 'Start-OSDCloudGUI.json' - During WinPE SystemDrive will be 'X:'
$OSDCloudGUIjson = New-Item -Path "$($env:SystemDrive)\OSDCloud\Automate\Start-OSDCloudGUI.json" -Force

# Covert data to Json and export to the file created above
$Global:OSDCloud_Defaults | ConvertTo-Json -Depth 10 | Out-File -FilePath $($OSDCloudGUIjson.FullName) -Force
