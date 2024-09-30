# Check if the script is running as administrator
$Global:currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
  Write-Warning "The script is running as an administrator."
  Write-Warning "Drag and Drog will not work while running as an administrator."
}

# Load Assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Import XAML
#[xml]$XAMLformMSIProperties = Get-Content -Path $PSScriptRoot\windows.xaml
#[xml]$XAMLformMSIProperties = Get-Content -Path $PSScriptRoot\MSIProperties.xaml

# Build the GUI
[xml]$XAMLformMSIProperties = @"
<Window x:Class="OSDCloudGUI.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:OSDCloudGUI"
        mc:Ignorable="d"
        BorderThickness="0"
        RenderTransformOrigin="0.5,0.5"
        ResizeMode="NoResize"
        WindowStartupLocation = "CenterScreen"
        Title="OSDCloudGUI version on Manufacturer Model Product" Height="380" Width="820">
    <Window.Resources>
        <ResourceDictionary>
            <Style TargetType="{x:Type Button}">
                <Setter Property="Background"
                        Value="{DynamicResource FlatButtonBackgroundBrush}" />
                <Setter Property="BorderThickness"
                        Value="0" />
                <Setter Property="FontSize"
                        Value="{DynamicResource FlatButtonFontSize}" />
                <Setter Property="Foreground"
                        Value="{DynamicResource FlatButtonForegroundBrush}" />
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="{x:Type Button}">
                            <Border x:Name="Border"
                                    Margin="0"
                                    Background="{TemplateBinding Background}"
                                    BorderBrush="{TemplateBinding BorderBrush}"
                                    CornerRadius="5"
                                    BorderThickness="{TemplateBinding BorderThickness}"
                                    SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}">
                                <ContentPresenter x:Name="ContentPresenter"
                                                  ContentTemplate="{TemplateBinding ContentTemplate}"
                                                  Content="{TemplateBinding Content}"
                                                  HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"
                                                  Margin="{TemplateBinding Padding}"
                                                  VerticalAlignment="{TemplateBinding VerticalContentAlignment}" />
                            </Border>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
                <Style.Triggers>
                    <Trigger Property="IsMouseOver"
                             Value="True">
                        <!-- Windows 11 Theme Dark Blue -->
                        <Setter Property="Background"
                                Value="#0096D6" />
                    </Trigger>
                    <Trigger Property="IsMouseOver"
                             Value="False">
                        <!-- Windows 11 Theme Blue -->
                        <Setter Property="Background"
                                Value="#0067C0" />
                    </Trigger>
                    <Trigger Property="IsPressed"
                             Value="True">
                        <Setter Property="Background"
                                Value="{DynamicResource FlatButtonPressedBackgroundBrush}" />
                        <Setter Property="Foreground"
                                Value="{DynamicResource FlatButtonPressedForegroundBrush}" />
                    </Trigger>
                    <Trigger Property="IsEnabled"
                             Value="False">
                        <Setter Property="Foreground"
                                Value="{DynamicResource GrayBrush2}" />
                    </Trigger>
                </Style.Triggers>
            </Style>
            <Style TargetType="{x:Type ComboBox}">
                <Setter Property="FontFamily"
                        Value="Segoe UI" />
            </Style>
            <Style TargetType="{x:Type Label}">
                <Setter Property="FontFamily"
                        Value="Segoe UI" />
            </Style>
            <Style TargetType="{x:Type TextBox}">
                <Setter Property="FontFamily"
                        Value="Segoe UI" />
            </Style>
            <Style TargetType="{x:Type Window}">
                <Setter Property="FontFamily"
                        Value="Segoe UI" />
                <Setter Property="FontSize"
                        Value="16" />
                <Setter Property="Background"
                        Value="White" />
                <Setter Property="Foreground"
                        Value="Black" />
            </Style>
        </ResourceDictionary>
    </Window.Resources>
    <Window.Background>
        <RadialGradientBrush GradientOrigin="0.2,0.2"
                             Center="0.4,0.1"
                             RadiusX="0.7"
                             RadiusY="0.8">
            <RadialGradientBrush.RelativeTransform>
                <TransformGroup>
                    <ScaleTransform CenterY="0.5"
                                    CenterX="0.5" />
                    <SkewTransform CenterY="0.5"
                                   CenterX="0.5" />
                    <RotateTransform Angle="-40.601"
                                     CenterY="0.5"
                                     CenterX="0.5" />
                    <TranslateTransform />
                </TransformGroup>
            </RadialGradientBrush.RelativeTransform>
            <GradientStop Color="White" />
            <GradientStop Color="#FFF9FFFE"
                          Offset="0.056" />
            <GradientStop Color="#FFF8FEFF"
                          Offset="0.776" />
            <GradientStop Color="#FFF4FAFF"
                          Offset="0.264" />
            <GradientStop Color="White"
                          Offset="0.506" />
            <GradientStop Color="AliceBlue"
                          Offset="1" />
        </RadialGradientBrush>
    </Window.Background>
    <DockPanel>
        <Menu DockPanel.Dock="Top">
            <MenuItem Header="Deployment Options">
                <MenuItem Name="captureScreenshots"
                          Header="capture Screenshots"
                          IsCheckable="True"/>
                <MenuItem Name="ClearDiskConfirm"
                          Header="Clear-Disk Confirm Prompt"
                          IsCheckable="True" />
                <MenuItem Name="restartComputer"
                          Header="restart Computer after WinPE"
                          IsCheckable="True" />
            </MenuItem>
            <MenuItem Header="Microsoft Update Catalog">
                <MenuItem Name="updateDiskDrivers"
                          Header="update Disk Drivers"
                          IsCheckable="True" />
                <MenuItem Name="updateFirmware"
                          Header="update System Firmware"
                          IsCheckable="True" />
                <MenuItem Name="updateNetworkDrivers"
                          Header="update Network Drivers"
                          IsCheckable="True" />
                <MenuItem Name="updateSCSIDrivers"
                          Header="update SCSIAdapter Drivers"
                          IsCheckable="True" />
                <MenuItem Name="SyncMSUpCatDriverUSB"
                          Header="Sync MS drivers to USB"
                          IsCheckable="True"
                          IsChecked="True" />
            </MenuItem>
            <MenuItem x:Name="ManufacturerFunction" Header="Manufacturer Functions">
                <MenuItem x:Name="Option_Name_1"
                    Header="Option_Header_1"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="Option_Name_2"
                    Header="Option_Header_1"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="Option_Name_3"
                    Header="Option_Header_3"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="Option_Name_4"
                    Header="Option_Header_4"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="Option_Name_5"
                    Header="Option_Header_5"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="Option_Name_6"
                    Header="Option_Header_6"
                    IsCheckable="True"
                    IsChecked="False" />
            </MenuItem>
