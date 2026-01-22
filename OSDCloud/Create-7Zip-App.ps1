$SourcePath = "C:\Users\Eskim\Downloads\7-Zip_24.09_EXE"
# Package MSI as .intunewin file
$SourceFolder = Join-Path $SourcePath "Source"
$SetupFile = "7z2409-x64.exe"
$OutputFolder = Join-Path $SourcePath "Output"
$Win32AppPackage = New-IntuneWin32AppPackage -SourceFolder $SourceFolder -SetupFile $SetupFile -OutputFolder $OutputFolder -Verbose

# Get intunewin file path
$IntuneWinFile = $Win32AppPackage.Path

# Create custom display name like 'Name' and 'Version'
$DisplayName = "7-Zip 24.09 - EXE"
$Publisher = "Igor Pavlov"

# Create requirement rule for all platforms and Windows 10 20H2
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture x64 -MinimumSupportedWindowsRelease "W10_1607"  
  
# Create detection rule
$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Path "C:\Program Files\7-Zip" -FileOrFolder "7zFM.exe" -Version -VersionValue "24.9.0.0" -Operator equal

# Convert image file to icon
$ImageFile = Join-Path (Join-Path $SourcePath "Logo") "7-Zip.png"
$Icon = New-IntuneWin32AppIcon -FilePath $ImageFile

# Add new MSI Win32 app
$Win32App = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description "Install 7-zip application" -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -Icon $Icon -Verbose

# Add assignment for all users
Add-IntuneWin32AppAssignmentAllUsers -ID $Win32App.id -Intent "available" -Notification "showAll" -Verbose
