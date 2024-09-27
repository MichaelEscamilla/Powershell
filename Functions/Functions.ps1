<#
.SYNOPSIS
Some useful functions

.DESCRIPTION
Just a list of function that I like
.PARAMETER Name
Nothing for now

.EXAMPLE
For Later

.NOTES
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
powershell iex (irm functions.osdcloud.com)
#>

[CmdletBinding()]
param ()

# Load Functions
Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/MichaelEscamilla/Powershell/main/Functions/Get-PatchTuesday.ps1')