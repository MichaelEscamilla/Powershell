[CmdletBinding()]
param (
    [System.String]
    $DownloadUrl,

    [System.String]
    $DocID
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
    if ($DownloadUrl) {
        $Response = Invoke-WebRequest -UseBasicParsing -Uri "$($DownloadUrl)" -Headers $Headers
    }
    elseif ($DocID) {
        $Response = Invoke-WebRequest -UseBasicParsing -Uri "https://support.lenovo.com/downloads/$($DocID)" -Headers $Headers
    }
}
catch {
    throw "Unable to download the Lenovo Driver Pack from $DownloadUrl"
}
#$Response.Content | Out-File -FilePath "$PSScriptRoot\response.txt" -Force
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

        # Get the Supported Models
        $SupportedModels = foreach ($Template in $CustomData.driver.body.DriverDetails.Templates) {
            if ($Template.Label -eq "product") {
                # Get the Template Body
                $TemplateBody = $Template.body

                # Convert the Body to Objects
                $BodyObjects = [regex]::Matches($TemplateBody, '<li>(.*?)<\/li>')
                foreach ($Match in $BodyObjects) {
                    $Objects = [Ordered]@{
                        # Convert HTML Special Characters
                        SupportedModels = [System.Web.HttpUtility]::HtmlDecode($Match.Groups[1].Value)
                    }
                    New-Object -TypeName PSObject -Property $Objects
                }
            }
        }
        
        # Build a PSObject with the Download URL and Hash Info
        $Results = foreach ($File in $CustomData.driver.body.DriverDetails.Files) {
            # Build a PSObject with the Download URL and Hash Info
            $ObjectProperties = [Ordered]@{
                DocID           = $CustomData.docID
                OS              = $File.OperatingSystemKeys
                Name            = $File.Name
                FileName        = $File.URL | Split-Path -Leaf
                Released        = Get-Date $([System.DateTimeOffset]::FromUnixTimeMilliseconds($($File.Released.Unix)).DateTime) -Format "yyyy.MM.dd"
                SupportedModels = $SupportedModels.SupportedModels
                FileType        = $File.TypeString
                DownloadUrl     = $File.URL
                Size            = $File.Size
                SHA1            = $File.SHA1
                SHA256          = $File.SHA256
                MD5             = $File.MD5
            }
            New-Object -TypeName PSObject -Property $ObjectProperties
        }
            
        Return $Results
    }
}