<MenuItem x:Name="SetupComplete" Header="SetupComplete Options">
                <MenuItem x:Name="WindowsUpdates"
                    Header="Windows Updates (No Drivers)"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="WindowsUpdateDrivers"
                    Header="Windows Update (Only Drivers)"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="WindowsDefenderUpdate"
                    Header="Windows Defender Update"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="OEMActivation"
                    Header="Apply Key from UEFI"
                    IsCheckable="True"
                    IsChecked="False" />
                <MenuItem x:Name="ShutdownSetupComplete"
                    Header="Shutdown After SetupComplete"
                    IsCheckable="True"
                    IsChecked="False" />
            </MenuItem>
        </Menu>
        <Grid Margin="10,0,10,10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="1" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="1" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="1" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>

        <!-- Row 0 Title -->
        <Label Grid.Row="0"
               Name="BrandingTitleControl"
               Content="OSDCloud"
               FlowDirection="RightToLeft"
               FontSize="24"
               FontWeight="Bold"
               Foreground="#0096D6"
               HorizontalAlignment="Right"
               VerticalAlignment="Top" />

        <!-- Row 1 Gridline -->
        <Line Grid.Row="1"
              X1="0"
              Y1="0"
              X2="1"
              Y2="0"
              Stroke="Gainsboro"
              StrokeThickness="1"
              Stretch="Uniform"></Line>

        <!-- Row 2 OperatingSystem -->
        <StackPanel Grid.Row="2"
                    HorizontalAlignment="Left"
                    VerticalAlignment="Top">
            <!-- Operating System -->
            <StackPanel Orientation="Horizontal"
                        HorizontalAlignment="Left"
                        VerticalAlignment="Top">
                <Label Name="OperatingSystemLabel"
                       Content="Operating System"
                       FontSize="18"
                       FontWeight="Bold"
                       Foreground="#0096D6"
                       Margin="5"
                       Padding="2"
                       Width="155"
                       FlowDirection="RightToLeft" />
                <ComboBox Name="OSNameCombobox"
                          FontSize="16"
                          Margin="5"
                          Padding="2" >
                </ComboBox>
            </StackPanel>
            <StackPanel Orientation="Horizontal"
                        HorizontalAlignment="Left"
                        VerticalAlignment="Top">
                <Label Name="OperatingSystemDetailsLabel"
                       Content=""
                       FontSize="18"
                       FontWeight="Bold"
                       Foreground="#0096D6"
                       Margin="5"
                       Padding="2"
                       Width="155" />
                <ComboBox Name="OSEditionCombobox"
                          FontSize="16"
                          Margin="5"
                          Padding="2" />
                <ComboBox Name="OSLanguageCombobox"
                          FontSize="16"
                          Margin="5"
                          Padding="2" />
                <ComboBox Name="OSActivationCombobox"
                          FontSize="16"
                          Margin="5"
                          Padding="2" />
                <ComboBox Name="ImageNameCombobox"
                          FontSize="16"
                          Margin="5"
                          Padding="2" />
                <Label Name="ImageIndexLabel"
                       Content="Index"
                       FontSize="18"
                       FontWeight="Bold"
                       Foreground="#0096D6"
                       Margin="5"
                       Padding="2" />
                <TextBox Name="ImageIndexTextbox"
                         FontSize="16"
                         Margin="5"
                         Padding="2"
                         Text="Auto" />
            </StackPanel>
            <StackPanel HorizontalAlignment="Left"
                        VerticalAlignment="Top">
            </StackPanel>
        </StackPanel>

        <!-- Row 3 Gridline -->
        <Line Grid.Row="3"
              X1="0"
              Y1="0"
              X2="1"
              Y2="0"
              Stroke="Gainsboro"
              StrokeThickness="1"
              Stretch="Uniform">
        </Line>

        <!-- Row 4 Driver Pack -->
        <StackPanel Grid.Row="4"
                    HorizontalAlignment="Left"
                    VerticalAlignment="Top">
            <!-- Driver Pack -->
            <StackPanel Orientation="Horizontal"
                        HorizontalAlignment="Left"
                        VerticalAlignment="Top">
                <Label Name="DriverPackLabel"
                       Content="Driver Pack"
                       FontSize="18"
                       FontWeight="Bold"
                       Foreground="#0096D6"
                       Margin="5"
                       Padding="2"
                       Width="155"
                       FlowDirection="RightToLeft" />
                <ComboBox Name="DriverPackCombobox"
                          FontSize="16"
                          Margin="5"
                          Padding="2"
                          SelectedIndex="1" >
                    <ComboBoxItem Content="None"/>
                    <ComboBoxItem Content="Microsoft Update Catalog"/>
                </ComboBox>
            </StackPanel>
        </StackPanel>

        <!-- Row 5 Gridline -->
        <Line Grid.Row="5"
              X1="0"
              Y1="0"
              X2="1"
              Y2="0"
              Stroke="Gainsboro"
              StrokeThickness="1"
              Stretch="Uniform">
        </Line>

        <!-- Row 6 Options -->
        <StackPanel Grid.Row="6"
                    Orientation="Horizontal"
                    HorizontalAlignment="Left"
                    VerticalAlignment="Top">
            <Label Name="DeploymentOptionsLabel"
                   Content=""
                   FontSize="18"
                   FontWeight="Bold"
                   Foreground="#0096D6"
                   HorizontalAlignment="Left"
                   Margin="5"
                   Padding="2"
                   Width="155"
                   FlowDirection="RightToLeft" />
        </StackPanel>
        <StackPanel Grid.Row="6"
                    Orientation="Vertical"
                    HorizontalAlignment="Left"
                    VerticalAlignment="Top">
            <!-- AutopilotJson -->
            <StackPanel HorizontalAlignment="Left"
                        VerticalAlignment="Center"
                        Orientation="Horizontal"
                        Margin="10,5,5,0">
                <Label Name="AutopilotJsonLabel"
                       Content="Autopilot JSON"
                       FontSize="15"
                       Foreground="Black"
                       HorizontalAlignment="Right"
                       Margin="5"
                       Padding="2"
                       VerticalAlignment="Center"
                       Width="145"
                       FlowDirection="RightToLeft" />
                <ComboBox Name="AutopilotJsonCombobox"
                          FontSize="14"
                          Margin="5"
                          Padding="2" />
            </StackPanel>
            <!-- OOBEDeployJson -->
            <StackPanel HorizontalAlignment="Left"
                        VerticalAlignment="Center"
                        Orientation="Horizontal"
                        Margin="10,5,5,0">
                <Label Name="OOBEDeployLabel"
                       Content="OOBEDeploy"
                       FontSize="15"
                       Foreground="Black"
                       Margin="5"
                       Padding="2"
                       VerticalAlignment="Center"
                       Width="145"
                       FlowDirection="RightToLeft" />
                <ComboBox Name="OOBEDeployCombobox"
                          FontSize="14"
                          Margin="5"
                          Padding="2" />
            </StackPanel>
            <!-- AutopilotOOBEJson -->
            <StackPanel HorizontalAlignment="Left"
                        VerticalAlignment="Center"
                        Orientation="Horizontal"
                        Margin="10,5,5,0">
                <Label Name="AutopilotOOBELabel"
                       Content="AutopilotOOBE"
                       FontSize="15"
                       Foreground="Black"
                       Margin="5"
                       Padding="2"
                       VerticalAlignment="Center"
                       Width="145"
                       FlowDirection="RightToLeft" />
                <ComboBox Name="AutopilotOOBECombobox"
                          FontSize="14"
                          Margin="5"
                          Padding="2" />
            </StackPanel>
        </StackPanel>

        <!-- Row 7 Gridline -->
        <Line Grid.Row="7"
              X1="0"
              Y1="0"
              X2="1"
              Y2="0"
              Stroke="Gainsboro"
              StrokeThickness="1"
              Stretch="Uniform"></Line>
        
        <!-- Row 8 Start -->
        <Button Grid.Row="8"
                Name="StartButton"
                Content="Start"
                FontSize="18"
                Foreground="White"
                Height="40"
                Width="130"
                HorizontalAlignment="Right"
                VerticalAlignment="Bottom" />
        </Grid>
    </DockPanel>
