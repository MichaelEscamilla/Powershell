#Requires -RunAsAdministrator
function Import-DriversCM {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $false)]
        [string]$SiteCode = "$((Get-PSDrive -PSProvider CMSite).Name)"
    )

    # Import the Configuration Manager module
    try {
        Import-Module "$(${env:ProgramFiles(x86)})\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1" -ErrorAction Stop
    }
    catch {
        Write-Error "Microsoft Configuration Manager Console is not installed"
        Break
    }

    #=================================================
    #   Create Source Directory for OpenOSD WinPEDrivers
    #=================================================
    $DriverSourcePath = "\\MEMCM-Dev\Source$\Drivers"
    $DriverSourceFolder = "OpenOSD WinPE x64"
    if (! (Test-Path "$(Join-Path $DriverSourcePath $DriverSourceFolder)")) {
        Write-Output "Creating directory: [$($DriverSourcePath)\$($DriverSourceFolder)]"
        $SourceFolderLocation = New-Item -Path "$($DriverSourcePath)" -Name "$($DriverSourceFolder)" -ItemType Directory -Verbose
    }

    #=================================================
    #   OpenOSD WinPEDrivers
    #=================================================
    $WinPEDrivers = Select-OpenWinPEDrivers -Architecture 'amd64'

    #=================================================
    #   Copy Drivers to Source Directory
    #=================================================
    foreach ($Driver in $WinPEDrivers) {
        if (! (Test-Path "$(Join-Path $SourceFolderLocation $Driver.Name)")) {
            $DriverFolder = New-Item -Path "$($SourceFolderLocation)" -Name $($Driver.Name) -ItemType Directory -Verbose
        }

        # Copy the driver to the source directory
        Copy-Item -Path $($Driver.FullName) -Destination "$($SourceFolderLocation.FullName)" -Recurse -Force -Verbose
    
        # Connect to the Configuration Manager site
        if ($SiteCode) {
            try {
                # Set Location to site
                Push-Location "$($SiteCode):\"
                Write-Output "Successfully connected to the Configuration Manager site: [$SiteCode]"
            }
            catch {
                Write-Error "Failed to connect to the Configuration Manager site"
                Break
            }
        }
        else {
            Write-Error "Configuration Manager Site Code is required"
            Break
        }

        #=================================================
        #   Import Drivers
        #=================================================
                Write-Output "SourceFolderlocation: [$($DriverFolder.FullName)]"
        Import-CMDriver -Path "$($DriverFolder.FullName)" -ImportFolder
    }

    # Return to the previous location
    Pop-Location
}