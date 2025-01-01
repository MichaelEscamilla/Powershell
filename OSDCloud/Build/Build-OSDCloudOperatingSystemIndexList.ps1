# Define a place to store the ESD Files
$ESDStorage = "C:\_ESDStorage"

# Get the Cloud Operating Systems
$ESDFilesX64 = Get-OSDCloudOperatingSystems -OSArch x64
$ESDFilesARM64 = Get-OSDCloudOperatingSystems -OSArch ARM64

#=================================================
#   Get Index Info - x64
#=================================================
# Define a Image Index List
$ImageIndexList = @()

# Define a Counter
$Counter = 0

# Loop through the ESD Files
ForEach ($ESD in $ESDFilesX64) {
    # Increment the Counter
    $Counter++

    Write-Host -ForegroundColor Cyan "Starting: [$($ESD.Name)] - [$(("{0:D$($ESDFilesX64.Count.Measure)}" -f $Counter)) of $($ESDFilesX64.Count)]"
    Write-Host -ForegroundColor Green "Time: [$(Get-Date -Format HH:mm:ss-yyyy-MM-dd)]"

    # Define a Folder Path
    $ImageFolderPath = "$ESDStorage\$($ESD.Version) $($ESD.ReleaseID) $($ESD.Architecture)"
    # Check if the Folder Exists - Else Create it
    if (-Not (Test-Path -Path $ImageFolderPath)) { New-Item -Path $ImageFolderPath -ItemType Directory -Force | Out-Null }
    # Define an Image Path
    $ImagePath = "$ImageFolderPath\$($ESD.FileName)"
    $ImageDownloadRequired = $true
    # Check if the Image Exists
    if (Test-Path -Path $ImagePath) {
        Write-Host "Foung previously downloaded media, Checking Image SHA1 Hash"
        # Get the Hash of the Image
        $ImageHash = Get-FileHash -Path $ImagePath -Algorithm SHA1
        # Check if the Hash is the same
        if ($ImageHash.Hash -eq $ESD.SHA1) {
            Write-Host "Skipping Download, SHA1 Hash Match: [$($ImagePath)]"
            $ImageDownloadRequired = $false
        }
        else {
            Write-Host -ForegroundColor Gray "SHA1 Match Failed on $ImagePath, removing content"
        }
    }

    # Download the Image
    if ($ImageDownloadRequired) {
        Write-Host "Downloading Image: [$($ImagePath)]"
        # Kill existing download jobs of Image
        $ExistingBitsJob = Get-BitsTransfer -Name "$($ESD.FileName)" -AllUsers -ErrorAction SilentlyContinue
        if ($ExistingBitsJob) { Remove-BitsTransfer -BitsJob $ExistingBitsJob }
        # Start Bits Service
        if ((Get-Service -Name BITS).Status -ne "Running") {
            Write-Host "BITS Service is not running, attempting to start"
            Start-Service -Name BITS -PassThru
            Start-Sleep -Seconds 2
        }
        # Download the Image
        Write-Host -ForegroundColor DarkGray "Start-BitsTransfer`n`t-Source:`t[$($ESD.Url)]`n`t-Destination:`t[$($ImageFolderPath)]`n`t-DisplayName:`t[$($ESD.FileName)]`n`t-Description:`t['Windows Media Download']`n`t-RetryInterval:`t[60]"
        $BitsJob = Start-BitsTransfer -Source $ESD.Url -Destination $ImageFolderPath -DisplayName $ESD.FileName -Description "Windows Media Download" -RetryInterval 60
    }
}