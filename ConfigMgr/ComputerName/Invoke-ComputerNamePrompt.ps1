# Invoke-ComputerNamePrompt.ps1
# This script displays a WPF window asking for a computer name and returns the input.

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Define XAML for the window
[xml]$xaml = @"
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
[System.Windows.Window]$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader($xaml)))

# Create Variables for all the controls in the XAML form
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Global }

# Set up button events
$btnOK.Add_Click({
        if ($txtComputerName.Text.Length -gt 15) {
            [System.Windows.MessageBox]::Show('Computer name must be 15 characters or less.', 'Validation Error', 'OK', 'Error')
            return
        }

        # Check if running in a task sequence
        try {
            # Initialize the Task Sequence Environment
            $TSEnviornment = New-Object -ComObject Microsoft.SMS.TSEnvironment

            # Create and set the Task Sequence Variable
            Write-Host "Creating Task Sequence Variable: [OSDComputerName] | Set to: [$($txtComputerName.Text)]"
            $TSEnviornment.Value("OSDComputerName") = "$($txtComputerName.Text)"
        }
        catch {
            # Output message if not in a Task Sequence environment
            Write-Host "Not in Task Sequence"
        }
        
        $window.Close()
    })

$btnCancel.Add_Click({
        $window.Close()
    })

# Show window
$window.ShowDialog() | Out-Null