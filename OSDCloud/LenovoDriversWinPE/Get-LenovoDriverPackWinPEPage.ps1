# Define URI
$LenovoWinPEPageFile = 'LenovoWinPEPage.txt'
$LenovoWinPEPage = 'https://support.lenovo.com/us/en/solutions/ht074984-microsoft-system-center-configuration-manager-sccm-and-microsoft-deployment-toolkit-mdt-package-index'

# Build Temp Directory
$CatalogBuildFolder = Join-Path "$env:USERPROFILE\Downloads" 'LenovoDrivers'
if (-not(Test-Path $CatalogBuildFolder)) {
    $null = New-Item -Path $CatalogBuildFolder -ItemType Directory -Force
}
# Define File Name for downloaded Catalog
$RawCatalogFile = Join-Path $CatalogBuildFolder $LenovoWinPEPageFile

# Download Catalog
try {
    $session = $null
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/132.0.0.0"
    
    $Headers = $null
    $Headers = @{
        "authority"                 = "support.lenovo.com"
        "method"                    = "GET"
        "path"                      = "/us/en/solutions/ht074984-microsoft-system-center-configuration-manager-sccm-and-microsoft-deployment-toolkit-mdt-package-index"
        "scheme"                    = "https"
        "accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
        "accept-encoding"           = "gzip, deflate, br, zstd"
        "accept-language"           = "en-US,en;q=0.9"
        "cache-control"             = "max-age=0"
        "priority"                  = "u=0, i"
        "sec-ch-ua"                 = "`"Not A(Brand`";v=`"8`", `"Chromium`";v=`"132`", `"Microsoft Edge`";v=`"132`""
        "sec-ch-ua-mobile"          = "?0"
        "sec-ch-ua-platform"        = "`"Windows`""
        "sec-fetch-dest"            = "document"
        "sec-fetch-mode"            = "navigate"
        "sec-fetch-site"            = "none"
        "sec-fetch-user"            = "?1"
        "upgrade-insecure-requests" = "1"
    }
    $LenovoWinPEPage = Invoke-WebRequest -UseBasicParsing -Uri $LenovoWinPEPage -Headers $Headers -WebSession $session -OutFile $RawCatalogFile  #-UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)
    $LenovoWinPEPage
    #$LenovoWinPEPage.AllElements | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force
}
catch {
    <#Do this if a terminating exception happens#>
}
