param(
    [string]$AdminCategory,
    [string]$UserName,
    [string]$UserPassword,
    [string]$SiteServerFQDN
)

# Create the Array for storing all the applications
$Applications = [System.Collections.ArrayList]::new()

# Create the Credential Object for the ConfigMgr Admin Service
$Password = ConvertTo-SecureString "$UserPassword" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("$UserName", $Password)

# Get all Application Categories from the ConfigMgr Admin Service
$AllCategories = (Invoke-RestMethod -Method 'Get' -Uri "https://$SiteServerFQDN/AdminService/wmi/SMS_CategoryInstance" -Credential $Credential).Value

# Get all applications from the ConfigMgr Admin Service
$AllItems = (Invoke-RestMethod -Method 'Get' -Uri "https://$SiteServerFQDN/AdminService/wmi/SMS_Application" -Credential $Credential).Value | Select-Object -Property LocalizedDisplayName, SoftwareVersion, CategoryInstance_UniqueIDs
$AllSortedItems = $AllItems | Sort-Object -Property LocalizedDisplayName, SoftwareVersion

# Loop through the App Categories to match the one we want to search for
$Category = $AllCategories | Where-Object { $_.LocalizedCategoryInstanceName -like "$AdminCategory" }

# Find all Applications that have the Category we are looking for
$ApplicationsToInstall = $AllSortedItems | Where-Object { $_.CategoryInstance_UniqueIDs -like "$($Category.CategoryInstance_UniqueID)" }

# Output the found applications
Write-Host "Found the following applications in the $AdminCategory category:"
ForEach ( $Application in $ApplicationsToInstall ) {
    Write-Host " - $($Application.LocalizedDisplayName)"
}

# Put together a single list of all the current applications to install
ForEach ($Application in $ApplicationsToInstall) {
    $CurrentApp = New-Object PSObject -prop @{
        Name = $Application.LocalizedDisplayName
    }
    [void]$Applications.Add($CurrentApp)
}

# Set the Task Sequence Variable to those Applications
try {
    # Initialize the Task Sequence Environment
    $TSEnviornment = New-Object -ComObject Microsoft.SMS.TSEnvironment
}
catch {
    # Output message if not in a Task Sequence environment
    Write-Output "Not in Task Sequence"
}

# Set a Counter for the Task Sequence Variable
$Count = 1
# Create an Array to hold the Application IDs
$AppId = @()
# Loop through the Applications and set the Task Sequence Variable
ForEach ( $App in $($Applications.Name) ) {
    #Add Code to add apps
    $Id = "{0:D2}" -f $Count
    $AppId = "XApplications$Id" 
    if ($TSEnviornment) {
        # Set the Task Sequence Variable to the Application ID
        $TSEnviornment.Value("$($AppId)") = "$($App)"

        # Check that the Task Sequence Variable exists
        Write-Host "Task Sequence Variable $($AppId): $($TSEnviornment.Value("$($AppId)"))"
    }
    else {
        Write-Host "App Name: $($App) | App ID: $($AppId)"
    }
    # Increment the Counter
    $Count++
}
