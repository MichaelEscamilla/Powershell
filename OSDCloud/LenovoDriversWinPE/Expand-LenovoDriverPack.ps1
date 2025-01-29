param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ ([System.IO.Path]::GetExtension($_) -eq '.exe') })]
    [System.String]
    $DriverPackPath,

    [System.String]
    $ExtractPath = "$($env:TEMP)\LenovoDriverPack"
)

# Create the extraction path if it doesn't exist
if (-not (Test-Path $ExtractPath)) {
    New-Item -Path $ExtractPath -ItemType Directory -Force | Out-Null
}

try {
    # Expand the .exe file
    Start-Process -FilePath $DriverPackPath -ArgumentList "/EXTRACT=YES /VERYSILENT /Dir=`"$ExtractPath`"" -Wait
}
catch {
    Write-Host -ForegroundColor Red "Failed to extract the driver pack: $DriverPackPath"
}