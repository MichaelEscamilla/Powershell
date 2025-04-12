#Requires -RunAsAdministrator
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Sets the Network Adapter as the first boot device for a specified Hyper-V VM.
.DESCRIPTION
    This script modifies the boot order of a Hyper-V virtual machine to prioritize the Network Adapter
    as the first boot device. Useful for PXE booting or network-based installations.
.PARAMETER VMName
    Name of the virtual machine to modify.
.EXAMPLE
    .\Set-VMNetworkBootOrder.ps1 -VMName "MyVM"
.NOTES
    Author: GitHub Copilot
    Date: April 10, 2025
    Requires: Hyper-V PowerShell module and administrator privileges
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$VMName
)

# If VMName is not provided, show a selection dialog with all VMs
if ([string]::IsNullOrEmpty($VMName)) {
    Write-Host "No VM name provided. Displaying selection dialog..." -ForegroundColor Cyan
    try {
        $allVMs = Get-VM -ErrorAction Stop
        
        if ($allVMs.Count -eq 0) {
            Write-Error "No virtual machines found on this host."
            exit 1
        }
          # Display VM selection dialog using Out-GridView with specific properties
        $selectedVM = $allVMs | Select-Object Name, State, Uptime, @{Name="Memory(GB)"; Expression={[math]::Round($_.MemoryAssigned/1GB, 2)}} | 
            Out-GridView -Title "Select a Virtual Machine to modify its boot order" -OutputMode Single
        
        if ($null -eq $selectedVM) {
            Write-Host "Operation canceled. No VM was selected." -ForegroundColor Yellow
            exit 0
        }
        
        # Get the full VM object based on the selected name
        $VMName = $selectedVM.Name
        $vm = Get-VM -Name $VMName
        
        $VMName = $selectedVM.Name
        $vm = $selectedVM
    }
    catch {
        Write-Error "Failed to retrieve virtual machines. $_"
        exit 1
    }
}
else {
    # Check if VM exists if name was provided
    try {
        $vms = Get-VM -Name "$($VMName)" -ErrorAction Stop
        
        # Check if more than one VM is found
        if ($vms -is [array] -and $vms.Count -gt 1) {
            Write-Error "Multiple VMs found with name '$VMName'. Please provide a more specific VM name."
            Write-Host "Found VMs:" -ForegroundColor Yellow
            $vms | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Yellow }
            exit 1
        }
        
        $vm = $vms
    }
    catch {
        Write-Error "Virtual Machine '$VMName' not found. Please check the VM name and try again."
        exit 1
    }
}

Write-Host "Configuring boot order for VM '$VMName'..." -ForegroundColor Cyan

# Get the current firmware
$firmware = Get-VMFirmware -VMName $VMName

# Get all boot entries
$bootEntries = $firmware.BootOrder

# Display current boot order
Write-Host "Current boot order for VM '$VMName':" -ForegroundColor Cyan
$i = 1
foreach ($device in $bootEntries) {
    Write-Host "  $i. $($device.BootType)" -ForegroundColor Cyan
    $i++
}
Write-Host ""

# Find the network adapter boot entry
$networkBootEntry = $bootEntries | Where-Object { $_.BootType -eq "Network" }

if ($null -eq $networkBootEntry) {
    Write-Error "No network adapter found in the boot configuration for VM '$VMName'. Make sure the VM has a network adapter."
    exit 1
}

# Create a new boot order with Network Adapter first
$newBootOrder = @($networkBootEntry) + ($bootEntries | Where-Object { $_ -ne $networkBootEntry })

# Set the new boot order
Write-Host "Setting Network Adapter as the first boot device..." -ForegroundColor Yellow
Set-VMFirmware -VMName $VMName -BootOrder $newBootOrder

# Verify the changes
$updatedFirmware = Get-VMFirmware -VMName $VMName
$firstBootDevice = $updatedFirmware.BootOrder[0]

if ($firstBootDevice.BootType -eq "Network") {
    Write-Host "Success! Network Adapter is now the first boot device for VM '$VMName'." -ForegroundColor Green
    Write-Host "Current boot order:" -ForegroundColor Cyan
    $i = 1
    foreach ($device in $updatedFirmware.BootOrder) {
        Write-Host "  $i. $($device.BootType)" -ForegroundColor Cyan
        $i++
    }
}
else {
    Write-Host "Warning: Failed to set Network Adapter as the first boot device." -ForegroundColor Red
}
