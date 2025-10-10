<#

Get ESD 

#>

# Setup a Folder for Staging Files
$StagingFolder = "$env:TEMP\OSDStaging"

# Create the Staging Folder if it doesn't exist
if (!(Test-Path -Path $StagingFolder)) {
    New-Item -Path $StagingFolder -ItemType Directory | Out-Null
}

# Manifests for Windows 10 and Windows 11
$WindowsTable = @(
    @{ Version = 'Win1022H2'; LocalCab = "Win1022H2.Cab"; URL = "https://download.microsoft.com/download/7/9/c/79cbc22a-0eea-4a0d-89c0-054a1b3aa8e0/products.cab" }
    @{ Version = 'Win1121H2'; LocalCab = "Win1121H2.Cab"; URL = "https://download.microsoft.com/download/1/b/4/1b4e06e2-767a-4c9a-9899-230fe94ba530/products_Win11_20211115.cab" }
    @{ Version = 'Win1122H2'; LocalCab = "Win1122H2.Cab"; URL = "https://download.microsoft.com/download/b/1/9/b19bd7fd-78c4-4f88-8c40-3e52aee143c2/products_win11_20230510.cab.cab" }
    @{ Version = 'Win1123H2'; LocalCab = "Win1123H2.Cab"; URL = "https://download.microsoft.com/download/6/2/b/62b47bc5-1b28-4bfa-9422-e7a098d326d4/products_win11_20231208.cab" }
    #@{ Version = 'Win1124H2'; LocalCab = "Win1124H2.Cab"; URL = "https://download.microsoft.com/download/6/2/b/62b47bc5-1b28-4bfa-9422-e7a098d326d4/products-Win11-20241004.cab" }
    @{ Version = 'Win1124H2'; LocalCab = "Win1124H2.Cab"; URL = "https://download.microsoft.com/download/8e0c23e7-ddc2-45c4-b7e1-85a808b408ee/Products-Win11-24H2-6B.cab" }
    @{ Version = 'Win1125H2'; LocalCab = "Win1125H2.Cab"; URL = ""; FilePath = "C:\Users\Eskim\_Github\MichaelEscamilla\Powershell\OSDCloud\Build\Win1125H2.cab" }
)

######## Functions ########
#Region Functions
function Invoke-ExpandCAB {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Cab,
        [Parameter(Mandatory = $true)]
        [string]$expectedFile
    )

    Write-Verbose "Expanding CAB File: [$Cab]"

    # Define an Extraction Target Folder
    $TargetFolder = "$Cab.dir"

    # Check if the Target Folder Already Exists
    if (Test-Path -Path $TargetFolder) {
        # Remove the Target Folder
        Remove-Item -Path $TargetFolder -Recurse -Force
        Write-Verbose "Removed folder: [$TargetFolder]"
    }
    Write-Verbose "Expanding [$Cab] to [$TargetFolder]"

    # Create the Target Folder
    New-Item -Force $TargetFolder -ItemType Directory | Out-Null
    Write-Verbose "Created folder: [$TargetFolder]"

    
    $Shell = New-Object -ComObject Shell.Application
    $Exception = $null
    try {
        if ($Shell) {
            $SourceCab = $Shell.NameSpace($Cab).Items()
            $DestinationFolder = $Shell.NameSpace($TargetFolder)
            $DestinationFolder.CopyHere($SourceCab)
            Write-Verbose "Extracted CAB File: [$Cab] to [$TargetFolder]"
        }
        else {
            throw "Failed to create Shell.Application COM object."
        }
    }
    catch {
        $Exception = $_.Exception
    }
    finally {
        # Release the Shell COM Object
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shell) | Out-Null
        # This line forces a garbage collection to occur, which attempts to reclaim memory occupied by unreachable objects.
        [System.GC]::Collect()
        # This line forces the garbage collector to wait for all pending finalizers to complete before continuing.
        [System.GC]::WaitForPendingFinalizers()
    }

    # Check if an Error Occurred
    if ($Exception) {
        throw "Failed to decompress $Cab. $($Exception.Message)."
    }

    # Check if the Expected File Exists
    if (!(Test-Path -Path $expectedFile)) {
        throw "Failed to extract the expected file: [$expectedFile]"
    }

    Return $expectedFile
}
#EndRegion
###########################

