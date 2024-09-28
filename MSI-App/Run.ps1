
function Show-MSI_psf {
	# Load Assemblies
	Add-Type -AssemblyName PresentationFramework
	Add-Type -AssemblyName System.Windows.Forms

	# Import XAML
	#[xml]$XAMLformMSIProperties = Get-Content -Path $PSScriptRoot\windows.xaml
	#[xml]$XAMLformMSIProperties = Get-Content -Path $PSScriptRoot\MSIProperties.xaml

	#Build the GUI
	[xml]$XAMLformMSIProperties = @"
<Window
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  Name="form1"
  MinWidth="900"
  MaxWidth="900"
  MinHeight="300"
  MaxHeight="300"
  Title="MSI Properties"
  FontSize="15">
  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="*" />
      <RowDefinition Height="*" />
      <RowDefinition Height="*" />
      <RowDefinition Height="*" />
      <RowDefinition Height="*" />
      <RowDefinition Height="*" />
    </Grid.RowDefinitions>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="Auto" />
      <ColumnDefinition Width="*" />
      <ColumnDefinition Width="0.15*" />
    </Grid.ColumnDefinitions>

    <Label
      Grid.Row="0"
      Grid.Column="0"
      Name="lbl_ProductName"
      Margin="5"
      HorizontalAlignment="Center"
      VerticalAlignment="Center"
      AllowDrop="False"
      IsEnabled="True">
      Product Name
    </Label>
    <TextBox
      Grid.Row="0"
      Grid.Column="1"
      Name="txt_ProductName"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      VerticalContentAlignment="Center"
      AcceptsReturn="False"
      AcceptsTab="False"
      AllowDrop="False"
      IsEnabled="True"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsReadOnly="True"
      xml:space="preserve" />
    <Button
      Grid.Row="0"
      Grid.Column="2"
      Name="btn_ProductName_Copy"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      Content="Copy"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsEnabled="False" />

    <Label
      Grid.Row="1"
      Grid.Column="0"
      Name="lbl_Manufacturer"
      Margin="5"
      HorizontalAlignment="Center"
      VerticalAlignment="Center"
      AllowDrop="False"
      IsEnabled="True">
      Manufacturer
    </Label>
    <TextBox
      Grid.Row="1"
      Grid.Column="1"
      Name="txt_Manufacture"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      VerticalContentAlignment="Center"
      AcceptsReturn="False"
      AcceptsTab="False"
      AllowDrop="False"
      IsEnabled="True"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsReadOnly="True"
      xml:space="preserve" />
    <Button
      Grid.Row="1"
      Grid.Column="2"
      Name="btn_Manufacture_Copy"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      Content="Copy"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsEnabled="False" />

    <Label
      Grid.Row="2"
      Grid.Column="0"
      Name="lbl_ProductVersion"
      Margin="5"
      HorizontalAlignment="Center"
      VerticalAlignment="Center"
      AllowDrop="False"
      IsEnabled="True">
      Product Version
    </Label>
    <TextBox
      Grid.Row="2"
      Grid.Column="1"
      Name="txt_ProductVersion"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      VerticalContentAlignment="Center"
      AcceptsReturn="False"
      AcceptsTab="False"
      AllowDrop="False"
      IsEnabled="True"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsReadOnly="True"
      xml:space="preserve" />
    <Button
      Grid.Row="2"
      Grid.Column="2"
      Name="btn_ProductVersion_Copy"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      Content="Copy"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsEnabled="False" />

    <Label
      Grid.Row="3"
      Grid.Column="0"
      Name="lbl_ProductCode"
      Margin="5"
      HorizontalAlignment="Center"
      VerticalAlignment="Center"
      AllowDrop="False"
      IsEnabled="True">
      Product Code
    </Label>
    <TextBox
      Grid.Row="3"
      Grid.Column="1"
      Name="txt_ProductCode"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      VerticalContentAlignment="Center"
      AcceptsReturn="False"
      AcceptsTab="False"
      AllowDrop="False"
      IsEnabled="True"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsReadOnly="True"
      xml:space="preserve" />
    <Button
      Grid.Row="3"
      Grid.Column="2"
      Name="btn_ProductCode_Copy"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      Content="Copy"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsEnabled="False" />

    <Label
      Grid.Row="4"
      Grid.Column="0"
      Name="lbl_UpgradeCode"
      Margin="5"
      HorizontalAlignment="Center"
      VerticalAlignment="Center"
      AllowDrop="False"
      IsEnabled="True">
      Upgrade Code
    </Label>
    <TextBox
      Grid.Row="4"
      Grid.Column="1"
      Name="txt_UpgradeCode"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      VerticalContentAlignment="Center"
      AcceptsReturn="False"
      AcceptsTab="False"
      AllowDrop="False"
      IsEnabled="True"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsReadOnly="True"
      xml:space="preserve" />
    <Button
      Grid.Row="4"
      Grid.Column="3"
      Name="btn_UpgradeCode_Copy"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      Content="Copy"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsEnabled="False" />

    <Button
      Grid.Row="5"
      Grid.Column="0"
      Name="btn_Clear"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Center"
      Content="Clear File"
      MinHeight="32"
      MaxHeight="32"
      Width="Auto"
      IsEnabled="False" />
    <ListBox
      Grid.Row="5"
      Grid.Column="1"
      Grid.ColumnSpan="2"
      Name="lsbox_File"
      Margin="5"
      HorizontalAlignment="Stretch"
      VerticalAlignment="Stretch"
      AllowDrop="True"
      IsEnabled="True"
      TabIndex="0">
      <ListBox.Items>
        <ListBoxItem HorizontalContentAlignment="Center" VerticalContentAlignment="Center">
          <TextBlock Text="Drag and drop files here - *.msi" HorizontalAlignment="Center" VerticalAlignment="Center" />
        </ListBoxItem>
      </ListBox.Items>
    </ListBox>
  </Grid>
</Window>

"@

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

	function Get-MsiProperties {
		param (
			[Parameter(Mandatory = $true)]
			[IO.FileInfo[]]$Path
		)
	
		# Check if the MSI file path exists
		if (-not (Test-Path $Path)) {
			throw "The file $Path does not exist."
		}
	
		# Create a new Windows Installer COM object
		$WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
	
		# Open the MSI database in read-only mode
		$MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstaller, @($Path.FullName, 0))
	
		# Open a view on the Property table
		$MSIPropertyView = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, @("SELECT * FROM Property"))
	
		# Execute the view query
		$MSIPropertyView.GetType().InvokeMember("Execute", "InvokeMethod", $null, $MSIPropertyView, $null)
	
		# Fetch the first record from the result set
		$MSIRecord = $MSIPropertyView.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $MSIPropertyView, $null)
	
		# Initialize an empty hashtable to store properties
		$Properties = @{}
	
		# Loop through all records in the result set
		while ($null -ne $MSIRecord) {
			# Get the property name from the first column
			$property = $MSIRecord.GetType().InvokeMember("StringData", "GetProperty", $null, $MSIRecord, @(1))
			
			# Get the property value from the second column
			$Value = $MSIRecord.GetType().InvokeMember("StringData", "GetProperty", $null, $MSIRecord, @(2))
			
			# Add the property name and value to the hashtable
			$Properties[$Property] = $Value
			
			# Fetch the next record from the result set
			$MSIRecord = $MSIPropertyView.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $MSIPropertyView, $null)
		}
	
		# Return the hashtable of properties
		$Properties
	}

	$lsbox_File.Add_Drop(
		{
			$filename = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
			if ($filename) {
				# Get the MSI file properties
				#$FileInfo = Get-MsiDatabaseProperties -FilePath $filename
				$FileInfo = Get-MsiProperties -Path $filename

				# Populate the textboxes with the MSI file properties
				$txt_ProductName.Text = $FileInfo.ProductName
				$txt_Manufacture.Text = $FileInfo.Manufacturer
				$txt_ProductVersion.Text = $FileInfo.ProductVersion
				$txt_ProductCode.Text = $FileInfo.ProductCode
				$txt_UpgradeCode.Text = $FileInfo.UpgradeCode

				# Enable the Copy buttons
				$btn_ProductName_Copy.IsEnabled = $true
				$btn_Manufacture_Copy.IsEnabled = $true
				$btn_ProductVersion_Copy.IsEnabled = $true
				$btn_ProductCode_Copy.IsEnabled = $true
				$btn_UpgradeCode_Copy.IsEnabled = $true
				$btn_Clear.IsEnabled = $true

				# Clear the listbox and add the filename
				$lsbox_File.Items.Clear()
				$lsbox_File.Items.Add($filename[0])

				# Center the text of the added item
				$lsbox_File.HorizontalContentAlignment = 'Center'	
   }
		}
	)

	$lsbox_File.Add_DragOver(
		{
			# Check if the dragged data contains file drop data
			if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        Write-Host "FileDrop: [$($_.Data.GetData([Windows.Forms.DataFormats]::FileDrop))]"
        Write-Host "File Extension: [$([System.IO.Path]::GetExtension($_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)))]"
				foreach ($File in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
					# Check if the file is an MSI file
					#Write-Host "Extension: $([System.IO.Path]::GetExtension($File))"
					if (([System.IO.Path]::GetExtension($File)) -eq ".msi") {
						# Set the drag effect to Copy if the file is an MSI file
						$_.Effects = [System.Windows.DragDropEffects]::Copy
					}
					else {
						# Set the drag effect to None if the file is not an MSI file
						$_.Effects = [System.Windows.DragDropEffects]::None
					}
					$_.Handled = $true
				}
			}
		}
	)

	$btn_Clear.add_Click(
		{
			# Loop through all items and remove from the listbox
			for ($i = ($lsbox_File.Items.Count); $i -ge 0; $i--) {
				$CurrentItem = $lsbox_File.Items[$i]
				$lsbox_File.Items.Remove($CurrentItem)
			}
			# Clear all textboxes
			$txt_ProductName.Clear()
			$txt_Manufacture.Clear()
			$txt_ProductVersion.Clear()
			$txt_ProductCode.Clear()
			$txt_UpgradeCode.Clear()

			# Disable the Copy buttons
			$btn_ProductName_Copy.IsEnabled = $false
			$btn_Manufacture_Copy.IsEnabled = $false
			$btn_ProductVersion_Copy.IsEnabled = $false
			$btn_ProductCode_Copy.IsEnabled = $false
			$btn_UpgradeCode_Copy.IsEnabled = $false
		}
	)

	$btn_ProductName_Copy.add_Click(
		{
			[System.Windows.Forms.Clipboard]::SetText($txt_ProductName.Text)
		}
	)

	$btn_Manufacture_Copy.add_Click(
		{
			[System.Windows.Forms.Clipboard]::SetText($txt_Manufacturer.Text)
		}
	)

	$btn_ProductVersion_Copy.add_Click(
		{
			[System.Windows.Forms.Clipboard]::SetText($txt_ProductVersion.Text)
		}
	)

	$btn_ProductCode_Copy.add_Click(
		{
			[System.Windows.Forms.Clipboard]::SetText($txt_ProductCode.Text)
		}
	)

	$btn_UpgradeCode_Copy.add_Click(
		{
			[System.Windows.Forms.Clipboard]::SetText($txt_UpgradeCode.Text)
		}
	)

	#Show the WPF Window
	$formMSIProperties.WindowStartupLocation = "CenterScreen"
	return $formMSIProperties.ShowDialog()
}

#Call the form
Show-MSI_psf | Out-Null