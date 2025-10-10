    # Gather In-Use Drivers
    $PnputilXml = & pnputil.exe /enum-devices /format xml
    $PnputilXmlObject = [xml]$PnputilXml
    $PnputilDevices = $PnputilXmlObject.PnpUtil.Device | `
        #Where-Object { $_.DriverName -like "oem*.inf" } | `
        Sort-Object DriverName -Unique | `
        Select-Object -Property DriverName, Status, ClassGuid, ClassName, DeviceDescription, ManufacturerName, InstanceId
    $PnputilDevices | Export-Clixml -Path "C:\Users\Eskim\downloads\Drivers.xml" -Force
    #=================================================
    # Export Drivers to Disk    
    $OutputPath = "C:\Users\Eskim\downloads\ExportedDrivers2"
    Write-Verbose "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Exporting drivers to: $OutputPath"
    foreach ($Device in $PnputilDevices) {
        # Check that the Device has a DriverName
        if ($Device.Drivername) {
            $FolderName = $Device.DriverName -replace '.inf', ''
            $destinationPath = $OutputPath + "\$($Device.ClassName)\$($Device.DeviceDescription)\$($Device.ManufacturerName)\" + $FolderName
            # Ensure the output directory exists
            if (-not (Test-Path -Path $destinationPath)) {
                New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
            }
            
            # Export the driver using pnputil
            Write-Verbose "[$(Get-Date -format G)][$($MyInvocation.MyCommand.Name)] Exporting $($Device.DriverName) to: $destinationPath"
            $null = & pnputil.exe /export-driver $Device.DriverName $destinationPath
        }
    }