# Define a Table to Store the ESD Information
$ESDInfo = @()

# Download the CAB Files and Extract the ESD Information
ForEach ($Option in $WindowsTable) {
    # Check if URL is empty and copy FilePath to Staging Folder
    if ($Option.URL -eq "") {
        Copy-Item -Path $Option.FilePath -Destination "$StagingFolder\$($Option.LocalCab)" -Force
        Write-Verbose "Copied CAB File from [$($Option.FilePath)] to [$StagingFolder\$($Option.LocalCab)]"
    }
    else {
        # Download the CAB File to the Staging Folder
        Invoke-WebRequest -Uri $Option.URL -UseBasicParsing -OutFile "$StagingFolder\$($Option.LocalCab)" -ErrorAction SilentlyContinue -Verbose
    }

    # Extract 'products.xml' from the CAB File
    $File = Invoke-ExpandCAB -cab "$StagingFolder\$($Option.LocalCab)" -expectedFile "$StagingFolder\$($Option.LocalCab).dir\products.xml" -Verbose

    # Load the XML File
    [XML]$XML = Get-Content -Raw -Path "$StagingFolder\$($Option.LocalCab).dir\products.xml"

    # Add the ESD Information to the Table
    $ESDInfo += $XML.MCT.Catalogs.Catalog.PublishedMedia.Files.File
}

# Remove Duplicates (Based on FileName) - Strips out most of the editions already
$UniqueESDInfo = $ESDInfo | Group-Object -Property FileName | ForEach-Object { $_.Group | Select-Object -First 1 }

# x64 ESDs
$x64ESDInfo = $UniqueESDInfo | Where-Object { $_.Architecture -eq "x64" }
# Only include the following Editions if they exist
$x64ESDInfo = $x64ESDInfo | Where-Object {
    $_.Edition -eq "Professional" -or
    $_.Edition -eq "Education" -or
    $_.Edition -eq "Enterprise" -or
    $_.Edition -eq "Professional" -or
    $_.Edition -eq "HomePremium"
}

# ARM ESDs
$ARM64ESDInfo = $UniqueESDInfo | Where-Object { $_.Architecture -eq "ARM64" }
# Only include the following Editions if they exist
$ARM64ESDInfo = $ARM64ESDInfo | Where-Object {
    $_.Edition -eq "Professional" -or
    $_.Edition -eq "Education" -or
    $_.Edition -eq "Enterprise" -or
    $_.Edition -eq "Professional" -or
    $_.Edition -eq "HomePremium"
}

#=================================================
#   Media Creation Tool - x64
#=================================================
$Results = $x64ESDInfo
$Results = $Results | Select-Object @(
    @{Name = 'Status'; Expression = { ($null) } }
    @{Name = 'ReleaseDate'; Expression = { ($null) } }
    @{Name = 'Name'; Expression = { ($_.Title) } }
    @{Name = 'Version'; Expression = { ($null) } }
    @{Name = 'ReleaseID'; Expression = { ($_.null) } }
    @{Name = 'Architecture'; Expression = { ($_.Architecture) } }
    @{Name = 'Language'; Expression = { ($_.LanguageCode) } }
    @{Name = 'Activation'; Expression = { ($null) } }
    @{Name = 'Build'; Expression = { ($null) } }
    @{Name = 'FileName'; Expression = { ($_.FileName) } }
    @{Name = 'ImageIndex'; Expression = { ($null) } }
    @{Name = 'ImageName'; Expression = { ($null) } }
    @{Name = 'Url'; Expression = { ($_.FilePath) } }
    @{Name = 'SHA1'; Expression = { ($_.Sha1) } }
    @{Name = 'UpdateID'; Expression = { ($_.UpdateID) } }
    @{Name = 'Win10'; Expression = { ($null) } }
    @{Name = 'Win11'; Expression = { ($null) } }
)

