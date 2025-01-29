[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [System.String]
    $LenovoDocID = "ds563172",

    [Parameter(Mandatory = $false)]
    [System.String]
    $DestinationPath = "$PSScriptRoot"
)

# Get the Lenovo DocID file information
$LenovoDocIDFiles = & $PSScriptRoot\Resolve-LenovoDSDownloadUrl.ps1 -DocID $LenovoDocID

if ($LenovoDocIDFiles) {
    # Main Download Path
    $RootDownloadPath = Join-Path $DestinationPath "LenovoDrivers"
    if (-not (Test-Path $RootDownloadPath)) {
        New-Item -Path $RootDownloadPath -ItemType Directory | Out-Null
    }

    foreach ($LenovoDocIDFile in $LenovoDocIDFiles) {
        try {
            # Download Path
            $DownloadPath = Join-Path $RootDownloadPath "$($LenovoDocIDFile.FileName | Split-Path -LeafBase)"
            if (-not (Test-Path $DownloadPath)) {
                New-Item -Path $DownloadPath -ItemType Directory | Out-Null
            }
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Download Path: $($DownloadPath)"

            # Extraction Path
            $ExtractionPath = Join-Path $DownloadPath "Extracted"
            if (-not (Test-Path $ExtractionPath)) {
                New-Item -Path $ExtractionPath -ItemType Directory | Out-Null
            }
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extraction Path: $($ExtractionPath)"

            # Download the EXE file
            Invoke-WebRequest -Uri "$($LenovoDocIDFile.DownloadUrl)" -OutFile "$($DownloadPath)\$($LenovoDocIDFile.FileName)"
            Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Downloaded: $($LenovoDocIDFile.FileName)"
    
            if ($LenovoDocIDFile.FileType -eq 'EXE') {
                # Extract the Driver Pack
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extracting: [$($($LenovoDocIDFile.FileName))]"
                & $PSScriptRoot\Expand-LenovoDriverPack.ps1 -DriverPackPath "$($DownloadPath)\$($LenovoDocIDFile.FileName)" -ExtractPath "$($ExtractionPath)"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extracted to: [$($ExtractionPath)]"
            }
        }
        catch {
            <#Do this if a terminating exception happens#>
        }
    }
}