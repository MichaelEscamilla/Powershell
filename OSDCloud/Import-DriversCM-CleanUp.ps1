Import-Module "$(${env:ProgramFiles(x86)})\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" -ErrorAction Stop

Push-Location "DEV:\"

#=================================================
#  Get CM Root Driver Folder
#=================================================
$CMRootFolderamd64 = Get-CMFolder -ParentFolderPath Driver -Name "OpenOSD WinPE amd64"
if ($null -eq $CMRootFolderamd64) {
    Write-Output "Could not find Folder: [OpenOSD WinPE amd64]"
}
$CMRootFolderarm64 = Get-CMFolder -ParentFolderPath Driver -Name "OpenOSD WinPE arm64"
if ($null -eq $CMRootFolderarm64) {
    Write-Output "Could not find Folder: [OpenOSD WinPE arm64]"
}

#=================================================
#  Delete CM Drivers
#=================================================
$CMDriversamd64 = Get-CMDriver -Fast | Where-Object { $_.ObjectPath -match "$($CMRootFolderamd64.Name)" } | Remove-CMDriver -Force
$CMDriversarm64 = Get-CMDriver -Fast | Where-Object { $_.ObjectPath -match "$($CMRootFolderarm64.Name)" } | Remove-CMDriver -Force

#=================================================
#  Delete CM Root Driver Folder
#=================================================
$CMRootFolderamd64 | Remove-CMFolder -Force
$CMRootFolderarm64 | Remove-CMFolder -Force

#=================================================
#  Delete CM Category
#=================================================
Get-CMCategory -CategoryType DriverCategories -Name "OpenOSD WinPE amd64" | Remove-CMCategory -Force
Get-CMCategory -CategoryType DriverCategories -Name "OpenOSD WinPE arm64" | Remove-CMCategory -Force
Get-CMCategory -CategoryType DriverCategories | Remove-CMCategory -Force

#=================================================
#  Return to the original location
#=================================================
Pop-Location

#=================================================
#  Delete CM Driver Source Folder
#=================================================
if (Test-Path "\\MEMCM-DEV\Source$\Drivers\OpenOSD WinPE amd64") {
    Remove-Item -Path "\\MEMCM-DEV\Source$\Drivers\OpenOSD WinPE amd64" -Recurse -Force | Out-Null
}
if (Test-Path "\\MEMCM-DEV\Source$\Drivers\OpenOSD WinPE arm64") {
    Remove-Item -Path "\\MEMCM-DEV\Source$\Drivers\OpenOSD WinPE arm64" -Recurse -Force | Out-Null
}
