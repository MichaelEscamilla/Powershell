# Define Export Path
$CatalogExportPath = Join-Path $PSScriptRoot "Catalogs"

# Create Export Path if it does not exist
if (-not (Test-Path $CatalogExportPath)) {
    New-Item -Path $CatalogExportPath -ItemType Directory | Out-Null
}

# Import txt file of DocIDs
$lines = Get-Content -Path "C:\Users\Eskim\Downloads\LenovoWinPE_DS.txt"

# Create Outer Object
$Results = New-Object -TypeName PSObject

$Counter = 0
# Loop through each line
$Results = foreach ($line in $lines) {
    
    # Resolve the DS
    $DSInfo = $null
    $DSInfo = & .\Resolve-LenovoDSDownloadUrl.ps1 -DocID $line

    # Inner Object
    $InnerResults = @{}
    $InnerResults = @{
        DocID  = "$($line)"
        DSInfo = $DSInfo
    }
    
    New-Object -TypeName PSObject -Property $InnerResults

    #$Counter++

    if ($Counter -eq 10) {
        break
    }
}

$Results | Export-Clixml -Path "$CatalogExportPath\LenovoDriverPackWinPEDocID.xml" -Depth 100 -Force

# Export JSON - Import the XML and convert it to JSON
Import-Clixml -Path "$CatalogExportPath\LenovoDriverPackWinPEDocID.xml" | ConvertTo-Json -Depth 100 | Out-File -FilePath "$CatalogExportPath\LenovoDriverPackWinPEDocID.json" -Force
