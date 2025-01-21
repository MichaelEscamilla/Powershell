# Get Driver Information
$Drivers = Get-CimInstance -ClassName Win32_PnPEntity | Select-Object Status, DeviceID, Name, Manufacturer, PNPClass, Service | Where-Object { $_.Status -ne "OK" } | Sort Status, DeviceID

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

Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] Export Drivers to: ['$env:SystemDrive\DriversExport.csv]"
$DriverExport | Export-Csv -Path "$($env:SystemDrive)\DriversExport.csv" -NoTypeInformation -Force
Write-Host -ForegroundColor DarkCyan "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] Display Driver Information"
$DriverExport