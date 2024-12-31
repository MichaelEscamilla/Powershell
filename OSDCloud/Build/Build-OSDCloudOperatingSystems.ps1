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
    @{ Version = 'Win1124H2'; LocalCab = "Win1124H2.Cab"; URL = "https://download.microsoft.com/download/6/2/b/62b47bc5-1b28-4bfa-9422-e7a098d326d4/products-Win11-20241004.cab" }
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
    Write-Verbose "Expanding $cab to $TargetFolder"

    # Create the Target Folder
    New-Item -Force $TargetFolder -ItemType Directory | Out-Null
    Write-Verbose "Created folder $result"

    
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
    # Download the CAB File to the Staging Folder
    Invoke-WebRequest -Uri $Option.URL -UseBasicParsing -OutFile "$StagingFolder\$($Option.LocalCab)" -ErrorAction SilentlyContinue -Verbose

    # Extract 'products.xml' from the CAB File
    Invoke-ExpandCAB -cab "$StagingFolder\$($Option.LocalCab)" -expectedFile "$StagingFolder\$($Option.LocalCab).dir\products.xml" -Verbose

    #[XML]$XML = Get-Content -Raw -Path "$StagingFolder\$($Option.LocalCab).dir\products.xml"
    #$ESDInfo += $XML.MCT.Catalogs.Catalog.PublishedMedia.Files.File
}