foreach ($Result in $Results) {
    #=================================================
    #   Activation
    #   URL (Or Filename?) will contain 'Business' for Volume
    #=================================================
    if ($Result.Url -match 'Business') {
        $Result.Activation = 'Volume'
    }
    else {
        $Result.Activation = 'Retail'
    }

    #=================================================
    #   Build
    #   Extract the Build Number from the FileName
    #=================================================
    # Match all numbers separated by a period
    $Regex = "[0-9]*\.[0-9]+"
    # Take the first match found
    $Result.Build = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value

    #=================================================
    #   OS Version
    #=================================================
    if ($Result.Build -lt 22000) {
        $Result.Version = 'Windows 10'
        $Result.Win10 = $true
        $Result.Win11 = $false
    }
    if ($Result.Build -ge 22000) {
        $Result.Version = 'Windows 11'
        $Result.Win10 = $false
        $Result.Win11 = $true
    }

    #=================================================
    #   ReleaseID
    #=================================================
    if ($Result.Build -match "19045") { $Result.ReleaseID = "22H2" }
    if ($Result.Build -match "22000") { $Result.ReleaseID = "21H2" }
    if ($Result.Build -match "22621") { $Result.ReleaseID = "22H2" }
    if ($Result.Build -match "22631") { $Result.ReleaseID = "23H2" }
    if ($Result.Build -match "26100") { $Result.ReleaseID = "24H2" }
    if ($Result.Build -match "26200") { $Result.ReleaseID = "25H2" }

    #=================================================
    #   Date
    #   Extract the Release Date from the FileName
    #=================================================
    # Data is the set of numbers after the second period and before the hyphen
    $DateString = (($Result.FileName).Split(".")[2]).Split("-")[0]
    # Convert the Date String to a Date Object
    $Date = [datetime]::ParseExact($DateString, 'yyMMdd', $null)
    # Reformat
    $Result.ReleaseDate = (Get-Date $Date -Format "yyyy-MM-dd")

    #=================================================
    #   Name 
    #=================================================
    $Result.Name = $Result.Version + ' ' + $Result.ReleaseID + ' x64 ' + $Result.Language + ' ' + $Result.Activation + ' ' + $Result.Build
}

$ResultsMCTx64 = $Results | Sort-Object -Property Name

#=================================================
#   Media Creation Tool - ARM64
#=================================================
$ARMResults = $ARM64ESDInfo
$ARMResults = $ARMResults | Select-Object @(
    @{Name = 'Status'; Expression = { ($null) } }
    @{Name = 'ReleaseDate'; Expression = { ($null) } }
    @{Name = 'Name'; Expression = { ($_.Title) } }
    @{Name = 'Version'; Expression = { ($null) } }
    @{Name = 'ReleaseID'; Expression = { ($_.null) } }
    @{Name = 'Architecture'; Expression = { ($_.Architecture) } }
    @{Name = 'Language'; Expression = { ($_.LanguageCode) } }
    @{Name = 'Activation'; Expression = { ($null) } }
    @{Name = 'Build'; Expression = { ($null) } }
    @{Name = 'FileName'; Expression = { ($_.FileName) } }
    @{Name = 'ImageIndex'; Expression = { ($null) } }
    @{Name = 'ImageName'; Expression = { ($null) } }
    @{Name = 'Url'; Expression = { ($_.FilePath) } }
    @{Name = 'SHA1'; Expression = { ($_.Sha1) } }
    @{Name = 'UpdateID'; Expression = { ($_.UpdateID) } }
    @{Name = 'Win10'; Expression = { ($null) } }
    @{Name = 'Win11'; Expression = { ($null) } }
)

