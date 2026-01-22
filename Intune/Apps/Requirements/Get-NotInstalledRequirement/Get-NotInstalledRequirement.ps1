<#
.Synopsis
Searches for installed software by DisplayName and/or DisplayVersion and returns 'Applicable' if not found.

Created on:   2024-06-17
Updated on:   2026-01-22
Created by:   Ben Whitmore @PatchMyPC
Modified by:  Michael Escamilla @PatchMyPC
Filename:     Get-NotInstalledRequirement.ps1

.Description
This script can be used as a requirement rule on a Win32 app to ensure the Win32 app is only applicable if software listed in the $appNameList is not installed
This script searches through specified registry paths to find installed software that matches a given DisplayName.
If a match is found on $appnameList, no output is displayed and the requirment rule is not satisfied which prevents the installation of the Win32 app.
If no match is found, 'Applicable' is written to the output stream to indicate the software is not installed and the Win32 app is applicable because the requirement is met.

References/credit:
https://github.com/PatchMyPCTeam/Community-Scripts/tree/main/Uninstall/Pre-Uninstall/Uninstall-Software @Codaamok

---------------------------------------------------------------------------------
LEGAL DISCLAIMER

The PowerShell script provided is shared with the community as-is
The author and co-author(s) make no warranties or guarantees regarding its functionality, reliability, or suitability for any specific purpose
Please note that the script may need to be modified or adapted to fit your specific environment or requirements
It is recommended to thoroughly test the script in a non-production environment before using it in a live or critical system
The author and co-author(s) cannot be held responsible for any damages, losses, or adverse effects that may arise from the use of this script
You assume all risks and responsibilities associated with its usage
---------------------------------------------------------------------------------

#>

# Define the application name to search for
# Note: The script will search for the exact match based on what you enter in $appNameList. 
# You can add asterisk characters (*) if you want to use wildcards.
# Optionally define a Version and Operator to perform version comparison
# Operator Accepted Values: Equal, NotEqual, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual
# If any of the apps are found, the script will not return 'Applicable' and the Win32 app will not be installed.
[array]$appNameList = @(
    @{Name = 'FortiClient VPN'; Version = '7.2'; Operator = 'GreaterThanOrEqual'; }
)

# Set the error action preference to stop the script if an error occurs
$ErrorActionPreference = 'Stop'