</Window>
"@

# Create a new XML node reader for reading the XAML content
$readerformMSIProperties = New-Object System.Xml.XmlNodeReader $XAMLformMSIProperties

# Load the XAML content into a WPF window object using the XAML reader
[System.Windows.Window]$formMSIProperties = [Windows.Markup.XamlReader]::Load($readerformMSIProperties)

# This script selects all XML nodes with a "Name" attribute from the $XAMLformMSIProperties object.
# For each selected node, it creates a PowerShell variable with the same name as the node's "Name" attribute.
# The value of the created variable is set to the result of the FindName method called on the $formMSIProperties object, using the node's "Name" attribute as the parameter.
$XAMLformMSIProperties.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $formMSIProperties.FindName($_.Name) -Scope Global }

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

$formMSIProperties.Add_Loaded({
    # Check if the script is running as an administrator
    if (($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
      # Clear the listbox
      $lsbox_File.Items.Clear()
      # Add a warning message to the listbox
      $lsbox_File.Items.Add("WARNING: Running as Administrator | Drag and Drop will not work.")
      # Make the warning message bold and yellow
      $lsbox_File.Background = [System.Windows.Media.Brushes]::Yellow
      $lsbox_File.FontWeight = 'Bold'
    }
    Write-Host "Menu Items: [$($formMSIProperties.FindName('MenuItem_Install'))]"
  })

$lsbox_File.Add_Drop({
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
      $btn_FilePath_Copy.IsEnabled = $true
      $btn_Clear.IsEnabled = $true

      # Clear the listbox and add the filename
      $lsbox_File.Items.Clear()
      $lsbox_File.Items.Add($filename[0])

      # Center the text of the added item
      $lsbox_File.HorizontalContentAlignment = 'Center'	
    }
  })

