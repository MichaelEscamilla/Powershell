$AgentFilePath = "C:\HP\SureRecover\HPSRStaging_OSDCloud\SRAgent"

# Get all the Folders within the $AgentPath
$Files = Get-ChildItem -Path $AgentFilePath -Recurse | Where-Object { $_.PSIsContainer -eq $false }

# Loop through the Folders
foreach ($File in $Files){
    Write-Host "Name Old: [$($File.Name)]"
    Write-Host "Name New: [$($File.Name.ToLower())]"
    Rename-Item -Path $File.FullName -NewName $($File.Name.ToLower()) -Force
}

# Get all the Folders within the $AgentPath
$Folders = Get-ChildItem -Path $AgentFilePath -Recurse | Where-Object { $_.PSIsContainer -eq $true }

# Loop through the Folders
foreach ($Folder in $Folders){
    Write-Host "Name Old: [$($Folder.Name)]"
    Write-Host "Name New: [$($Folder.Name.ToLower())]"
    Rename-Item -Path $Folder.FullName -NewName $($Folder.Name.ToLower()) -Force
}