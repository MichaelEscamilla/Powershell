<#
    Checks if any users don't have a Firewall profile for Webex
#>

#Define a log path (defaults to system, but will be copied to the users own temp after successful execution.)
$LogPath = join-path -path $($env:SystemRoot) -ChildPath "\TEMP\log_Detection-FWRulesWebex.txt"

# Child path of Firewall Rule
$ProgramPathChild = "AppData\Local\CiscoSparkLauncher\CiscoCollabHost.exe"
# Name of the Firewall Rule
$RuleName = "Webex - CiscoCollabHost.exe"

#region Functions

Function Get-LoggedInUserProfiles() {
    # Gets all user profiles
    try {
        # Get All User profiles on Machine
        $UserProfilesAll = Get-CimInstance win32_userprofile | select LocalPath, SID

        # Filter to only Network Accounts and EntraID Accounts
        $UserProfilesAll = $UserProfilesAll | Where-Object { $_.SID -like "S-1-5-21-*" -or $_.SID -like "S-1-12-*" }
        # Filter out Built-In Administrator
        $UserProfilesAll = $UserProfilesAll | Where-Object { $_.SID -notlike "*-500" }
    }
    catch [Exception] {
    
        $Message = "Unable to get User Profiles: $_"
        Throw $Message
       
    }

    return $UserProfilesAll
}

function Set-FWRule {
    param (
        $ProgramPath
    )
    # Create Firewall Rule
    New-NetFirewallRule -DisplayName "$($RuleName)" -Direction Inbound -Action Allow -Protocol Any -Profile Domain, Private, Public -Program $ProgramPath | Out-Null
}

function Remove-FWRule {
    param (
        $FirewallRule
    )
    # Remove Firewall Rule
    $FirewallRule | Remove-NetFirewallRule -ErrorAction SilentlyContinue
}

function Get-FWRule {
    param (
        $ProfilesObj,
        [switch]$Remediate,
        [switch]$Cleanup
    )

    # Loop through the object incase there is more than one
    foreach ($Profile in $ProfilesObj) {
        # Setup Program Path Based on User Profile
        $ProgramPathUser = Join-Path -Path $($Profile.LocalPath) -ChildPath $ProgramPathChild

        # Search for a Rule that matches what we want
        $RuleFound = $false
        $RuleFoundCount = 0            
        # Get existing Firewall rules based on $ProgramPath
        $ExistingFWRules = $null
        $ExistingFWRules = Get-NetFirewallApplicationFilter -Program $ProgramPathUser -ErrorAction SilentlyContinue
        if ($ExistingFWRules) {
            foreach ($Rule in $ExistingFWRules) {
                # Get Rule Details
                $CurrentRule = $Rule | Get-NetFirewallRule 
                # Check if the details Match
                if (($CurrentRule.DisplayName -eq "$($RuleName)")`
                        -and ($CurrentRule.Direction -eq "Inbound")`
                        -and ($CurrentRule.Action -eq "Allow")`
                        -and ($CurrentRule.Profile -eq "Domain, Private, Public")`
                        -and ((($CurrentRule | Get-NetFirewallPortFilter).Protocol) -eq "Any")`
                        -and (($RuleFoundCount -eq 0))
                ) {                    
                    $RuleFound = $true
                    if ($Cleanup) {
                        $RuleFoundCount++
                    }
                }
                else {
                    if ($Cleanup) {
                        Remove-FWRule -FirewallRule $CurrentRule
                        Write-Information "Removed Rule: [$($CurrentRule.DisplayName)] - [$($CurrentRule.Name)]" -InformationAction Continue
                    }    
                }
            }
        }
        
        if (!($RuleFound)) {
            if ($Remediate) {
                Set-FWRule -ProgramPath "$($ProgramPathUser)"
                Write-Information "Rule Created for: [$($Profile.LocalPath)]" -InformationAction Continue
            }
            else {
                # If a rule is not found Exit 1 to Trigger Remediate
                Write-Host "User Rule Missing for: [$($Profile.LocalPath)]"
                Exit 1
            }
        }
    }
}

#endregion Functions

#region Execution

#Start logging
Start-Transcript $LogPath -Force

Try {
    
    Write-Information "Checking Firewall Rules for each user profile" -InformationAction Continue
    # Get user profiles and Check for firewall rules, Remediate, Cleanup
    Get-FWRule -ProfilesObj (Get-LoggedInUserProfiles) -Remediate -Cleanup
    # If you make it passed above, you're good
    Write-Host "All Firewall Rules Exist"
    Exit 0
}
catch [Exception] {
    $Message = "I don't know what happened!!: $_"
    Write-Host "$Message"
    exit 1

}
Finally {
    #Make sure we stop logging no matter what whent down.
    Stop-Transcript

}

#endregion Execution