foreach ($Result in $ARMResults) {
    #=================================================
    #   Activation
    #   URL (Or Filename?) will contain 'Business' for Volume
    #=================================================
    if ($Result.Url -match 'Business') {
        $Result.Activation = 'Volume'
    }
    else {
        $Result.Activation = 'Retail'
    }

    #=================================================
    #   Build
    #   Extract the Build Number from the FileName
    #=================================================
    # Match all numbers separated by a period
    $Regex = "[0-9]*\.[0-9]+"
    # Take the first match found
    $Result.Build = ($Result.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value

    #=================================================
    #   OS Version
    #=================================================
    if ($Result.Build -lt 22000) {
        $Result.Version = 'Windows 10'
        $Result.Win10 = $true
        $Result.Win11 = $false
    }
    if ($Result.Build -ge 22000) {
        $Result.Version = 'Windows 11'
        $Result.Win10 = $false
        $Result.Win11 = $true
    }

    #=================================================
    #   ReleaseID
    #=================================================
    if ($Result.Build -match "19045") { $Result.ReleaseID = "22H2" }
    if ($Result.Build -match "22000") { $Result.ReleaseID = "21H2" }
    if ($Result.Build -match "22621") { $Result.ReleaseID = "22H2" }
    if ($Result.Build -match "22631") { $Result.ReleaseID = "23H2" }
    if ($Result.Build -match "26100") { $Result.ReleaseID = "24H2" }
    if ($Result.Build -match "26200") { $Result.ReleaseID = "25H2" }

    #=================================================
    #   Date
    #   Extract the Release Date from the FileName
    #=================================================
    # Data is the set of numbers after the second period and before the hyphen
    $DateString = (($Result.FileName).Split(".")[2]).Split("-")[0]
    # Convert the Date String to a Date Object
    $Date = [datetime]::ParseExact($DateString, 'yyMMdd', $null)
    # Reformat
    $Result.ReleaseDate = (Get-Date $Date -Format "yyyy-MM-dd")

    #=================================================
    #   Name 
    #=================================================
    $Result.Name = $Result.Version + ' ' + $Result.ReleaseID + ' ARM64 ' + $Result.Language + ' ' + $Result.Activation + ' ' + $Result.Build
}

$ResultsMCTARM = $ARMResults | Sort-Object -Property Name

#=================================================
#   LEGACY FeatureUpdates x64 - Windows 10 21H2 and Under
#=================================================
$WSUSResults = Get-WSUSXML -Catalog FeatureUpdate -Silent
$WSUSResults = $WSUSResults | Where-Object { $_.UpdateArch -eq 'x64' }
$WSUSResults = $WSUSResults | Select-Object @(
    @{Name = 'Status'; Expression = { ($_.OSDStatus) } }
    @{Name = 'ReleaseDate'; Expression = { (Get-Date $_.CreationDate -Format "yyyy-MM-dd") } }
    @{Name = 'Name'; Expression = { ($_.Title) } }
    @{Name = 'Version'; Expression = { ($_.UpdateOS) } }
    @{Name = 'ReleaseID'; Expression = { ($_.UpdateBuild) } }
    @{Name = 'Architecture'; Expression = { ($_.UpdateArch) } }
    @{Name = 'Language'; Expression = { ($null) } }
    @{Name = 'Activation'; Expression = { ($null) } }
    @{Name = 'Build'; Expression = { ($null) } }
    @{Name = 'FileName'; Expression = { ((Split-Path -Leaf $_.FileUri)) } }
    @{Name = 'ImageIndex'; Expression = { ($null) } }
    @{Name = 'ImageName'; Expression = { ($null) } }
    @{Name = 'Url'; Expression = { ($_.FileUri) } }
    @{Name = 'SHA1'; Expression = { ($null) } }
    @{Name = 'UpdateID'; Expression = { ($_.UpdateID) } }
    @{Name = 'Win10'; Expression = { ($null) } }
    @{Name = 'Win11'; Expression = { ($null) } }
)

foreach ($WSUSResult in $WSUSResults) {
    #=================================================
    #   Language
    #=================================================
    if ($WSUSResult.FileName -match 'sr-latn-rs') {
        $WSUSResult.Language = 'sr-latn-rs'
    }
    else {
        $Regex = "[a-zA-Z]+-[a-zA-Z]+"
        $WSUSResult.Language = ($WSUSResult.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value
    }

    #=================================================
    #   Activation
    #   URL (Or Filename?) will contain 'Business' for Volume
    #=================================================
    if ($WSUSResult.Url -match 'Business') {
        $WSUSResult.Activation = 'Volume'
    }
    else {
        $WSUSResult.Activation = 'Retail'
    }

    #=================================================
    #   Support Win11 22H2 GA ESD
    #=================================================
    if (($WSUSResult.Version -match 'Windows 11') -and ($WSUSResult.ReleaseID -eq '22H2')) {
        $WSUSResult.ReleaseID = '22H2-GA'
    }

    #=================================================
    #   Version
    #=================================================
    if ($WSUSResult.Name -match 'Windows 10') {
        $WSUSResult.Version = 'Windows 10'
        $WSUSResult.Win10 = $true
        $WSUSResult.Win11 = $false
    }
    if ($WSUSResult.Name -match 'Windows 11') {
        $WSUSResult.Version = 'Windows 11'
        $WSUSResult.Win10 = $false
        $WSUSResult.Win11 = $true
    }

    #=================================================
    #   Build
    #   Extract the Build Number from the FileName
    #=================================================
    $Regex = "[0-9]*\.[0-9]+"
    $WSUSResult.Build = ($WSUSResult.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value

    #=================================================
    #   SHA1
    #=================================================
    $Regex = "[0-9a-f]{40}"
    $WSUSResult.SHA1 = ($WSUSResult.FileName | Select-String -AllMatches -Pattern $Regex).Matches[0].Value

    #=================================================
    #   Name
    #=================================================
    $WSUSResult.Name = $WSUSResult.Version + ' ' + $WSUSResult.ReleaseID + ' x64 ' + $WSUSResult.Language + ' ' + $WSUSResult.Activation + ' ' + $WSUSResult.Build
}

$ResultsWSUS = $WSUSResults | Where-Object {
    $_.Version -eq "Windows 10" -and
    ($_.ReleaseID -eq "21H2" -or
    $_.ReleaseID -eq "20H2" -or
    $_.ReleaseID -eq "2004" -or
    $_.ReleaseID -eq "1909")
} | Sort-Object -Property Name

#=================================================
#   Export the Catalog Files
#=================================================

$CatalogExportPath = Join-Path "$((Get-Module -Name OSD -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase))" "Catalogs"
Write-Host "Catalog Export Path: [$CatalogExportPath]"

$CatalogExportPath = "$StagingFolder"

# x64 Catalog File
$ResultsTotal += $ResultsMCTx64
$ResultsTotal += $ResultsWSUS
# Export XML
$ResultsTotal | Export-Clixml -Path "$CatalogExportPath\CloudOperatingSystems.xml" -Force
# Export JSON - Import the previously created XML file, convert it to JSON, and save the file
Import-Clixml -Path "$CatalogExportPath\CloudOperatingSystems.xml" | ConvertTo-Json | Out-File -FilePath "$CatalogExportPath\CloudOperatingSystems.json" -Encoding ascii -Width 2000 -Force

# ARM Catalog File
# Export XML
$ResultsMCTARM | Export-Clixml -Path "$CatalogExportPath\CloudOperatingSystemsARM64.xml" -Force
# Export JSON - Import the previously created XML file, convert it to JSON, and save the file
Import-Clixml -Path "$CatalogExportPath\CloudOperatingSystemsARM64.xml" | ConvertTo-Json | Out-File -FilePath "$CatalogExportPath\CloudOperatingSystemsARM64.json" -Encoding ascii -Width 2000 -Force

# Clear All Variables
$Results = $null
$ResultsMCTx64 = $null
$ResultsMCTARM = $null
$ResultsWSUS = $null
$ResultsTotal = $null
$ResultsMCTARM = $null