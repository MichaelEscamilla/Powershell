param (
    [switch]$RunOnStartup = $true,
    [switch]$AcceptEULA = $true,
    [switch]$HideTrayIcon = $true,
    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x64"
)

### Set Download URL based on architecture
if ($Architecture -eq "x64") {
    $DownloadURL = "https://live.sysinternals.com/ZoomIt64.exe"
} else {
    $DownloadURL = "https://live.sysinternals.com/ZoomIt.exe"
}

### Parse File Name from Download URL
$FileName = $DownloadURL.Split("/")[-1]

### Set Save Path
$SavePath = [Environment]::GetFolderPath('MyDocuments')


### Combine Save Path and File Name
$SaveFile = Join-Path -Path $SavePath -ChildPath $FileName

### Download ZoomIt
Invoke-WebRequest -Uri $DownloadURL -OutFile $SaveFile

### Run On Startup via Registry
if ($RunOnStartup) {
    # Define the registry path for startup programs
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    
    # Define the registry entry name for ZoomIt
    $RegName = "ZoomIt"
    
    # Define the registry entry value as the path to the ZoomIt executable
    $RegValue = $SaveFile
    
    # Create or update the registry entry to run ZoomIt on startup
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType String -Force | Out-Null
}

### Create Accept EULA Registry Key if AcceptEULA switch is set
if ($AcceptEULA) {
    # Define the registry path for ZoomIt settings
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    
    # Define the registry entry name for EULA acceptance
    $RegName = "EulaAccepted"
    
    # Define the registry entry value to indicate EULA acceptance
    $RegValue = "1"
    
    # Create the registry path if it doesn't exist
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    # Create or update the registry entry to accept the EULA
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord -Force | Out-Null
}

### Remove from System Tray
if ($HideTrayIcon) {
    # Define the registry path for ZoomIt settings
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    
    # Define the registry entry name for showing the system tray icon
    $RegName = "ShowTrayIcon"
    
    # Define the registry entry value to hide the system tray icon
    $RegValue = "0"
    
    # Create the registry path if it doesn't exist
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    # Create or update the registry entry to hide the system tray icon
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord -Force | Out-Null
}