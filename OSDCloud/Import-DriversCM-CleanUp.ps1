Import-Module "$(${env:ProgramFiles(x86)})\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" -ErrorAction Stop

Push-Location "DEV:\"

#=================================================
#  Get CM Root Driver Folder
#=================================================
$CMRootFolder = Get-CMFolder -ParentFolderPath Driver -Name "OpenOSD WinPE amd64"
if ($null -eq $CMRootFolder) {
    Write-Output "Could not find Folder: [OpenOSD WinPE amd64]"
    Pop-Location
    Exit
}

#=================================================
#  Delete CM Drivers
#=================================================
$CMDrivers = Get-CMDriver -Fast | Where-Object { $_.ObjectPath -match "$($CMRootFolder.Name)" } | Remove-CMDriver -Force

#=================================================
#  Delete CM Root Driver Folder
#=================================================
$CMRootFolder | Remove-CMFolder -Force

#=================================================
#  Delete CM Category
#=================================================
Get-CMCategory -CategoryType DriverCategories -Name "OpenOSD WinPE amd64" | Remove-CMCategory -Force

Pop-Location