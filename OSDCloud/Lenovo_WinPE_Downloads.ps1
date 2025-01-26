function Get-LenovoDriverPackWinPE {
    param ()
    
    # Define Catalog URI
    $OnlineCatalogName = 'catalog.xml'
    $OnlineCatalogUri = 'https://download.lenovo.com/cdrt/td/catalog.xml'

    # Build Temp Directory
    $CatalogBuildFolder = Join-Path $env:TEMP 'LenovoDrivers'
    if (-not(Test-Path $CatalogBuildFolder)) {
        $null = New-Item -Path $CatalogBuildFolder -ItemType Directory -Force
    }
    # Define File Name for downloaded Catalog
    $RawCatalogFile = Join-Path $CatalogBuildFolder $OnlineCatalogName

    # Download Catalog
    try {
        $CatalogCloudRaw = Invoke-RestMethod -Uri $OnlineCatalogUri -UseBasicParsing
        Write-Host "Cloud Catalog $OnlineCatalogUri"
        Write-Host "Saving Cloud Catalog to $RawCatalogFile"
        $CatalogCloudContent = $CatalogCloudRaw
        $CatalogCloudContent | Out-File -FilePath $RawCatalogFile -Encoding utf8 -Force

        if (Test-Path $RawCatalogFile) {
            Write-Host "Catalog saved to $RawCatalogFile"
            $UseCatalog = 'Raw'
        }
        else {
            Write-Host "Catalog was NOT downloaded to $RawCatalogFile"
            Write-Warning 'Unable to complete'
            Break
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
    }

    Write-Host "Reading the Raw Catalog at $RawCatalogFile"
    [xml]$XmlCatalogContent = Get-Content -Path $RawCatalogFile -Raw

    $ProductList = $XmlCatalogContent.Products.Product

    $Results = foreach ($Product in $ProductList) {
        foreach ($Item in $Product.DriverPack) {
            if ($Item.id -like 'WinPE*') {
                if (($Item.InnerXml -notmatch 'no winpe') -and ($Item.InnerXml -notmatch 'Import')) {
                    # Covert Family
                    $Family = $null
                    switch ($Product.family) {
                        'tc' { $Family = 'ThinkCentre' }
                        'tp' { $Family = 'ThinkPad' }
                        'ts' { $Family = 'ThinkStation' }
                        Default { $Family = 'Unknown' }
                    }

                    # Convert OS Version
                    $OSVersion = $null
                    switch ($Product.os) {
                        'win11' { $OSVersion = 'Windows 11' }
                        'win10' { $OSVersion = 'Windows 10' }
                        'win81' { $OSVersion = 'Windows 8.1' }
                        'win732' { $OSVersion = 'Windows 7 x86' }
                        'win764' { $OSVersion = 'Windows 7 x64' }
                        Default { $OSVersion = 'Unknown' }
                    }

                    # Convert OS Build
                    $OSReleaseId = $Product.build
                    if ($OSReleaseId -eq '*') {
                        $OSReleaseId = $null
                    }
                    $OSBuild = $null
                    if ($OSReleaseId -eq '24H2') {
                        $OSBuild = '26100'
                    }
                    elseif ($OSReleaseId -eq '23H2') {
                        $OSBuild = '22631'
                    }
                    elseif ($OSReleaseId -eq '22H2') {
                        if ($Product.os -eq 'win10') {
                            $OSBuild = '19045'
                        }
                        if ($Product.os -eq 'win11') {
                            $OSBuild = '22621'
                        }
                    }
                    elseif ($OSReleaseId -eq '21H2') {
                        if ($Item.os -eq 'win10') {
                            $OSBuild = '19044'
                        }
                        if ($Item.os -eq 'win11') {
                            $OSBuild = '22000'
                        }
                    }
                    elseif ($OSReleaseId -eq '21H1') {
                        $OSBuild = '19043'
                    }
                    elseif ($OSReleaseId -eq '20H2') {
                        $OSBuild = '19042'
                    }
                    elseif ($OSReleaseId -eq '2004') {
                        $OSBuild = '19041'
                    }
                    elseif ($OSReleaseId -eq '1909') {
                        $OSBuild = '18363'
                    }
                    elseif ($OSReleaseId -eq '1903') {
                        $OSBuild = '18362'
                    }
                    elseif ($OSReleaseId -eq '1809') {
                        $OSBuild = '17763'
                    }
                    elseif ($OSReleaseId -eq '1803') {
                        $OSBuild = '17134'
                    }
                    elseif ($OSReleaseId -eq '1709') {
                        $OSBuild = '16299'
                    }
                    elseif ($OSReleaseId -eq '1703') {
                        $OSBuild = '15063'
                    }
                    elseif ($OSReleaseId -eq '1607') {
                        $OSBuild = '14393'
                    }
                    elseif ($OSReleaseId -eq '1511') {
                        $OSBuild = '10586'
                    }
                    elseif ($OSReleaseId -eq '1507') {
                        $OSBuild = '10240'
                    }

                    $ObjectProperties = [Ordered]@{
                        Manufacturer = 'Lenovo'
                        Name         = $Product.name
                        Model        = $Product.model
                        Family       = $Family
                        Product      = [array]$Product.Queries.Types.Type.split(',').Trim()
                        Component    = 'DriverPack'
                        ID           = $Item.id
                        FileName     = $Item.InnerXml | Split-Path -Leaf
                        Url          = $Item.InnerXml
                        OSVersion    = $OSVersion
                        OSReleaseId  = $OSReleaseId
                        OSBuild      = $OSBuild
                    }
                    New-Object -TypeName PSObject -Property $ObjectProperties
                }
            }
        }
    }

    Return $Results
}

function Resolve-LenovoDSDownloadUrl {
    param (
        [string]$DownloadUrl,

        [ValidateSet('.txt', '.exe')]
        [string]$DownloadFileType = '.exe'
    )

    # Build Headers to trick the website
    $Headers = $null
    $Headers = @{
        "authority"                 = "support.lenovo.com"
        "method"                    = "GET"
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

    # Get the DS* page information
    try {
        $Response = $null
        $Response = Invoke-WebRequest -UseBasicParsing -Uri "$($DownloadUrl)" -Headers $Headers
        $Response.RawContent | Out-File C:\Users\Eskim\Downloads\LenovoDriverPack.txt
    }
    catch {
        <#Do this if a terminating exception happens#>
    }

    # Loop through the RawContent - Split by New Line
    foreach ($Line in $($Response.RawContent -split "`n")) {
        if ($Line -match "window.customData \|\| {`"docId`"") {
            # Load the Line
            $CustomData = $Line
            # Get the Index of the pattern '{"docId"'
            $Index_DocId = $Line.IndexOf('{"docId"')
            # Remove the Leading Text
            $CustomData = $CustomData.Substring($Index_DocId)
            # Remove the Trailing Text
            $CustomData = $CustomData.Replace(";", "")
            # Convert the JSON to a PowerShell Object
            $CustomData = ConvertFrom-Json $CustomData
            
            $Results = foreach ($File in $CustomData.driver.body.DriverDetails.Files) {
                # Build a PSObject with the Download URL and Hash Info
                $ObjectProperties = [Ordered]@{
                    FileType    = $File.TypeString
                    DownloadUrl = $File.URL
                    Size        = $File.Size
                    SHA1        = $File.SHA1
                    SHA256      = $File.SHA256
                    MD5         = $File.MD5
                    Date        = $([System.DateTimeOffset]::FromUnixTimeMilliseconds($($File.Date.Unix)).DateTime)
                    Released    = $([System.DateTimeOffset]::FromUnixTimeMilliseconds($($File.Released.Unix)).DateTime)
                    OS          = $File.OperatingSystemKeys
                }
                New-Object -TypeName PSObject -Property $ObjectProperties
            }
            
            Return $Results
        }
    }

    <#
    # Loop through the RawContent - Split by New Line
    foreach ($Item in $($Response.RawContent -split "`n")) {
        # Check for the line with the download link
        if ($Item -match "https://download\.lenovo\.com.*\.exe") {
            # Get the Index of the pattern '.exe'
            $Index_FileType = $Item.IndexOf("$($DownloadFileType)")
            # Get the Last Index of the pattern 'https://download.lenovo.com' Starting from the Index of '.exe'
            $Index_DownloadLenovoCom = $Item.LastIndexOf("https://download.lenovo.com", $($Index_FileType))
            # Get the Download URL
            $Download_Url = $Item.Substring($Index_DownloadLenovoCom, ($Index_FileType + $($DownloadFileType.Length)) - ($Index_DownloadLenovoCom))
            
            Return $Download_Url
        }
    }
    #>
}

function Expand-LenovoDriverPack {
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
}

$Results = $null
#$Results = Get-LenovoDriverPack | Out-GridView -Title "Lenovo Driver Packs" -OutputMode Multiple
$Results = Get-LenovoDriverPackWinPE | Where-Object { $_.id -eq "WinPE 10" } | Select-Object -Unique Url # | Group-Object Url

# Loop through the results and download the files
$Count = $null
$Count = 1
foreach ($Result in $Results) {

    Write-Host -ForegroundColor Yellow "############################ = $($Count.ToString("D2"))"
    Write-Host -ForegroundColor DarkGray "DS Url: $($Result.Url)"
    
    # Resolve the download URL
    Resolve-LenovoDSDownloadUrl -DownloadUrl $Result.Url
    $DownloadUrl = Resolve-LenovoDSDownloadUrl -DownloadUrl $Result.Url -DownloadFileType '.exe'
    Write-Host -ForegroundColor DarkCyan "Downloading: $DownloadUrl"

    # Define Location
    $DownloadLocation = "$($env:TEMP)\LenovoDriverPack_Download"
    $DownloadFileName = $null
    $DownloadFileName = $DownloadUrl | Split-Path -Leaf
    $ExtractPath = $null
    $ExtractPath = "$($env:TEMP)\LenovoDriverPack_Extract\$($DownloadFileName | Split-Path -LeafBase)"

    # Create the download location if it doesn't exist
    if (-not (Test-Path $DownloadLocation)) {
        New-Item -Path $DownloadLocation -ItemType Directory -Force | Out-Null
    }

    # Create the extraction path if it doesn't exist
    if (-not (Test-Path $ExtractPath)) {
        New-Item -Path $ExtractPath -ItemType Directory -Force | Out-Null
    }

    # Download the EXE file
    try {
        Invoke-WebRequest -Uri "$($DownloadUrl)" -OutFile "$($DownloadLocation)\$($DownloadFileName)"
        Write-Host -ForegroundColor Green "Downloaded: $($DownloadFileName)"

        # Extract the Driver Pack
        Write-Host -ForegroundColor DarkGray "Extracting: [$($DownloadLocation)\$($DownloadFileName)]"
        Expand-LenovoDriverPack -DriverPackPath "$($DownloadLocation)\$($DownloadFileName)" -ExtractPath "$($ExtractPath)"
        Write-Host -ForegroundColor Green "Extracted to: [$($ExtractPath)]"

        # Download the TXT file
        $DownloadUrl = Resolve-LenovoDSDownloadUrl -DownloadUrl $Result.Url -DownloadFileType '.txt'
        Write-Host -ForegroundColor DarkCyan "Downloading: $DownloadUrl"
        try {
            Invoke-WebRequest -Uri "$($DownloadUrl)" -OutFile "$($ExtractPath)\$($DownloadFileName.Replace('.exe', '.txt'))"
            Write-Host -ForegroundColor Green "Downloaded: $($DownloadFileName.Replace('.exe', '.txt'))"
        }
        catch {
            Write-Host -ForegroundColor Red "Failed to download the TXT file: $DownloadUrl"
        }
    }
    catch {
        Write-Host -ForegroundColor Red "Failed to download the EXE file: $DownloadUrl"
    }

    $Count++
}