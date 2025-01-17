# Define the URL of the script to download
$url = 'https://raw.githubusercontent.com/MichaelEscamilla/OSD/refs/heads/WinREWiFi/Public/OSDCloudTS/OSD.WinRE.WiFi.ps1'

# Define the path to the temp folder
$tempFolder = [System.IO.Path]::GetTempPath()

# Define the path to save the downloaded script
$tempFilePath = Join-Path -Path $tempFolder -ChildPath 'OSD.WinRE.WiFi.ps1'

# Download the script and save it to the temp folder
Invoke-WebRequest -Uri $url -OutFile $tempFilePath

Write-Output "Script downloaded to $tempFilePath"

# Replace the file within the installed module
$OSDModuleBase = (Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase
$destinationPath = Join-Path -Path $OSDModuleBase -ChildPath 'Public\OSDCloudTS\OSD.WinRE.WiFi.ps1'
Copy-Item -Path $tempFilePath -Destination $destinationPath -Force
Write-Output "Script replaced in module at [$destinationPath]"