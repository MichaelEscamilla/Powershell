# Load the AngleSharp library
Add-Type -Path 'C:\Program Files\PackageManagement\NuGet\Packages\AngleSharp.1.2.0\lib\net8.0\AngleSharp.dll'

# Fetch the HTML content
$Content = Get-Content C:\Users\Eskim\Downloads\Lenovo_WinPE_Drivers.html -Raw

# Build the parser
$Parser = New-Object AngleSharp.Html.Parser.HtmlParser

# Parse the content
$Parsed = $Parser.ParseDocument($Content)

# Build the 'ThinkPad' object
$ThinkPad_Rows = (($Parsed.All | Where-Object { $_.TagName -eq 'h4' -and $_.InnerHtml -eq "ThinkPad"}).NextElementSibling | Select-Object -Property * -ExcludeProperty InnerHtml, OuterHtml, TextContent).AllRows
# Loop through the rows and build a custom object
$Count = 0
$ThinkPad_DocIDs = foreach ($Row in $ThinkPad_Rows) {
    # Sub-series
    $SubSeries = $null
    $SubSeries = $Row.Cells[0].InnerHtml

    # WinPE 3.1
    #$WinPE31 = $Row.Cells[1].Children.Attributes["href"].Value
    $WinPE31 = $null
    $WinPE31 = $Row.Cells[1].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # WinPE 5
    $WinPE5 = $null
    $WinPE5 = $Row.Cells[2].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # WinPE 10/11
    $WinPE1011 = $Row.Cells[3].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # Build Object
    [PSCustomObject]@{
        SubSeries = $SubSeries
        WinPE31 = $WinPE31
        WinPE5 = $WinPE5
        WinPE1011 = $WinPE1011
    }

    $Count++
    #if ($Count -gt 3) { Break }
}

# Build the 'ThinkStation' object
$ThinkStation_Rows = (($Parsed.All | Where-Object { $_.TagName -eq 'h4' -and $_.InnerHtml -eq "ThinkStation"}).NextElementSibling | Select-Object -Property * -ExcludeProperty InnerHtml, OuterHtml, TextContent).AllRows
# Loop through the rows and build a custom object
$ThinkStation_DocIDs = foreach ($Row in $ThinkStation_Rows) {
    # Sub-series
    $SubSeries = $null
    $SubSeries = $Row.Cells[0].InnerHtml

    # WinPE 3.1
    #$WinPE31 = $Row.Cells[1].Children.Attributes["href"].Value
    $WinPE31 = $null
    $WinPE31 = $Row.Cells[1].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # WinPE 5
    $WinPE5 = $null
    $WinPE5 = $Row.Cells[2].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # WinPE 10/11
    $WinPE1011 = $Row.Cells[3].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # Build Object
    [PSCustomObject]@{
        SubSeries = $SubSeries
        WinPE31 = $WinPE31
        WinPE5 = $WinPE5
        WinPE1011 = $WinPE1011
    }

    $Count++
    #if ($Count -gt 3) { Break }
}

# Build the 'ThinkPad' object
$ThinkCentre_Rows = (($Parsed.All | Where-Object { $_.TagName -eq 'h4' -and $_.InnerHtml -eq "ThinkCentre / Lenovo"}).NextElementSibling | Select-Object -Property * -ExcludeProperty InnerHtml, OuterHtml, TextContent).AllRows
# Loop through the rows and build a custom object
$ThinkCentre_DocIDs = foreach ($Row in $ThinkCentre_Rows) {
    # Sub-series
    $SubSeries = $null
    $SubSeries = $Row.Cells[0].InnerHtml

    # WinPE 3.1
    #$WinPE31 = $Row.Cells[1].Children.Attributes["href"].Value
    $WinPE31 = $null
    $WinPE31 = $Row.Cells[1].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # WinPE 5
    $WinPE5 = $null
    $WinPE5 = $Row.Cells[2].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # WinPE 10/11
    $WinPE1011 = $Row.Cells[3].Children | Where-Object { $_.Attributes.Name -eq 'href' } | ForEach-Object {
        # Build Object
        [PSCustomObject]@{
            OS = [System.Net.WebUtility]::HtmlDecode($_.InnerHtml)
            URL = $($_.Attributes | Where-Object { $_.Name -eq 'href' }).Value
        }
    }

    # Build Object
    [PSCustomObject]@{
        SubSeries = $SubSeries
        WinPE31 = $WinPE31
        WinPE5 = $WinPE5
        WinPE1011 = $WinPE1011
    }

    $Count++
    #if ($Count -gt 3) { Break }
}

# Combine the objects
$LenovoWinPEDrivers_DocIDs = [PSCustomObject]@{
    ThinkPad = $ThinkPad_DocIDs
    ThinkStation = $ThinkStation_DocIDs
    ThinkCentre = $ThinkCentre_DocIDs
}

# Define Export Path
$CatalogExportPath = Join-Path $PSScriptRoot "Catalogs"

# Create Export Path if it does not exist
if (-not (Test-Path $CatalogExportPath)) {
    New-Item -Path $CatalogExportPath -ItemType Directory | Out-Null
}

$LenovoWinPEDrivers_DocIDs | Export-Clixml -Path "$CatalogExportPath\LenovokWinPEDocIDURLs.xml" -Depth 100 -Force

# Export JSON - Import the XML and convert it to JSON
Import-Clixml -Path "$CatalogExportPath\LenovokWinPEDocIDURLs.xml" | ConvertTo-Json -Depth 100 | Out-File -FilePath "$CatalogExportPath\LenovokWinPEDocIDURLs.json" -Force