$lsbox_File.Add_DragOver({
    # Check if the dragged data contains file drop data
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
      foreach ($File in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
        # Check if the file is an MSI file
        if (([System.IO.Path]::GetExtension($File)) -eq ".msi") {
          # Set the drag effect to Copy if the file is an MSI file
          $_.Effects = [System.Windows.DragDropEffects]::Copy
        }
        else {
          # Set the drag effect to None if the file is not an MSI file
          $_.Effects = [System.Windows.DragDropEffects]::None
        }
      }
    }
  })

$btn_Clear.add_Click({
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
    $btn_FilePath_Copy.IsEnabled = $false
  })

$btn_ProductName_Copy.add_Click({
    [System.Windows.Forms.Clipboard]::SetText($txt_ProductName.Text)
  })

$btn_Manufacture_Copy.add_Click({
    [System.Windows.Forms.Clipboard]::SetText($txt_Manufacturer.Text)
  })

$btn_ProductVersion_Copy.add_Click({
    [System.Windows.Forms.Clipboard]::SetText($txt_ProductVersion.Text)
  })

$btn_ProductCode_Copy.add_Click({
    [System.Windows.Forms.Clipboard]::SetText($txt_ProductCode.Text)
  })

$btn_UpgradeCode_Copy.add_Click({
    [System.Windows.Forms.Clipboard]::SetText($txt_UpgradeCode.Text)
  })

