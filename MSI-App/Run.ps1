
function Show-MSI_psf {
	# Load Assemblies
	Add-Type -AssemblyName PresentationFramework
	Add-Type -AssemblyName System.Windows.Forms

	# Import XAML
	[xml]$XAMLformMSIProperties = Get-Content -Path $PSScriptRoot\windows.xaml

	# Remove some stuff


	# Create a new XML node reader for reading the XAML content
	$readerformMSIProperties = New-Object System.Xml.XmlNodeReader $XAMLformMSIProperties

	
	# Load the XAML content into a WPF window object using the XAML reader
	#[System.Windows.Window]$formMSIProperties = [Windows.Markup.XamlReader]::Load($readerformMSIProperties)
	$formMSIProperties = [Windows.Markup.XamlReader]::Load($readerformMSIProperties)

	# This script selects all XML nodes with a "Name" attribute from the $XAMLformMSIProperties object.
	# For each selected node, it creates a PowerShell variable with the same name as the node's "Name" attribute.
	# The value of the created variable is set to the result of the FindName method called on the $formMSIProperties object, using the node's "Name" attribute as the parameter.
	$XAMLformMSIProperties.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $formMSIProperties.FindName($_.Name) -Scope Global }

	function Get-MsiDatabaseProperties {
		<#
	    .SYNOPSIS
	    This function retrieves properties from a Windows Installer MSI database.
	    .DESCRIPTION
	    This function uses the WindowInstaller COM object to pull all values from the Property table from a MSI
	    .EXAMPLE
	    Get-MsiDatabaseProperties 'MSI_PATH'
	    .PARAMETER FilePath
	    The path to the MSI you'd like to query
	    #>
		[CmdletBinding()]
		param (
			[Parameter(Mandatory = $True,
				ValueFromPipeline = $True,
				ValueFromPipelineByPropertyName = $True,
				HelpMessage = 'What is the path of the MSI you would like to query?')]
			[IO.FileInfo[]]$FilePath
		)
		
		begin {
			$com_object = New-Object -com WindowsInstaller.Installer
		}
		
		process {
			try {
				
				$database = $com_object.GetType().InvokeMember(
					"OpenDatabase",
					"InvokeMethod",
					$Null,
					$com_object,
					@($FilePath.FullName, 0)
				)
				
				$query = "SELECT * FROM Property"
				$View = $database.GetType().InvokeMember(
					"OpenView",
					"InvokeMethod",
					$Null,
					$database,
					($query)
				)
				
				$View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
				
				$record = $View.GetType().InvokeMember(
					"Fetch",
					"InvokeMethod",
					$Null,
					$View,
					$Null
				)
				
				$msi_props = @{ }
				while ($record -ne $null) {
					$prop_name = $record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 1)
					$prop_value = $record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 2)
					$msi_props[$prop_name] = $prop_value
					$record = $View.GetType().InvokeMember(
						"Fetch",
						"InvokeMethod",
						$Null,
						$View,
						$Null
					)
				}
				
				$msi_props
				
			}
			catch {
				throw "Failed to get MSI file version the error was: {0}." -f $_
			}
		}
	}

	$lsbox_File.Add_Drop(
		{
			$filename = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
			if ($filename) {
				$FileInfo = Get-MsiDatabaseProperties -FilePath $filename
				$txt_Name.Text = $FileInfo.ProductName
				$txt_Manufacturer.Text = $FileInfo.Manufacturer
				$txt_Version.Text = $FileInfo.ProductVersion
				$txt_Code.Text = $FileInfo.ProductCode
				$lsbox_File.Items.Clear()
				$lsbox_File.Items.Add($filename[0])
			}
			Write-host "FileDrop: [$($_.Data.GetData([Windows.Forms.DataFormats]::FileDrop))]"
		}
	)

	$lsbox_File.Add_DragOver(
		{
			# Check if the dragged data contains file drop data
			if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
				foreach ($File in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
					# Check if the file is an MSI file
					if ((Get-Item $File).Extension -eq ".msi") {
						# Set the drag effect to Copy if the file is an MSI file
						$_.Effects = [System.Windows.DragDropEffects]::Copy
					}
					else {
						# Set the drag effect to None if the file is not an MSI file
						$_.Effects = [System.Windows.DragDropEffects]::None
					}
				}
			}
		}
	)

	$btn_Man_Copy.add_Click(
		{
			[System.Windows.Forms.Clipboard]::SetText($txt_Manufacturer.Text)
		}
	)

	#Show the WPF Window
	$formMSIProperties.WindowStartupLocation = "CenterScreen"
	return $formMSIProperties.ShowDialog()
}

#Call the form
Show-MSI_psf | Out-Null