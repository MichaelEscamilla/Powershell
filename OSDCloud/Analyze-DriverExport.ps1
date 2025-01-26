# Import the CSV file located at F:\DriversExport.csv
$csvData = $null
$csvData = Import-Csv -Path "F:\DriversExport.csv"

$infExport = @()
# Loop through each row in the CSV file
foreach ($Driver in $csvData) {
    # Get the DeviceID from the CSV file and Extrace the 2nd part of the string
    $SearchString = $Driver.DeviceID -split "\\" | Select-Object -Index 1

    # Define the path to the driver source folder
    $DriverSourcePath = "C:\SWSetup\sp155535\src\Driver"

    # Search for .ini files that contains the SearchString
    $iniFile = $null
    $iniFile = Get-ChildItem -Path $DriverSourcePath -Filter *.inf -Recurse | Select-String -Pattern $SearchString | Select-Object -ExpandProperty Path -First 1

    if ($iniFile) {
        foreach ($inf in $iniFile) {
            $infExport += [PSCustomObject]@{
                Path       = $inf
                ParentFolder = (Split-Path -Parent $inf)
                #ParentFolder = Split-Path (Split-Path -Parent $inf) -Leaf
            }
        }
        Write-Output "SearchString: [$($SearchString)] - Found .inf file: $iniFile"

        # Fine all files in the parent folder of the ini with similar names
        $ParentFolder = Split-Path -Parent $iniFile
        Write-Host "ParentFolder: $ParentFolder"
        $ParentFolderFiles = Get-ChildItem -Path $ParentFolder -Filter "$(Split-Path $iniFile -LeafBase)*" -Recurse -File
        Write-Host "ParentFolderFiles: $(Split-Path $ParentFolderFiles -Leaf)"

    }
    else {
        Write-Output "No .ini file found for $SearchString"
    }
}

$infExport.ParentFolder | Select-Object -Unique | % {
    $_
    ($_ | Get-ChildItem | Measure-Object -Sum Length).Sum / 1MB }