$btn_FilePath_Copy.add_Click({
    if ($lsbox_File.Items[0] -match "\s") {
      [System.Windows.Forms.Clipboard]::SetText("`"$($lsbox_File.Items[0])`"")
      Write-Host "Copied to Clipboard: [`"$($lsbox_File.Items[0])`"]"
    }
    else {
      [System.Windows.Forms.Clipboard]::SetText($lsbox_File.Items[0])
      Write-Host "Copied to Clipboard: [$($lsbox_File.Items[0])]"
    }
  })

$MenuItem_Install.add_Click({
    Write-Host "Menu Item Install Clicked"
    Write-Host "Creating GetMSIInformation folder in LOCALAPPDATA folder"
    # Create a new directory in the LOCALAPPDATA folder
    New-Item -ItemType Directory -Path $env:LOCALAPPDATA -Name "GetMSIInformation" -ErrorAction SilentlyContinue
    # Copy the GetMSIInfo.ps1 script to the new directory
    Write-Host "Copying Script to GetMSIInfo Folder"
    $scriptName = [System.IO.Path]::GetFileName($PSCommandPath)
    Write-Host "Current script name: $scriptName"
    Copy-Item "$PSScriptRoot\$($scriptName)" -Destination "$env:LOCALAPPDATA\GetMSIInformation\GetMSIInformation.ps1" -ErrorAction SilentlyContinue
  })

$MenuItem_Uninstall.add_Click({
    Write-Host "Menu Item Uninstall Clicked"
    Write-Host "MyInvocation: $($MyInvocation)"
    Write-Host "MyInvocation.PSCommandPath: $($MyInvocation.PSCommandPath)"
    Write-Host "PSCommandPath: $($PSCommandPath)"
    Write-Host "PSCommandPath.MyCommand: $($PSCommandPath.MyCommand)"
    Write-Host "PSCommandPath.MyCommand.Path: $($PSCommandPath.MyCommand.Path)"
  })

#Show the WPF Window
$formMSIProperties.WindowStartupLocation = "CenterScreen"
$formMSIProperties.ShowDialog() | Out-Null