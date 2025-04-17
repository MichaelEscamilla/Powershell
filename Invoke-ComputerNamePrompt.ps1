# Invoke-ComputerNamePrompt.ps1
# This script displays a WPF window asking for a computer name and returns the input.

Add-Type -AssemblyName PresentationFramework

# Define XAML for the window
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Enter Computer Name" Height="150" Width="350" WindowStartupLocation="CenterScreen">
    <StackPanel Margin="10">
        <TextBlock Text="Please enter the computer name:" Margin="0,0,0,10"/>
        <TextBox Name="txtComputerName" Height="25" Margin="0,0,0,10"/>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
            <Button Name="btnOK" Width="75" Margin="0,0,10,0">OK</Button>
            <Button Name="btnCancel" Width="75">Cancel</Button>
        </StackPanel>
    </StackPanel>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlTextReader([System.IO.StringReader]$xaml)))

# Get controls
$txtComputerName = $window.FindName('txtComputerName')
$btnOK = $window.FindName('btnOK')
$btnCancel = $window.FindName('btnCancel')

# Set up button events
$btnOK.Add_Click({
    $window.DialogResult = $true
    $window.Close()
})
$btnCancel.Add_Click({
    $window.DialogResult = $false
    $window.Close()
})

# Show window
$result = $window.ShowDialog()

if ($result -eq $true) {
    $computerName = $txtComputerName.Text
    Write-Host "Computer Name entered: $computerName"
    return $computerName
} else {
    Write-Host "Operation cancelled."
    return $null
}
