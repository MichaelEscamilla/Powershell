<#
.SYNOPSIS
    Removes devices from Configuration Manager and Active Directory
.DESCRIPTION
    This script connects to a Configuration Manager site and removes specified devices
    from both Configuration Manager and Active Directory
.PARAMETER SiteCode
    The Configuration Manager site code
.PARAMETER SiteServer
    The Configuration Manager site server FQDN
.PARAMETER DeviceName
    The name of the device to remove (optional - if not specified, will show a grid view for selection)
.PARAMETER RemoveFromAD
    Switch to also remove devices from Active Directory
.EXAMPLE
    .\Remove-DeviceConfigMgrAD.ps1 -SiteCode "P01" -SiteServer "cm01.contoso.com"
.EXAMPLE
    .\Remove-DeviceConfigMgrAD.ps1 -SiteCode "P01" -SiteServer "cm01.contoso.com" -DeviceName "DESKTOP-123456" -RemoveFromAD
.NOTES
    Requires the ConfigurationManager module and ActiveDirectory module for AD operations
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteCode,
    
    [Parameter(Mandatory = $true)]
    [string]$SiteServer,
    
    [Parameter(Mandatory = $false)]
    [string]$DeviceName,
    
    [Parameter(Mandatory = $false)]
    [switch]$RemoveFromAD
)

function Connect-ConfigMgr {
    param(
        [string]$SiteCode,
        [string]$SiteServer
    )
    
    try {
        # Import the ConfigurationManager module
        if (-not (Get-Module ConfigurationManager)) {
            Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction Stop
        }
        
        # Connect to the site
        if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $SiteServer -ErrorAction Stop | Out-Null
        }
        
        # Set the current location to the site
        Set-Location "$($SiteCode):\" -ErrorAction Stop
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Successfully connected to Configuration Manager site $SiteCode on $SiteServer" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to connect to Configuration Manager site. Error: $_"
        return $false
    }
}

function Get-CMDevices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DeviceName
    )

    try {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Retrieving devices from Configuration Manager..." -ForegroundColor Yellow
        
        # Build query based on whether a device name was provided
        if ($DeviceName) {
            $devices = Get-CMDevice -Name $DeviceName -Fast
            
            if (-not $devices) {
                Write-Warning "No device found with name: $DeviceName"
                return $null
            }
        } else {
            # Get all devices
            $devices = Get-CMDevice -Fast
            
            if (-not $devices) {
                Write-Warning "No devices found in Configuration Manager"
                return $null
            }
            
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Found $($devices.Count) devices in Configuration Manager" -ForegroundColor Green
        }
        
        return $devices
    }
    catch {
        Write-Error "Error retrieving devices from Configuration Manager: $_"
        return $null
    }
}

