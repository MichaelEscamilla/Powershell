# Catalog File
$CatalogFilePath = Join-Path -Path "$($PSScriptRoot)\Catalogs" -ChildPath "LenovoDriverPackWinPEDocID.json"

# Import the LenovoDriverPackWinPEDocID.json
$CatalogFileData = Get-Content -Path "$CatalogFilePath" -Raw | ConvertFrom-Json

$Filtered = $null
$Filtered = foreach ($CatalogItem in $CatalogFileData) {
    foreach ($DSInfo in $CatalogItem.DSInfo) {
        if ($DSInfo.OS -like "Windows PE*") {
            if ((Get-Date $DSInfo.Released) -gt (Get-Date 2024.01.01)) {
                Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('HH:mm:ss'))] DocID: [$($CatalogItem.DocID)]"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Name: $($DSInfo.FileName)"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] OS: $($DSInfo.OS)"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Released: $($DSInfo.Released)"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Size: $($DSInfo.Size)"
                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] URL: $($DSInfo.DownloadUrl)"

                # Determine the Family based on the FileName
                $Family = $null
                switch ($DSInfo.FileName) {
                    {$_ -like "tc_*"} { $Family = 'ThinkCentre' }
                    {$_ -like "tp_*"} { $Family = 'ThinkPad' }
                    {$_ -like "ts_*"} { $Family = 'ThinkStation' }
                    Default { $Family = 'Unknown' }
                }

                Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Family: $($Family)"
                $CatalogItem
            }
        }
    }
}
$Filtered.Count