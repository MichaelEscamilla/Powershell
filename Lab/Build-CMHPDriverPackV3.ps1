$FilePath = "C:\_HPDrivers"

# Function Connect to ConfigMgr
function Connect-ConfigMgr
{
	param
	(
		[parameter(Mandatory = $false)]
		[bool]
		$OutputInfo = $true
	)
	# Load ConfigMgr
	try
	{
		if ($OutputInfo)
		{
			Write-Host "Connecting to ConfigMgr Site..."
		}
		
		# Variables for Enterprise
		$SiteCode = "511"
		$SiteServer = "SCVM2.511tactical.com"
		
		# Get Current Location
		$script:OriginalLocation = Get-Location
		
		# Import the Configuration Manager Cmdlets, Be sure to install them to the system first
		Import-Module ConfigurationManager
		
		# Get SCCM Site and Set Locatio to Site
		$SiteCode = Get-PSDrive -PSProvider CMSite
		Set-Location "$($SiteCode.Name):\"
		
		if ($OutputInfo)
		{
			Write-Host "Successfully connected to CM Site: [$($SiteCode.Name)]" -ForegroundColor Green
		}
	}
	catch
	{
		if ($OutputInfo)
		{
			Write-Host "ERROR - CM Powershell: $_" -ForegroundColor Red
		}
		Throw
	}
}
# Function Disconnect to ConfigMgr
function Disconnect-ConfigMgr
{
	param
	(
		[parameter(Mandatory = $false)]
		[bool]
		$OutputInfo = $true
	)
	
	if ($OutputInfo)
	{
		Write-Host "Disconnecting from ConfigMgr Site..."
	}
	
	# Set location back to original
	Set-Location $script:OriginalLocation
	
	if ($OutputInfo)
	{
		Write-Host "Successfully Set Location back to where you were" -ForegroundColor Green
	}
}
# Function
function Build-HpDriverPack
{
	param
	(
		[parameter(Mandatory = $true)]
		$HPDeviceDetails,
		[parameter(Mandatory = $true)]
		$OSInformation,
		[Parameter(Mandatory = $false)]
		[string]$DriverPackSavePath = "$($env:SystemDrive)\_HPDrivers",
		[Parameter(Mandatory = $false)]
		[switch]$TestMode
	)
	
	# Loop through all SystemsIDs in $HPDeviceDetails
	$DriverPack = $null
	foreach ($Device in $HPDeviceDetails)
	{
		try
		{
			# Get Device Drivers
			$DeviceDriverPack = Get-SoftpaqList -Os $OSInformation.OSNameShort -OsVer $OSInformation.OSVersion -Characteristic DPB -Platform $Device.SystemID
			Write-Host "System Name: [$($Device.Name)] - SystemID: [$($Device.SystemID)] - Driver Count: [$($DeviceDriverPack.Count)]"
			
			# Add Device Sofpaqs to Total
			$DriverPack = $DriverPack + $DeviceDriverPack
		}
		catch
		{
			Write-Host "ERROR - Could not find drivers for [$($OSInformation.OSName) $($OSInformation.OSVersion)] and SystemID: [$($Device.SystemID)]" -ForegroundColor Red
		}
	}
	
	# Get Unique Softpaqs for all found Drivers
	$DriverPackUnique = $DriverPack | Sort-Object id | Get-Unique -AsString
	Write-Host "Unique Driver Count: [$($DriverPackUnique.Count)]"
	
	# Build DriverPack
	$script:DriverPackSavePath = $DriverPackSavePath
	$DriverPackName = "$($DeviceDetails[0].SystemID -replace '\s', '')$($OSInformation.OSNameShort)$($OSInformation.OSVersion)"
	$DriverPackNameFile = "$DriverPackName.Wim"
	
	Write-Host "Building Driver Pack: [$($DriverPackName)]"
	
	# Check if Directory Already Exists
	Write-Host "DriverPack Save Path: [$DriverPackSavePath]"
	$DriverPackSavePathTest = Test-Path -Path "$($DriverPackSavePath)"
	if ($TestMode)
	{
		Write-Host "Save Directory Test: [$($DriverPackSavePathTest)]"
		Write-Host "`tSave Directory Test Path: [$($DriverPackSavePath)]"
	}
	if (!($DriverPackSavePathTest))
	{
		# Create Directory
		Write-Host "Creating Driver Pack Save Path: [$($DriverPackSavePath)]"
		$DriverPackSavePathNew = New-Item -Path $DriverPackSavePath -ItemType Directory
		if ($DriverPackSavePathNew)
		{
			Write-Host "`tSuccessfully Created Driver Pack Save Path" -ForegroundColor Green
		}
		else
		{
			$DriverPackSavePathNew
		}
	}
	# Check if Driver Pack File already Exists in Save Path
	if ($DriverPackSavePathTest)
	{
		$DriverPackNameTest = Test-Path -Path "$($DriverPackSavePath)\$($DriverPackNameFile)"
		if ($TestMode)
		{
			Write-Host "Driver Pack Test: [$($DriverPackNameTest)]"
			Write-Host "`tDriver Pack Test Path: [$($DriverPackSavePath)\$($DriverPackNameFile)]"
		}
		# Rename old File in Save Path
		if ($DriverPackNameTest)
		{
			Write-Host "Existing Driver Pack File already Exists, Renaming File..." -ForegroundColor Yellow
			
			# Get Date
			$CurrentDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
			$DriverPackNameFileRename = "$($DriverPackName)_$($CurrentDate).Wim"
			Rename-Item -Path "$($DriverPackSavePath)\$($DriverPackNameFile)" -NewName "$($DriverPackSavePath)\$($DriverPackNameFileRename)"
			
			Write-Host "`tSuccessfully Renamed existing file: [$($DriverPackNameFileRename)]" -ForegroundColor Green
		}
	}
	
	if (!($TestMode))
	{
		# Build Driver Pack
		$NewHPDriverPack = New-HPBuildDriverPack -Softpaqs $DriverPackUnique -Os $OSInformation.OSNameShort -OSVer $OSInformation.OSVersion -Path $DriverPackSavePath -Format Wim -Name $DriverPackName -ErrorAction Stop
	}
	else
	{
		$NewHPDriverPack = @(
			[pscustomobject]@{ Name = "$DriverPackNameFile" }
		)
		New-Item -Path "$($DriverPackSavePath)\$($NewHPDriverPack.Name)" | Out-Null
	}
	return $NewHPDriverPack
}

