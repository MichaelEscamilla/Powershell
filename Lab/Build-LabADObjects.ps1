function Build-LabADObjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$OUName = "OU=MTA,DC=dev,DC=michaeltheadmin,DC=com",

        [Parameter(Mandatory = $false)]
        [string]$DomainName = "dev.michaeltheadmin.com",

        [Parameter(Mandatory = $false)]
        [string]$DefaultPassword
    )

    process {
        # Create the Organizational Unit
        try {
            $ouPath = "OU=$OUName,DC=$($DomainName -replace '\.', ',DC=')"
            #New-ADOrganizationalUnit -Name $OUName -Path "DC=$($DomainName -replace '\.', ',DC=')" -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to create Organizational Unit: $_"
        }
        Write-Output "Organizational Unit '$OUName' created successfully in domain '$DomainName'."

        # Create the Users Accounts
        try {
            $users = @(
                @{ Name = "CMAdmin"; Description = "Configuration Manager Admin" },
                @{ Name = "CM_NA"; Description = "Configuration Manager Network Access" },
                @{ Name = "CM_DJ"; Description = "Configuration Manager Domain Join" },
                @{ Name = "CM_CP_Workstations"; Description = "Workstation Client Push Account" },
                @{ Name = "CM_CP_Servers"; Description = "Server Client Push Account" }
            )

            foreach ($user in $users) {
                $userName = $user.Name
                $userDescription = $user.Description
                $userPrincipalName = "$userName@$DomainName"

                # Check if the user already exists using the SamAccountName
                $existingUser = Get-ADUser -Filter { SamAccountName -eq $userName } -ErrorAction SilentlyContinue

                if ($existingUser) {
                    # Update the description if the user exists
                    Set-ADUser -Identity $existingUser -Description $userDescription -ErrorAction Stop
                    Write-Output "User account '$userName' already exists. Description updated to '$userDescription'."
                }
                else {
                    # Use the provided UserPassword if available, otherwise randomly generate a password
                    if ($DefaultPassword) {
                        $userPassword = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force
                    }
                    else {
                        $userPassword = [System.Web.Security.Membership]::GeneratePassword(12, 2) | ConvertTo-SecureString -AsPlainText -Force
                    }

                    New-ADUser -Name $userName -AccountPassword $userPassword -UserPrincipalName $userPrincipalName -Path $OUName -Enabled $true -Description $userDescription -ErrorAction Stop
                    Write-Output "User account '$userName' with description '$userDescription' created successfully in Organizational Unit '$OUName'."
                }
            }
        }
        catch {
            Write-Error "Failed to create User accounts: $_"
        }
    }
}