[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [PSCustomObject]
    $DSInfo,

    [Parameter(Mandatory = $true)]
    [ValidateSet('ThinkPad', 'ThinkStation', 'ThinkCentre')]
    [System.String]
    $Family,

    [Parameter(Mandatory = $false)]
    [System.String]
    $DestinationPath = "$PSScriptRoot",

    [Parameter(Mandatory = $false)]
    [System.String]
    $RepoPath
)

<##>
if ($RepoPath) {
    # Move to the Repo Path
    Push-Location -Path $RepoPath

    # Create a new Git Branch
    git checkout -b "$($DSInfo.DocID.ToUpper())"

    # Move back to the original path
    Pop-Location
}


# Main Download Path
$RootDownloadPath = Join-Path $DestinationPath "Lenovo-$($Family)"
if (-not (Test-Path $RootDownloadPath)) {
    New-Item -Path $RootDownloadPath -ItemType Directory | Out-Null
}

try {
    # Download Path
    $DownloadPath = Join-Path $RootDownloadPath "$($DSInfo.DocID.ToUpper())"
    if (-not (Test-Path $DownloadPath)) {
        New-Item -Path $DownloadPath -ItemType Directory | Out-Null
    }
    Start-Transcript -Path "$($DownloadPath)\$((Get-Date).ToString('yyyy-MM-dd'))-Build.log" -Append
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Download Path: $($DownloadPath)"

    # Extraction Path
    $ExtractionPath = Join-Path $DownloadPath "Drivers"
    if (-not (Test-Path $ExtractionPath)) {
        New-Item -Path $ExtractionPath -ItemType Directory | Out-Null
    }
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extraction Path: $($ExtractionPath)"

    # Download the EXE file
    Invoke-WebRequest -Uri "$($DSInfo.DownloadUrl)" -OutFile "$($DownloadPath)\$($DSInfo.FileName)"
    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Downloaded: $($DSInfo.FileName)"
    
    if ($DSInfo.FileType -eq 'EXE') {
        # Extract the Driver Pack
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extracting: [$($($DSInfo.FileName))]"
        & $PSScriptRoot\Expand-LenovoDriverPack.ps1 -DriverPackPath "$($DownloadPath)\$($DSInfo.FileName)" -ExtractPath "$($ExtractionPath)"
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extracted to: [$($ExtractionPath)]"

        # Delete the EXE file
        Remove-Item -Path "$($DownloadPath)\$($DSInfo.FileName)" -Force
        Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Deleted: $($DSInfo.FileName)"
    }
}
catch {
}

Stop-Transcript
#>