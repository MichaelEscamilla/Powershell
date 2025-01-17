#Requires -RunAsAdministrator
function Import-DriversCM {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]$SiteCode,

        [parameter(Mandatory = $true)]
        [System.String]$SourcePath
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
    $DriverSourceFolder = Join-Path $SourcePath "OpenOSD WinPE amd64"
    if (! (Test-Path "$($DriverSourceFolder)")) {
        Write-Output "Creating directory: [$($DriverSourceFolder)]"
        New-Item -Path "$($DriverSourceFolder)" -ItemType Directory -Verbose | Out-Null
    }

    #=================================================
    #   OpenOSD WinPEDrivers
    #=================================================
    $WinPEDrivers = Select-OpenWinPEDrivers -Architecture "amd64"

    #=================================================
    #   Copy Drivers to Source Directory
    #=================================================
    foreach ($Driver in $WinPEDrivers) {
        if (! (Test-Path "$(Join-Path $DriverSourceFolder $Driver.Name)")) {
            New-Item -Path "$($DriverSourceFolder)" -Name $($Driver.Name) -ItemType Directory -Verbose | Out-Null
        }

        # Copy the driver to the source directory
        Copy-Item -Path $($Driver.FullName) -Destination "$($DriverSourceFolder)" -Recurse -Force -Verbose | Out-Null
    
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
        #  Create CM Category
        #=================================================
        $CMCategory = Get-CMCategory -CategoryType DriverCategories -Name "OpenOSD WinPE amd64"
        if ($null -eq $CMCategory) {
            Write-Output "Creating Category: [OpenOSD WinPE amd64]"
            $CMCategory = New-CMCategory -CategoryType DriverCategories -Name "OpenOSD WinPE amd64" -Verbose
        }

        #=================================================
        #  Create CM Root Driver Folder
        #=================================================
        $CMRootFolder = Get-CMFolder -ParentFolderPath Driver -Name "OpenOSD WinPE amd64"
        if ($null -eq $CMRootFolder) {
            Write-Output "Creating Driver Folder: [OpenOSD WinPE amd64]"
            $CMRootFolder = New-CMFolder -ParentFolderPath Driver -Name "OpenOSD WinPE amd64" -Verbose
        }
        
        #=================================================
        #  Create CM Sub Driver Folder
        #=================================================
        $CMSubFolder = Get-CMFolder -FolderPath "Driver\$($CMRootFolder.Name)\$($Driver.Name)"
        if ($null -eq $CMSubFolder) {
            Write-Output "Creating Driver Folder: [OpenOSD WinPE amd64]"
            $CMSubFolder = New-CMFolder -ParentFolderPath "Driver\$($CMRootFolder.Name)" -Name "$($Driver.Name)" -Verbose
        }

        #=================================================
        #   Import Drivers
        #=================================================
        Write-Output "SourceFolderlocation: [$($DriverSourceFolder)]"
        $ImportedDrivers = Import-CMDriver -Path "$(Join-Path $DriverSourceFolder $Driver.Name)" -ImportFolder -AdministrativeCategory $CMCategory
        Write-Output "Successfully Imported: [$($ImportedDrivers.LocalizedDisplayName)]"

        #=================================================
        #   Move Drivers to CM Folder
        #=================================================
        Move-CMObject -InputObject $ImportedDrivers -FolderPath "$($SiteCode):\Driver\$($CMRootFolder.Name)\$($CMSubFolder.Name)"
        #Move-CMObject -InputObject $ImportedDrivers -FolderPath $CMFolder.Name

        # Return to the previous location
        Pop-Location
    }
}

function Import-DriversCM {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]$SiteCode,

        [parameter(Mandatory = $true)]
        [System.String]$SourcePath
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
    $DriverSourceFolder = Join-Path $SourcePath "OpenOSD WinPE amd64"
    if (! (Test-Path "$($DriverSourceFolder)")) {
        Write-Output "Creating directory: [$($DriverSourceFolder)]"
        New-Item -Path "$($DriverSourceFolder)" -ItemType Directory -Verbose | Out-Null
    }

    #=================================================
    #   OpenOSD WinPEDrivers
    #=================================================
    $WinPEDrivers = Select-OpenWinPEDrivers -Architecture "amd64"

    #=================================================
    #   Copy Drivers to Source Directory
    #=================================================
    foreach ($Driver in $WinPEDrivers) {
        if (! (Test-Path "$(Join-Path $DriverSourceFolder $Driver.Name)")) {
            New-Item -Path "$($DriverSourceFolder)" -Name $($Driver.Name) -ItemType Directory -Verbose | Out-Null
        }

        # Copy the driver to the source directory
        Copy-Item -Path $($Driver.FullName) -Destination "$($DriverSourceFolder)" -Recurse -Force -Verbose | Out-Null
    
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
        #  Create CM Category
        #=================================================
        $CMCategory = Get-CMCategory -CategoryType DriverCategories -Name "OpenOSD WinPE amd64"
        if ($null -eq $CMCategory) {
            Write-Output "Creating Category: [OpenOSD WinPE amd64]"
            $CMCategory = New-CMCategory -CategoryType DriverCategories -Name "OpenOSD WinPE amd64" -Verbose
        }

        #=================================================
        #  Create CM Root Driver Folder
        #=================================================
        $CMRootFolder = Get-CMFolder -ParentFolderPath Driver -Name "OpenOSD WinPE amd64"
        if ($null -eq $CMRootFolder) {
            Write-Output "Creating Driver Folder: [OpenOSD WinPE amd64]"
            $CMRootFolder = New-CMFolder -ParentFolderPath Driver -Name "OpenOSD WinPE amd64" -Verbose
        }
        
        #=================================================
        #  Create CM Sub Driver Folder
        #=================================================
        $CMSubFolder = Get-CMFolder -FolderPath "Driver\$($CMRootFolder.Name)\$($Driver.Name)"
        if ($null -eq $CMSubFolder) {
            Write-Output "Creating Driver Folder: [OpenOSD WinPE amd64]"
            $CMSubFolder = New-CMFolder -ParentFolderPath "Driver\$($CMRootFolder.Name)" -Name "$($Driver.Name)" -Verbose
        }

        #=================================================
        #   Import Drivers
        #=================================================
        Write-Output "SourceFolderlocation: [$($DriverSourceFolder)]"
        $ImportedDrivers = Import-CMDriver -Path "$(Join-Path $DriverSourceFolder $Driver.Name)" -ImportFolder -AdministrativeCategory $CMCategory
        Write-Output "Successfully Imported: [$($ImportedDrivers.LocalizedDisplayName)]"

        #=================================================
        #   Move Drivers to CM Folder
        #=================================================
        Move-CMObject -InputObject $ImportedDrivers -FolderPath "$($SiteCode):\Driver\$($CMRootFolder.Name)\$($CMSubFolder.Name)"
        #Move-CMObject -InputObject $ImportedDrivers -FolderPath $CMFolder.Name

        # Return to the previous location
        Pop-Location
    }
}