function Remove-CMSelectedDevices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Devices
    )
    
    $results = @{
        Success = @()
        Failed = @()
    }
    
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Starting removal of $($Devices.Count) device(s) from Configuration Manager..." -ForegroundColor Yellow
    
    foreach ($device in $Devices) {
        try {
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Removing device '$($device.Name)' from Configuration Manager..." -NoNewline
            
            # Remove the device from ConfigMgr
            Remove-CMDevice -Name $device.Name -Force -Confirm:$false -ErrorAction Stop
            
            Write-Host "Success" -ForegroundColor Green
            $results.Success += $device.Name
        }
        catch {
            Write-Host "Failed" -ForegroundColor Red
            Write-Warning "Error removing device '$($device.Name)': $_"
            $results.Failed += $device.Name
        }
    }
    
    # Display summary
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] `nRemoval Summary:" -ForegroundColor Cyan
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Successfully removed: $($results.Success.Count) device(s)" -ForegroundColor Green
    
    if ($results.Success.Count -gt 0) {
        $results.Success | ForEach-Object { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)]   - $_" -ForegroundColor Green }
    }
    
    if ($results.Failed.Count -gt 0) {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Failed to remove: $($results.Failed.Count) device(s)" -ForegroundColor Red
        $results.Failed | ForEach-Object { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)]   - $_" -ForegroundColor Red }
    }
    
    return $results
}

function Remove-ADSelectedDevices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$DeviceNames
    )
    
    $results = @{
        Success = @()
        Failed = @()
        NotFound = @()
    }
    
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] `nStarting removal of $($DeviceNames.Count) device(s) from Active Directory..." -ForegroundColor Yellow
    
    # Check if ActiveDirectory module is available
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        Write-Error "ActiveDirectory module is not available. Cannot remove devices from AD."
        return $results
    }
    
    # Import the ActiveDirectory module
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to import ActiveDirectory module: $_"
        return $results
    }
    
    foreach ($deviceName in $DeviceNames) {
        try {
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Searching for computer '$deviceName' in Active Directory..." -NoNewline
            
            # Check if computer exists in AD
            $adComputer = Get-ADComputer -Filter "Name -eq '$deviceName'" -ErrorAction Stop
            
            if ($adComputer) {
                Write-Host "found" -ForegroundColor Green
                Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Removing computer '$deviceName' from Active Directory..." -NoNewline
                
                # Remove computer from AD with Recursive switch to delete all child objects
                $adComputer | Remove-ADObject -Confirm:$false -Recursive -ErrorAction Stop
                
                Write-Host "Success" -ForegroundColor Green
                $results.Success += $deviceName
            }
            else {
                Write-Host "not found" -ForegroundColor Yellow
                $results.NotFound += $deviceName
            }
        }
        catch {
            Write-Host "Failed" -ForegroundColor Red
            Write-Warning "Error removing computer '$deviceName' from AD: $_"
            $results.Failed += $deviceName
        }
    }
    
    # Display summary
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] `nAD Removal Summary:" -ForegroundColor Cyan
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Successfully removed: $($results.Success.Count) device(s)" -ForegroundColor Green
    
    if ($results.Success.Count -gt 0) {
        $results.Success | ForEach-Object { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)]   - $_" -ForegroundColor Green }
    }
    
    if ($results.NotFound.Count -gt 0) {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Not found in AD: $($results.NotFound.Count) device(s)" -ForegroundColor Yellow
        $results.NotFound | ForEach-Object { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)]   - $_" -ForegroundColor Yellow }
    }
    
    if ($results.Failed.Count -gt 0) {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Failed to remove: $($results.Failed.Count) device(s)" -ForegroundColor Red
        $results.Failed | ForEach-Object { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)]   - $_" -ForegroundColor Red }
    }
    
    return $results
}

# Connect to Configuration Manager
if (-not (Connect-ConfigMgr -SiteCode $SiteCode -SiteServer $SiteServer)) {
    Write-Error "Failed to connect to Configuration Manager. Exiting script."
    exit 1
}

# Get devices from Configuration Manager
if ($DeviceName) {
    # If a specific device name is provided, get just that device
    $cmDevices = Get-CMDevices -DeviceName $DeviceName
    
    # If device is found, add it to the selection
    if ($cmDevices) {
        $selectedDevices = $cmDevices
    } else {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No devices selected for removal. Exiting script." -ForegroundColor Yellow
        Set-Location -Path $PSScriptRoot
        exit 0
    }
} else {
    # Get all devices and display in Out-GridView for selection
    $cmDevices = Get-CMDevices
    
    if ($cmDevices) {
        # Present devices in a grid view with multiple selection enabled
        $selectedDevices = $cmDevices | 
            Select-Object Name, DeviceOS, LastLogonUser, LastActiveTime, ClientVersion, ADSiteName |
            Out-GridView -Title "Select devices to delete from CM Database" -PassThru
        
        if (-not $selectedDevices) {
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No devices selected for removal. Exiting script." -ForegroundColor Yellow
            Set-Location -Path $PSScriptRoot
            exit 0
        }
    } else {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] No devices available. Exiting script." -ForegroundColor Yellow
        Set-Location -Path $PSScriptRoot
        exit 0
    }
}

# Display selected devices for confirmation
Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] The following devices will be removed:" -ForegroundColor Yellow
$selectedDevices | Select-Object Name, DeviceOS, LastLogonUser, LastActiveTime | Format-Table -AutoSize

# Confirm before proceeding
$confirmation = Read-Host "Do you want to proceed with removing these devices? (Y/N)"
if ($confirmation -ne 'Y') {
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Operation cancelled by user. Exiting script." -ForegroundColor Yellow
    Set-Location -Path $PSScriptRoot
    exit 0
}

# Remove selected devices from ConfigMgr
$cmRemovalResults = Remove-CMSelectedDevices -Devices $selectedDevices

# If RemoveFromAD switch is provided, also remove from Active Directory
if ($RemoveFromAD) {
    # Ask for confirmation specific to AD removal
    $adConfirmation = Read-Host "Do you also want to remove these devices from Active Directory? (Y/N)"
    
    if ($adConfirmation -eq 'Y') {
        # Get device names for AD removal
        $deviceNames = $selectedDevices | Select-Object -ExpandProperty Name
        
        # Remove devices from AD
        $adRemovalResults = Remove-ADSelectedDevices -DeviceNames $deviceNames
    }
    else {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Skipping removal from Active Directory." -ForegroundColor Yellow
    }
}
else {
    # Ask if user wants to also remove from AD
    $adConfirmation = Read-Host "Do you want to also remove these devices from Active Directory? (Y/N)"
    
    if ($adConfirmation -eq 'Y') {
        # Get device names for AD removal
        $deviceNames = $selectedDevices | Select-Object -ExpandProperty Name
        
        # Remove devices from AD
        $adRemovalResults = Remove-ADSelectedDevices -DeviceNames $deviceNames
    }
    else {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))][$($MyInvocation.MyCommand.Name)] Skipping removal from Active Directory." -ForegroundColor Yellow
    }
}

# Return to original location
Set-Location -Path $PSScriptRoot