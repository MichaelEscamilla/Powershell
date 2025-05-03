# Invoke-ComputerNamePrompt.ps1 - Yes
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

# Focus the computer name textbox when the window loads
$window.Add_SourceInitialized({
    $txtComputerName.Focus()
})

# Set up button events
$btnOK.Add_Click({
        # Check if the input is empty or contains only whitespace
        if ([string]::IsNullOrWhiteSpace($txtComputerName.Text)) {
            [System.Windows.MessageBox]::Show('Computer name cannot be empty.', 'Validation Error', 'OK', 'Error')
            return
        }
        # Check if the input is longer than 15 characters
        if ($txtComputerName.Text.Length -gt 15) {
            [System.Windows.MessageBox]::Show('Computer name must be 15 characters or less.', 'Validation Error', 'OK', 'Error')
            return
        }

        # Confirmation prompt
        $result = [System.Windows.MessageBox]::Show("Are you sure you want to set the computer name to '$($txtComputerName.Text)'?", 'Confirm Computer Name', 'YesNo', 'Question')
        # If the user clicks 'No', focus the textbox and return
        if ($result -ne [System.Windows.MessageBoxResult]::Yes) {
            $txtComputerName.Focus()
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
            Write-Host "Not in Task Sequence, will not set Task Sequence variable."
            Write-Host "Computer Name: $($txtComputerName.Text)"
        }
        
        $window.Close()
    })

# Enable Enter key in the textbox to trigger OK
$txtComputerName.Add_KeyDown({
    if ($_.Key -eq 'Enter') {
        $btnOK.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
    }
})

$btnCancel.Add_Click({
        $window.Close()
    })

# Show window
$window.ShowDialog() | Out-Null