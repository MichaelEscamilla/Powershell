<#

This Script will: 

Set a Static IP Address for the Task Sequence environment.
 
TS Variables Created:
 - OSDAdapter0EnableDHCP
 - OSDAdapter0IPAddressList
 - OSDAdapter0SubnetMask
 - OSDAdapter0Gateways
 - OSDAdapter0DNSServerList
 
.PARAMETER IPAddress
The static IP address to set. Default: 192.168.1.30

.PARAMETER SubnetMask
The subnet mask to set. Default: 255.255.255.0

.PARAMETER Gateway
The default gateway address. Default: 192.168.1.1

.PARAMETER DNSServer
The DNS server address. Default: 192.168.1.10

.PARAMETER EnableDHCP
If provided, enables DHCP instead of static IP. Default: False

.EXAMPLE
.\Set-OSDStaticIPAddress.ps1 -IPAddress 10.0.0.100 -SubnetMask 255.255.255.0 -Gateway 10.0.0.1 -DNSServer 10.0.0.10

.EXAMPLE
.\Set-OSDStaticIPAddress.ps1 -EnableDHCP $true
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory = $false)]
	[string]$IPAddress = "192.168.1.30",
    
	[Parameter(Mandatory = $false)]
	[string]$SubnetMask = "255.255.255.0",
    
	[Parameter(Mandatory = $false)]
	[string]$Gateway = "192.168.1.1",
    
	[Parameter(Mandatory = $false)]
	[string]$DNSServer = "192.168.1.10",
    
	[Parameter(Mandatory = $false)]
	[bool]$EnableDHCP = $false
)

try {
	# Initialize the Task Sequence Environment
	$TSEnviornment = New-Object -ComObject Microsoft.SMS.TSEnvironment
}
catch {
	# Output message if not in a Task Sequence environment
	Write-Output "Not in Task Sequence"
}

if ($TSEnviornment) {
	#region Create the Task Sequence Variables
	$DHCPValue = if ($EnableDHCP) { "TRUE" } else { "FALSE" }
    
	$TSVariables = @(
		@{ Name = "OSDAdapterCount"; Value = "1" }, 
		@{ Name = "OSDAdapter0EnableDHCP"; Value = $DHCPValue },
		@{ Name = "OSDAdapter0IPAddressList"; Value = $IPAddress },
		@{ Name = "OSDAdapter0SubnetMask"; Value = $SubnetMask },
		@{ Name = "OSDAdapter0Gateways"; Value = $Gateway },
		@{ Name = "OSDAdapter0DNSServerList"; Value = $DNSServer }
	)

	foreach ($TSVariable in $TSVariables) {
		# Create and set the Task Sequence Variable
		Write-Output "Creating Task Sequence Variable: [$($TSVariable.Name)] | Set to: [$($TSVariable.Value)]"
		$TSEnviornment.Value("$($TSVariable.Name)") = "$($TSVariable.Value)"
	}
}
else {
	Write-Output "Not in Task Sequence"
    
	# Display the parameters that would be used in a task sequence
	Write-Output "Script was called with the following parameters:"
	Write-Output "IP Address: $IPAddress"
	Write-Output "Subnet Mask: $SubnetMask"
	Write-Output "Gateway: $Gateway"
	Write-Output "DNS Server: $DNSServer"
	Write-Output "DHCP Enabled: $EnableDHCP"
}