try
{
	# Find Devices Device Details
	try
	{
		Write-Host "############# Select HP Model #############" -ForegroundColor Cyan
		
		# Prompt User for a Model to search For
		$DeviceSearchText = Read-Host -Prompt "Enter A Model Name to Search (eg; '840 G8')"
		
		# Get all models 'like' the given input
		$DeviceSearchDetails = Get-HPDeviceDetails -Name "$($DeviceSearchText)" -Like -ErrorAction Stop
		
		# Check if Device is found
		if ($DeviceSearchDetails)
		{
			# Check if there are more than one Found Model After Sorting by unquie model Names
			$DeviceSearchDetailsUnique = $DeviceSearchDetails | select Name | Sort-Object Name | Get-Unique -AsString
			
			# Check if more than one unique device was found
			if (($DeviceSearchDetailsUnique | Measure-Object).Count -gt 1)
			{
				# Saved Selected Model
				$DeviceSearchDetailsSelected = $DeviceSearchDetails | select Name | Sort-Object Name | Get-Unique -AsString | Out-GridView -Title "Select a Computer Model" -OutputMode Single
			}
			else
			{
				$DeviceSearchDetailsSelected = $DeviceSearchDetails[0] | select Name
				
			}
			
			# Check if Device Details Are Found
			if ($DeviceSearchDetailsSelected)
			{
				# Loop through all the Devices Found
				Write-Host "Device Model Selected: [$($DeviceSearchDetailsSelected.Name)]"
				Write-Host "Number of SystemIDs for Model: [$(($DeviceSearchDetails | Measure-Object).Count)]"
			}
		}
		else
		{
			Write-Host "No Models Found" -ForegroundColor Red
			throw
		}
		
		Write-Host "###########################################" -ForegroundColor Cyan
	}
	catch
	{
		Write-Host "ERROR - Device Selection: $_" -ForegroundColor Red
		throw
	}
	
	# Select OS Information
	try
	{
		Write-Host "############# Select Operating System #############" -ForegroundColor Cyan
		Write-Host "Select Operating Systems..."
		
		# Build OS Info Object
		$OSInformation = @(
			[pscustomobject]@{ OSName = 'Windows 11'; OSNameShort = 'Win11'; OSVersion = '22H2'; OSCodeName = '22H2'; OSBuild = '22621'; OSBitness = 'x64' },
			[pscustomobject]@{ OSName = 'Windows 11'; OSNameShort = 'Win11'; OSVersion = '21H2'; OSCodeName = '21H2'; OSBuild = '22000'; OSBitness = 'x64' },
			[pscustomobject]@{ OSName = 'Windows 10'; OSNameShort = 'Win10'; OSVersion = '22H2'; OSCodeName = '22H2'; OSBuild = '19045'; OSBitness = 'x64' },
			[pscustomobject]@{ OSName = 'Windows 10'; OSNameShort = 'Win10'; OSVersion = '21H2'; OSCodeName = '21H2'; OSBuild = '19044'; OSBitness = 'x64' },
			[pscustomobject]@{ OSName = 'Windows 10'; OSNameShort = 'Win10'; OSVersion = '21H1'; OSCodeName = '21H1'; OSBuild = '19043'; OSBitness = 'x64' },
			[pscustomobject]@{ OSName = 'Windows 10'; OSNameShort = 'Win10'; OSVersion = '20H2'; OSCodeName = '2009'; OSBuild = '19042'; OSBitness = 'x64' },
			[pscustomobject]@{ OSName = 'Windows 10'; OSNameShort = 'Win10'; OSVersion = '20H1'; OSCodeName = '2004'; OSBuild = '19041'; OSBitness = 'x64' }
		)
		
		# Have User select OS Info, but only display certain columns
		$OSInfoSelectedUser = $OSInformation | select OSName, OSVersion, OSBuild | Out-GridView -Title "Select the OS Name and Version" -OutputMode Multiple

		# Use selected record to get all colmuns values
		$OSInfoSelected = Compare-Object -ReferenceObject $OSInformation -DifferenceObject $OSInfoSelectedUser -IncludeEqual -ExcludeDifferent -Property OSName, OSVersion, OSBuild -PassThru
		if (!($OSInfoSelected))
		{
			Write-Host "No Operating System selected" -ForegroundColor Red
			throw
		}
		
		# Output selected information
		foreach ($OSInfo in $OSInfoSelected)
		{
			Write-Host "`tSelected OS Information: [$($OSInfo.OSName) $($OSInfo.OSVersion)]"
		}
		
		Write-Host "###################################################" -ForegroundColor Cyan
	}
	catch
	{
		Write-Host "ERROR - OS Selection: $_" -ForegroundColor Red
		throw
	}
	
	# Select Distribution Point Group
	try
	{
		Write-Host "############# Select Distribution Point Group #############" -ForegroundColor Cyan
		Write-Host "Select Distribution Point to Distribute Package..."
		
		# Connect to ConfigMgr to Create Package
		Connect-ConfigMgr
		
		# Get Distribution Point Options
		$DistributionPointGroups = Get-CMDistributionPointGroup
		$DistributionPoints = Get-CMDistributionPoint
		
		# Build Distribution Selectable Object
		$DistributionOptions = @()
		# Add Distribution Point Groups
		foreach ($DistributionOption in $DistributionPointGroups)
		{
			$Distribution = [pscustomobject]@{ Type = "Distribution Point Group"; Name = "$($DistributionOption.Name)" }
			$DistributionOptions += $Distribution
		}
		# Add Distribution Points
		#			foreach ($DistributionOption in $DistributionPoints)
		#			{
		#				$Distribution = [pscustomobject]@{ Type = "Distribution Point"; Name = "$($DistributionOption.NetworkOSPath)" }
		#				$DistributionOptions += $Distribution
		#			}
		
		# Have User select Distribution Point Group
		$DistributionOptionsSelected = $DistributionOptions | Out-GridView -Title "Select a Distribution Point or Group" -OutputMode Single
		if (!($DistributionOptionsSelected))
		{
			Write-Host "No Distribution Group selected" -ForegroundColor Red
			throw
		}
		
		# Use selected record to get all colmuns values
		#$DistributionOptionsSelected = $OSInfo | Where-Object { ($_.OSName -eq $OSInfoSelectedUser.OSName) -and ($_.OSVersion -eq $OSInfoSelectedUser.OSVersion) }
		
		# Disconnect from ConfigMg
		Disconnect-ConfigMgr
		
		Write-Host "`tDistribution Point Group Selected: [$($DistributionOptionsSelected.Name)]"
		Write-Host "###########################################################" -ForegroundColor Cyan
	}
	catch
	{
		Write-Host "ERROR - DP Group Selection: $_" -ForegroundColor Red
		throw
	}
	
	#### Build Driver Packs for Each OS
	foreach ($OSInfo in $OSInfoSelected)
	{
		Write-Host "---------Building Driver Pack for: [$($OSInfo.OSName) $($OSInfo.OSVersion)]" -ForegroundColor Magenta
		
		# Driver Softpaqs
		try
		{
			Write-Host "############# Build HP Driver Package #############" -ForegroundColor Cyan
			# Get all SystemIDs From User Selected Model
			$DeviceDetails = Get-HPDeviceDetails -Name "$($DeviceSearchDetailsSelected.Name)" -Like -ErrorAction Stop
			
			# Build Driver Pack File to Dynamically named Variable
			New-Variable -Name "$($NewDriverPackOutput)_$($OSInfo.OSName -replace '\s', '')_$($OSInfo.OSVersion)" -Value (Build-HpDriverPack -HPDeviceDetails $DeviceDetails -OSInformation $OSInfo)

			Write-Host "`tSuccessfully Built Driver Pack" -ForegroundColor Green		
			Write-Host "###################################################" -ForegroundColor Cyan
		}
		catch
		{
			Write-Host "ERROR - Build Driver Pack: $_" -ForegroundColor Red
			throw
		}
		
		# Build New CM Package Information
		try
		{
			Write-Host "############# Build New Package Information #############" -ForegroundColor Cyan
			
			### Build Package Details (Check for existing stuff later)
			# Package Name
			$PackageName = "Drivers - $($DeviceSearchDetailsSelected.Name) - $($OSInfo.OSName) $($OSInfo.OSVersion) $($OSInfo.OSBitness)"
			
			# Package Version (Start by Assuming 1 First)
			$PackageVersion = '511.00 A 1'
			
			# Package Description
			$DeviceSystemIDs = $null
			foreach ($Device in $DeviceDetails)
			{
				if (!($DeviceSystemIDs))
				{
					$DeviceSystemIDs = $($Device.SystemID)
				}
				else
				{
					$DeviceSystemIDs = $DeviceSystemIDs + ",$($Device.SystemID)"
				}
			}
			$PackageDescription = "(Models included:$($DeviceSystemIDs.ToLower()))"
			
			# Package Manufacture
			$PackageManufacturer = "HP"
			
			# Package MIF Name (Remove the 'HP ' from the Name)
			$PackageMIFName = $($DeviceSearchDetailsSelected.Name.SubString(3))
			
			# Package MIF Version
			$PackageMIFVersion = "$($OSInfo.OSName) $($OSInfo.OSBitness)"
			
			# Package Source Path
			#$PackagePkgSourcePath = "\\SCVM2\SourcePackages\Drivers\Packages\$PackageManufacturer\$($DeviceSearchDetailsSelected.Name.SubString(3))\$($OSInfoSelected.OSName -Replace '\s', '')-$($OSInfoSelected.OSVersion)-$($OSInfoSelected.OSBitness)-$($PackageVersion)\StandardPkg"
			$PackagePkgSourcePath = "\\SCVM2\SourcePackages\Drivers\Packages\$PackageManufacturer\$($DeviceSearchDetailsSelected.Name.SubString(3))\$($OSInfo.OSName -Replace '\s', '')-$($OSInfo.OSVersion)-$($OSInfo.OSBitness)-$($PackageVersion)" + "\StandardPkg"
			
			Write-Host "Package Name       : $($PackageName)"
			Write-Host "Package Version    : $($PackageVersion)"
			Write-Host "Package Manufacture: $($PackageManufacturer)"
			Write-Host "Package Description: $($PackageDescription)"
			Write-Host "Package MIF Name   : $($PackageMIFName)"
			Write-Host "Package MIF Version: $($PackageMIFVersion)"
			Write-Host "Package Source Path: $($PackagePkgSourcePath)"
			
			Write-Host "#########################################################" -ForegroundColor Cyan
		}
		catch
		{
			Write-Host "ERROR - Build New CM Package: $_" -ForegroundColor Red
			throw
		}
		
		# Check for Exist CM Package
		try
		{
			Write-Host "############# Check Existing CM Package #############" -ForegroundColor Cyan
			
			# Connect to CM Site
			Connect-ConfigMgr
			
			Write-Host "Checking for Existing Package for Model and OS..."
			# Check for Package with Existing Name
			$ExistingPackage = Get-CMPackage -Fast -Name "$($PackageName)"
			
			if ($ExistingPackage)
			{
				# Select Package with Highest Version Number
				$VersionNumbers = @()
				foreach ($Package in $ExistingPackage)
				{
					$VersionNumber = [pscustomobject]@{ Version = "$([int]($Package.Version.Split()[-1]))"; PackageID = "$($Package.PackageID)" }
					$VersionNumbers += $VersionNumber
				}
				
				$ExistingPackage = $ExistingPackage | ? {
					$_.Version.Split()[-1] -eq (($VersionNumbers | Measure-Object -Property Version -Maximum).Maximum)
				}
				
				# Current Package Already Exists
				Write-Host "Exisiting Package Found" -ForegroundColor Yellow
				Write-Host "`tPackage Name       : $($ExistingPackage.Name)"
				Write-Host "`tPackage Version    : $($ExistingPackage.Version)"
				Write-Host "`tPackage Source Path: $($ExistingPackage.PkgSourcePath)"
				
				## Updating New Package Info
				Write-Host "Updated New Package Information" -ForegroundColor Yellow
				
				# Get Current Package Version and Increase by 1
				[int]$NewVersionNum = ($ExistingPackage.Version.Split()[-1])
				$NewVersionNum++
				$PackageVersion = "511.00 A " + $NewVersionNum
				
				# Update Package Source Path
				$PackagePkgSourcePath = "\\SCVM2\SourcePackages\Drivers\Packages\$PackageManufacturer\$($DeviceSearchDetailsSelected.Name.SubString(3))\$($OSInfo.OSName -Replace '\s', '')-$($OSInfo.OSVersion)-$($OSInfo.OSBitness)-$($PackageVersion)" + "\StandardPkg"
				
				Write-Host "`tPackage Name       : $($PackageName)"
				Write-Host "`tPackage Version    : $($PackageVersion)"
				Write-Host "`tPackage Source Path: $($PackagePkgSourcePath)"
				
				Write-Host "#####################################################" -ForegroundColor Cyan
			}
			else
			{
				Write-Host "No Existing Package Found, Use New Package Information"
			}
			
			# Disconnect from CM Site
			Disconnect-ConfigMgr
		}
		catch
		{
			Write-Host "ERROR - Check Existing CM Package: $_" -ForegroundColor Red
			throw
		}
		
		# Create New CM Package
		try
		{
			Write-Host "############# Create New Package in ConfigMgr #############" -ForegroundColor Cyan
			
			# Create Source Path for new Package
			# Check if Path Already Exists
			$PackagePkgSourcePathTest = Test-Path -Path $PackagePkgSourcePath
			if ($PackagePkgSourcePathTest)
			{
				# Remove Existing Path
				Write-Host "New Package Directory already Exists, Recursively Deleting it..." -ForegroundColor Yellow
				Remove-Item -Path $PackagePkgSourcePath -Recurse -Force
				Write-Host "`tSuccessfully deleted existing Directory" -ForegroundColor Green
			}
			
			Write-Host "Creating Package Directory.."
			$NewPkgSourcePath = New-Item -Path $($PackagePkgSourcePath) -ItemType Directory -Force
			if ($NewPkgSourcePath)
			{
				Write-Host "`tSuccessfully created Source Package Directory" -ForegroundColor Green
				
				# Move Driver Package File to Package Directory
				Write-Host "Moving Built Driver Pack to CM Package Source Directory..."
				Write-Host "Source: [$($script:DriverPackSavePath)\$((Get-Variable -Name "$($NewDriverPackOutput)_$($OSInfo.OSName -replace '\s', '')_$($OSInfo.OSVersion)").Value.Name)"
				Move-Item -Path "$($script:DriverPackSavePath)\$((Get-Variable -Name "$($NewDriverPackOutput)_$($OSInfo.OSName -replace '\s', '')_$($OSInfo.OSVersion)").Value.Name)" -Destination "$($PackagePkgSourcePath)\DriverPackage.Wim"
				Write-Host "`tSuccessfully Moved Driver Pack file" -ForegroundColor Green
				
				# Connect to ConfigMgr to Create Package
				Connect-ConfigMgr
				
				# Create Package
				Write-Host "Creating CM Package..."
				$NewPackage = New-CMPackage -Name $PackageName -Description $PackageDescription -Version $PackageVersion -Manufacturer $PackageManufacturer -PackageSourcePath $PackagePkgSourcePath
				Write-Host "`tSuccessfully created CM Package" -ForegroundColor Green
				
				# Set Mif Information
				Write-Host "Modifying CM Package MIF Information..."
				$NewPackage | Set-CMPackage -MifName $PackageMIFName -MifVersion $PackageMIFVersion -EnableBinaryDeltaReplication:$true
				Write-Host "`tSuccessfully Modified MIF Information" -ForegroundColor Green
				
				# Move Package to HP Folder
				Write-Host "Moving Package from Root Folder to HP Driver folder..."
				$NewPackage | Move-CMObject -FolderPath "$((Get-PSDrive -PSProvider CMSite).Name):\Package\Driver Packages\HP"
				Write-Host "`tSuccessfully Moved Package to HP Driver folder" -ForegroundColor Green
				
				# Distribute Package to selected DP Group
				Write-Host "Distributing Package to Distribution Point Group Selected: [$($DistributionOptionsSelected.Name)]"
				$NewPackage | Start-CMContentDistribution -DistributionPointGroupName $($DistributionOptionsSelected.Name)
				Write-Host "`tSuccessfully Started Package Distribution" -ForegroundColor Green
				
				# Disconnect from CM Site
				Disconnect-ConfigMgr
			}
			
			Write-Host "###########################################################" -ForegroundColor Cyan
		}
		catch
		{
			Write-Host "ERROR - Create New CM Package: $_" -ForegroundColor Red
			throw
		}
	}
}
catch
{
	Write-Host "ERROR - Main Loop: $_" -ForegroundColor Red
}

Disconnect-ConfigMgr