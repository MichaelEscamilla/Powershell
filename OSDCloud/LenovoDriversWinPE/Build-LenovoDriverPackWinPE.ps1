# Define Export Path
$CatalogExportPath = Join-Path $PSScriptRoot "Catalogs"

# Create Export Path if it does not exist
if (-not (Test-Path $CatalogExportPath)) {
    New-Item -Path $CatalogExportPath -ItemType Directory | Out-Null
}

# Export XML
Get-LenovoDriverPackWinPE | Export-Clixml -Path "$CatalogExportPath\LenovoDriverPackWinPE.xml" -Force

# Export JSON - Import the XML and convert it to JSON
Import-Clixml -Path "$CatalogExportPath\LenovoDriverPackWinPE.xml" | ConvertTo-Json | Out-File -FilePath "$CatalogExportPath\LenovoDriverPackWinPE.json" -Force