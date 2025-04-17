<#

This Script will: 

Set the OSDComputerName for the Task Sequence environment. 
 
TS Variables Created:
 - OSDComputerName
 
#>

try {
	# Initialize the Task Sequence Environment
	$TSEnviornment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
}
catch {
	# Output message if not in a Task Sequence environment
	Write-Output "Not in Task Sequence"
}



if ($TSEnviornment) {
	#region Create the Group Policies
	$TSVariables = @(
		@{ Name = "OSDComputerName"; Value = "MTA-98-DOMAIN" }
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