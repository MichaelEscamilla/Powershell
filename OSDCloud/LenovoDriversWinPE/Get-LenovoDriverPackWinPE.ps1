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
                        Component    = 'DriverPack'
                        ID           = $Item.id
                        Manufacturer = 'Lenovo'
                        Family       = $Family
                        Model        = $Product.model
                        Product      = [array]$Product.Queries.Types.Type.split(',').Trim()
                        Name         = $Product.name
                        DocID     = $Item.InnerXml | Split-Path -Leaf
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
