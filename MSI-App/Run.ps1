
function Show-MSI_psf {
	# Load Assemblies
	Add-Type -AssemblyName PresentationFramework
	Add-Type -AssemblyName WindowsBase
	Add-Type -AssemblyName System.Xml
	Add-Type -AssemblyName System.Drawing
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName WindowsFormsIntegration

	# Import XAML
	[xml]$XAMLformMSIProperties = Get-Content -Path $PSScriptRoot\windows.xaml

	# Create a new XML node reader for reading the XAML content
	$readerformMSIProperties = New-Object System.Xml.XmlNodeReader $XAMLformMSIProperties

	# Load the XAML content into a WPF window object using the XAML reader
	[System.Windows.Window]$formMSIProperties = [Windows.Markup.XamlReader]::Load($readerformMSIProperties)

	# This script selects all XML nodes with a "Name" attribute from the $XAMLformMSIProperties object.
	# For each selected node, it creates a PowerShell variable with the same name as the node's "Name" attribute.
	# The value of the created variable is set to the result of the FindName method called on the $formMSIProperties object, using the node's "Name" attribute as the parameter.
	$XAMLformMSIProperties.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $formMSIProperties.FindName($_.Name) -Scope Global }

	function Update-ListBox {
		<#
		.SYNOPSIS
			This functions helps you load items into a ListBox or CheckedListBox.
		
		.DESCRIPTION
			Use this function to dynamically load items into the ListBox control.
		
		.PARAMETER ListBox
			The ListBox control you want to add items to.
		
		.PARAMETER Items
			The object or objects you wish to load into the ListBox's Items collection.
		
		.PARAMETER DisplayMember
			Indicates the property to display for the items in this control.
		
		.PARAMETER Append
			Adds the item(s) to the ListBox without clearing the Items collection.
		
		.EXAMPLE
			Update-ListBox $ListBox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Update-ListBox $listBox1 "Red" -Append
			Update-ListBox $listBox1 "White" -Append
			Update-ListBox $listBox1 "Blue" -Append
		
		.EXAMPLE
			Update-ListBox $listBox1 (Get-Process) "ProcessName"
		
		.NOTES
			Additional information about the function.
	#>
		
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ListBox]
			$ListBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[Parameter(Mandatory = $false)]
			[string]
			$DisplayMember,
			[switch]
			$Append
		)
		
		if (-not $Append) {
			$listBox.Items.Clear()
		}
		
		if ($Items -is [System.Windows.Forms.ListBox+ObjectCollection] -or $Items -is [System.Collections.ICollection]) {
			$listBox.Items.AddRange($Items)
		}
		elseif ($Items -is [System.Collections.IEnumerable]) {
			$listBox.BeginUpdate()
			foreach ($obj in $Items) {
				$listBox.Items.Add($obj)
			}
			$listBox.EndUpdate()
		}
		else {
			$listBox.Items.Add($Items)
		}
		
		$listBox.DisplayMember = $DisplayMember
	}
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
			#Event Argument: $_ = [System.Windows.Forms.DragEventArgs]
			#TODO: Place custom script here
			$filename = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
			if ($filename) {
				$FileInfo = Get-MsiDatabaseProperties -FilePath $filename
				$txt_Name.Text = $FileInfo.ProductName
				$txt_Manufacturer.Text = $FileInfo.Manufacturer
				$txt_Version.Text = $FileInfo.ProductVersion
				$txt_Code.Text = $FileInfo.ProductCode
				Update-ListBox $lsbox_File $filename[0]
			}
		}
	)

	$lsbox_File.Add_DragOver(
		{
			if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
				$filename = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
				$fileExt = (Get-Item $filename).Extension
				if ($fileExt -eq ".msi") {
					$_.Effect = [System.Windows.DragDropEffects]::Copy
				}
			}
			else {
				$_.Effect = [System.Windows.DragDropEffects]::None
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