# Function to generate full registry paths based on architecture and hives to search
function Get-PathsToSearch {
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Both', 'x86', 'x64')]
        [String]$Architecture = 'Both',
        [Parameter(Mandatory = $false)]
        [ValidateSet('HKLM', 'HKCU')]
        [String[]]$HivesToSearch = ('HKLM', 'HKCU')
    )

    # Decide paths to search based on architecture parameter
    $pathsToSearch = switch -regex ($Architecture) {
        'Both|x86' { if (-not ([IntPtr]::Size -eq 4)) { 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' } else { 'Software\Microsoft\Windows\CurrentVersion\Uninstall\*' } }
        'Both|x64' { if (-not ([IntPtr]::Size -eq 4)) { 'Software\Microsoft\Windows\CurrentVersion\Uninstall\*' } }
    }

    # Generate full registry paths
    $fullPaths = foreach ($pathFragment in $pathsToSearch) {
        foreach ($hive in $HivesToSearch) {
            [string]::Format('registry::{0}\{1}', $hive, $pathFragment)
        }
    }

    # Return the full paths
    return $fullPaths
}

# Function to convert a version string to a [System.Version] object
# Stole from: https://github.com/PatchMyPCTeam/Community-Scripts/blob/main/Uninstall/Pre-Uninstall/Uninstall-Software/Uninstall-Software.ps1
function ConvertTo-Version {
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$VersionString
    )

    #Delete any backslashes
    $FormattedVersion = $VersionString.Replace('\', '')

    #Replace build or _build with a .
    $FormattedVersion = $FormattedVersion -replace '(_|\s)build', '.'

    #Replace any underscore, dash. plus, or open bracket surrounded by digits with a .
    $FormattedVersion = $FormattedVersion -replace '(?<=\d)(_|-|\+|\()(?=\d)', '.'

    # If Version ends in a trailing ., delete it
    $FormattedVersion = $FormattedVersion -replace '\.$', ''

    # Delete anything that isn't a decimal or a dot
    $FormattedVersion = $FormattedVersion -replace '[^\d.]', ''

    # Delete any random instances of a-z followed by digits, such as b1, ac3, beta5
    $FormattedVersion = $FormattedVersion -replace '[a-z]+\d+', ''

    # Trim any version numbers with 5 or more parts down to 4
    $FormattedVersion = $FormattedVersion -replace '^((\d+\.){3}\d+).*', '$1'

    # Add a .0 to any single integers
    $FormattedVersion = $FormattedVersion -replace '^(\d+)$', '$1.0'

    # Pad the version number out to contain 4 parts before casting to [version]
    $PeriodCount = $FormattedVersion.ToCharArray().Where{ $_ -eq '.' }.Count
    switch ($PeriodCount) {
        1 { $PaddedVersion = $FormattedVersion + '.0.0' }    # One period, so it's a two-part version number
        2 { $PaddedVersion = $FormattedVersion + '.0' }      # Two periods, so it's a three-part version number
        default { $PaddedVersion = $FormattedVersion }
    }

    try {
        [System.Version]::Parse($PaddedVersion)
    }
    catch {
        throw "'$VersionString' was formatted to '$FormattedVersion' which failed to be cast as [System.Version]: $_"
    }

}

function Get-InstalledSoftware {
    param (
        [Parameter(Mandatory = $true)]
        [array]$appName
    )

    # Variable to detect if any matching software is found
    [bool]$detected = $false

    # Search through all generated registry paths
    foreach ($path in Get-PathsToSearch) {

        # Retrieve all subkeys from the path
        $subkeys = Get-ChildItem $path

        # Check each subkey for matching DisplayName
        foreach ($subkey in $subkeys) {

            # Retrieve the DisplayName from the subkey
            $displayName = (Get-ItemProperty -Path $subkey.PSPath -Name DisplayName -ErrorAction SilentlyContinue).DisplayName

            foreach ($app in $appName) {
                if ($displayName -like "$($app.Name)") {
                    # Gather additional information when a match is found
                    $displayVersion = (Get-ItemProperty -Path $subkey.PSPath -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
                    $publisher = (Get-ItemProperty -Path $subkey.PSPath -Name Publisher -ErrorAction SilentlyContinue).Publisher
                    $installDate = (Get-ItemProperty -Path $subkey.PSPath -Name InstallDate -ErrorAction SilentlyContinue).InstallDate

                    # Create a custom object to hold software information
                    $application = [PSCustomObject]@{
                        DisplayName    = $displayName
                        DisplayVersion = $displayVersion
                        Publisher      = $publisher
                        InstallDate    = $installDate
                        MatchFoundOn   = "$($app.Name)"
                    }

                    # Check if version comparison is needed
                    if ($app.ContainsKey('Version') -and $app.ContainsKey('Operator')) {
                        $installedVersion = ConvertTo-Version -VersionString $displayVersion
                        $requiredVersion = ConvertTo-Version -VersionString $app.Version
                        $operator = $app.Operator

                        # Perform version comparison based on the specified operator
                        $versionMatch = switch ($operator) {
                            'Equal' { $installedVersion -eq $requiredVersion }
                            'NotEqual' { $installedVersion -ne $requiredVersion }
                            'GreaterThan' { $installedVersion -gt $requiredVersion }
                            'GreaterThanOrEqual' { $installedVersion -ge $requiredVersion }
                            'LessThan' { $installedVersion -lt $requiredVersion }
                            'LessThanOrEqual' { $installedVersion -le $requiredVersion }
                            default { }
                        }

                        if ($versionMatch) {
                            $detected = $true
                            # Only un-comment the line below to write-host during testing to see if the $appname match is working as expected
                            #Write-Host $application
                        }
                    }
                    else {
                        $detected = $true
                        # Only un-comment the line below to write-host during testing to see if the $appname match is working as expected
                        # Write-Host $application
                    }
                }
            }
        }
    }

    # Return the result
    if ($detected -eq $true) {
        return $true
    }
    else {
        return $false
    }
}

# Output result if no software match was found
if ((Get-InstalledSoftware -appName $appNameList) -eq $false) {
    Write-Host 'Applicable'
}