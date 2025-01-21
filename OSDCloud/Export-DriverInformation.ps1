# Get Driver Information
$Drivers = Get-CimInstance -ClassName Win32_PnPEntity | Select Status, DeviceID, Name, Manufacturer, PNPClass, Service | Where-Object { $_.Status -eq "OK" } | Sort Status, DeviceID

$DriverExport = @()
foreach ($Driver in $Drivers) {
    $DriverExport += [PSCustomObject]@{
        Status       = $Driver.Status
        DeviceID     = $Driver.DeviceID
        Name         = $Driver.Name
        Manufacturer = $Driver.Manufacturer
        PNPClass     = $Driver.PNPClass
        Service      = $Driver.Service
    }
}

$DriverExport | Export-Csv -Path "$($env:SystemDrive)\DriversExport.csv" -NoTypeInformation -Force