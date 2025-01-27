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
    }
    catch {
        throw "Unable to download the Lenovo Driver Pack from $DownloadUrl"
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
                    DocID       = $CustomData.docID
                    OS          = $File.OperatingSystemKeys
                    Name        = $File.Name
                    Released    = Get-Date $([System.DateTimeOffset]::FromUnixTimeMilliseconds($($File.Released.Unix)).DateTime) -Format "yyyy.MM.dd"
                    FileType    = $File.TypeString
                    DownloadUrl = $File.URL
                    Size        = $File.Size
                    SHA1        = $File.SHA1
                    SHA256      = $File.SHA256
                    MD5         = $File.MD5
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