# Define the URL of the script to download
$url = 'https://raw.githubusercontent.com/MichaelEscamilla/OSD/refs/heads/WinREWiFi_v2/Public/OSDCloudTS/OSD.WinRE.WiFi.ps1'
$url2 = 'https://raw.githubusercontent.com/MichaelEscamilla/OSD/refs/heads/WinREWiFi_v2/OSD.psd1'

# Define the path to the temp folder
$tempFolder = [System.IO.Path]::GetTempPath()

# Define the path to save the downloaded script
$tempFilePath = Join-Path -Path $tempFolder -ChildPath 'OSD.WinRE.WiFi.ps1'
$tempFilePath2 = Join-Path -Path $tempFolder -ChildPath 'OSD.psd1'

# Download the script and save it to the temp folder
Invoke-WebRequest -Uri $url -OutFile $tempFilePath
Invoke-WebRequest -Uri $url -OutFile $tempFilePath2

Write-Output "Script downloaded to $tempFilePath"
Write-Output "Script downloaded to $tempFilePath2"

# Replace the file within the installed module
$OSDModuleBase = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase
$destinationPath = Join-Path -Path $OSDModuleBase -ChildPath 'Public\OSDCloudTS\OSD.WinRE.WiFi.ps1'
$destinationPath2 = Join-Path -Path $OSDModuleBase -ChildPath 'OSD.psd1'
Copy-Item -Path $tempFilePath -Destination $destinationPath -Force
Copy-Item -Path $tempFilePath -Destination $destinationPath2 -Force
Write-Output "Script replaced in module at [$destinationPath]"
Write-Output "Script replaced in module at [$destinationPath2]"