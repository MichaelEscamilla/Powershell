[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [System.String]
    $LenovoDocID,

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

# Get the Lenovo DocID file information
$LenovoDocIDFiles = & $PSScriptRoot\Resolve-LenovoDSDownloadUrl.ps1 -DocID $LenovoDocID

if ($LenovoDocIDFiles) {
    # Filter for WinPE Drivers
    $LenovoDocIDFiles = $LenovoDocIDFiles | Where-Object { $_.OS -match "Windows PE" }

    # Check if any files were found
    if ($LenovoDocIDFiles) {
        if ($RepoPath) {
            # Move to the Repo Path
            Push-Location -Path $RepoPath

            # Create a new Git Branch
            git checkout -b "$($LenovoDocID.ToUpper())_$($LenovoDocIDFileS.FileName | Select-Object -First 1 | Split-Path -LeafBase)"

            # Move back to the original path
            Pop-Location
        }


        # Main Download Path
        $RootDownloadPath = Join-Path $DestinationPath "Lenovo-$($Family)"
        if (-not (Test-Path $RootDownloadPath)) {
            New-Item -Path $RootDownloadPath -ItemType Directory | Out-Null
        }

        foreach ($LenovoDocIDFile in $LenovoDocIDFiles) {
            try {
                # Download Path
                $DownloadPath = Join-Path $RootDownloadPath "$($LenovoDocID.ToUpper())_$($LenovoDocIDFile.FileName | Split-Path -LeafBase)"
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
                Invoke-WebRequest -Uri "$($LenovoDocIDFile.DownloadUrl)" -OutFile "$($DownloadPath)\$($LenovoDocIDFile.FileName)"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Downloaded: $($LenovoDocIDFile.FileName)"
    
                if ($LenovoDocIDFile.FileType -eq 'EXE') {
                    # Extract the Driver Pack
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extracting: [$($($LenovoDocIDFile.FileName))]"
                    & $PSScriptRoot\Expand-LenovoDriverPack.ps1 -DriverPackPath "$($DownloadPath)\$($LenovoDocIDFile.FileName)" -ExtractPath "$($ExtractionPath)"
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Extracted to: [$($ExtractionPath)]"

                    # Delete the EXE file
                    Remove-Item -Path "$($DownloadPath)\$($LenovoDocIDFile.FileName)" -Force
                    Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Deleted: $($LenovoDocIDFile.FileName)"
                }
            }
            catch {
                <#Do this if a terminating exception happens#>
            }
        }
        Stop-Transcript
    }
    else {
        Write-Host -ForegroundColor Red "[$((Get-Date).ToString('HH:mm:ss'))] No WinPE Drivers found for Lenovo DocID: $LenovoDocID"
    }
}