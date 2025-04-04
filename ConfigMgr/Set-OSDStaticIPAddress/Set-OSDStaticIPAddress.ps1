<#

This Script will: 

Set a Static IP Address for the Task Sequence environment.
 
TS Variables Created:
 - OSDAdapter0EnableDHCP
 - OSDAdapter0IPAddressList
 - OSDAdapter0SubnetMask
 - OSDAdapter0Gateways
 - OSDAdapter0DNSServerList
 
#>

try {
	# Initialize the Task Sequence Environment
	$TSEnviornment = New-Object -ComObject Microsoft.SMS.TSEnvironment
}
catch {
	# Output message if not in a Task Sequence environment
	Write-Output "Not in Task Sequence"
}

if ($TSEnviornment) {
	#region Create the Group Policies
	$TSVariables = @(
		@{ Name = "OSDAdapterCount"; Value = "1" }, 
		@{ Name = "OSDAdapter0EnableDHCP"; Value = "FALSE" },
		@{ Name = "OSDAdapter0IPAddressList"; Value = "192.168.1.30" },
		@{ Name = "OSDAdapter0SubnetMask"; Value = "255.255.255.0" },
		@{ Name = "OSDAdapter0Gateways"; Value = "192.168.1.1" },
		@{ Name = "OSDAdapter0DNSServerList"; Value = "192.168.1.10" }
	)

	foreach ($TSVariable in $TSVariables) {
		# Create and set the Task Sequence Variable
		Write-Output "Creating Task Sequence Variable: [$($TSVariable.Name)] | Set to: [$($TSVariable.Value)]"
		$TSEnviornment.Value("$($TSVariable.Name)") = "$($TSVariable.Value)"
	}
}
else {
	Write-Output "Not in Task Sequence"
}