# Favorites file location ('25' will most likely need to be updated for future versions)
$favoritesFile = "$env:APPDATA\TechSmith\SnagIt\25\Favorites.xml"

# Backup Folder location
$backupLocation = "$env:USERPROFILE\Downloads\SnagIt-Favorites-Backup"

# Create backup folder if it doesn't exist
if (-not (Test-Path -Path $backupLocation)) {
    New-Item -ItemType Directory -Path $backupLocation | Out-Null
}

# Create timestamp for the backup file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Create the backup file name
$backupFileName = "Favorites-$timestamp.xml"

# Full path for the backup file
$backupFilePath = Join-Path -Path $backupLocation -ChildPath $backupFileName

# Copy the favorites file to the backup location
if (Test-Path -Path $favoritesFile) {
    Copy-Item -Path $favoritesFile -Destination $backupFilePath
    Write-Output "Backup completed: $backupFilePath"
} else {
    Write-Output "Favorites file not found: $favoritesFile"
}

# Optional: Open the backup folder in File Explorer
#Start-Process explorer.exe $backupLocation

