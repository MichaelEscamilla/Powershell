#Requires -RunAsAdministrator
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Removes a Hyper-V virtual machine along with its associated virtual hard disks.

.DESCRIPTION
    This script removes a specified Hyper-V virtual machine and optionally deletes
    all virtual hard disks associated with it. The script will force shut down the VM
    if it's running before deletion.

.PARAMETER VMName
    The name of the Hyper-V virtual machine to remove.

.PARAMETER DeleteVHDs
    Switch parameter that when specified will delete all virtual hard disks associated with the VM.
    Default is to delete the VHDs.

.PARAMETER Force
    Switch parameter that when specified will suppress confirmation prompts.

.EXAMPLE
    .\Remove-HyperVVM.ps1 -VMName "TestVM"
    Removes the VM named "TestVM" and deletes its associated virtual hard disks after confirmation.

.EXAMPLE
    .\Remove-HyperVVM.ps1 -VMName "TestVM" -DeleteVHDs:$false
    Removes the VM named "TestVM" but preserves its virtual hard disks.

.EXAMPLE
    .\Remove-HyperVVM.ps1 -VMName "TestVM" -Force
    Removes the VM named "TestVM" and deletes its associated virtual hard disks without confirmation.

.NOTES
    Author: Michael Escamilla
    Date:   April 12, 2025
    Requires: Hyper-V PowerShell module and administrative privileges
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false, Position = 0, HelpMessage = "Name of the VM to delete")]
    [string]$VMName,
    
    [Parameter(Mandatory = $false)]
    [bool]$DeleteVHDs = $true,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

function Get-VHDPaths {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM
    )

    $vhdPaths = @()
    
    # Get all hard drives attached to the VM
    $hardDrives = $VM | Get-VMHardDiskDrive
    
    foreach ($drive in $hardDrives) {
        $vhdPaths += $drive.Path
    }
    
    return $vhdPaths
}

try {
    $vmsToProcess = @()
    
    # If VMName is not provided, display a grid view for selection with multi-select
    if ([string]::IsNullOrEmpty($VMName)) {
        $selectedVMs = Get-VM | Out-GridView -Title "Select VMs to delete (you can select multiple)" -OutputMode Multiple
        if ($selectedVMs) {
            $vmsToProcess = $selectedVMs
            Write-Host "Selected VMs: $($vmsToProcess.Name -join ', ')"
        } else {
            Write-Warning "No VMs were selected. Operation cancelled."
            exit
        }
    } else {
        # If VMName is provided, use it
        $vm = Get-VM -Name $VMName -ErrorAction Stop
        $vmsToProcess = @($vm)
    }

    # Process each VM
    foreach ($vm in $vmsToProcess) {
        $currentVMName = $vm.Name
        Write-Host "`n======== Processing VM: $currentVMName ========" -ForegroundColor Cyan
          # Get VHD paths before removing the VM
        $vhdPaths = Get-VHDPaths -VM $vm
    
        if ($vhdPaths.Count -eq 0 -and $DeleteVHDs) {
            Write-Warning "No virtual hard disks found attached to the VM '$currentVMName'."
        }
        elseif ($DeleteVHDs) {
            Write-Host "The following virtual hard disks will be deleted:"
            $vhdPaths | ForEach-Object { Write-Host "  - $_" }
        }
        
        # Check if VM is running and turn it off if needed
        if ($vm.State -ne "Off") {
            Write-Host "VM '$currentVMName' is currently $($vm.State). Stopping VM..."
            $confirmStop = $true
            if (-not $Force -and -not $PSCmdlet.ShouldContinue("VM '$currentVMName' will be forcibly shut down. Continue?", "Stop VM")) {
                $confirmStop = $false
                Write-Warning "Operation cancelled for VM '$currentVMName'. VM must be stopped before it can be removed."
                continue
            }
            
            if ($confirmStop) {
                $vm | Stop-VM -Force -Confirm:$false
                Write-Host "VM '$currentVMName' has been stopped."
            }
        }
        
        # Remove the VM
        $confirmRemove = $true
        if (-not $Force) {
            $message = "Are you sure you want to remove VM '$currentVMName'"
            if ($DeleteVHDs) {
                $message += " and delete all associated virtual hard disks"
            }
            $message += "?"
            
            if (-not $PSCmdlet.ShouldContinue($message, "Remove VM")) {
                $confirmRemove = $false
                Write-Host "Operation cancelled for VM '$currentVMName'."
                continue
            }
        }
        
        if ($confirmRemove) {
            Write-Host "Removing VM '$currentVMName'..."
            $vm | Remove-VM -Force -Confirm:$false
            Write-Host "VM '$currentVMName' has been removed."
            
            # Delete the VHDs if specified
            if ($DeleteVHDs -and $vhdPaths.Count -gt 0) {
                foreach ($vhdPath in $vhdPaths) {
                    if (Test-Path -Path $vhdPath) {
                        Write-Host "Deleting virtual hard disk: $vhdPath"
                        Remove-Item -Path $vhdPath -Force -Confirm:$false
                    }
                    else {
                        Write-Warning "Virtual hard disk not found: $vhdPath"
                    }
                }
                Write-Host "All associated virtual hard disks have been deleted for VM '$currentVMName'."
            }
        }
    }
}
catch [Microsoft.HyperV.PowerShell.VirtualizationObjectNotFoundException] {
    Write-Error "VM '$VMName' not found. Please check the name and try again."
    exit 1
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}

Write-Host "Operation completed successfully."
