function Build-LabADObjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'OUAndDomain')]
        [string]$OUName,

        [Parameter(Mandatory = $true, ParameterSetName = 'OUAndDomain')]
        [string]$DomainName,

        [Parameter(Mandatory = $false)]
        [string]$DefaultPassword
    )

    process {
        # Create the Organizational Unit
        try {
            $existingOU = Get-ADOrganizationalUnit -Filter { Name -eq "$($OUName)" } -ErrorAction SilentlyContinue

            if ($existingOU) {
                $OUPath = $existingOU.DistinguishedName
                Write-Output "Organizational Unit '$OUName' already exists in domain '$DomainName'."
            }
            else {
                New-ADOrganizationalUnit -Name $OUName -Path "DC=$($DomainName -replace '\.', ',DC=')" -ErrorAction Stop
                Write-Output "Organizational Unit '$OUName' created successfully in domain '$DomainName'."
            }

            # OU Path
            $OUPath = "OU=$($OUName),DC=$($DomainName -replace '\.', ',DC=')"
        }
        catch {
            Write-Error "Failed to create Organizational Unit: $_"
        }

        # Create the Groups
        try {
            $groups = @(
                @{ Name = "CM_Servers"; Description = "Configuration Manager Servers" },
                @{ Name = "CM_Admins"; Description = "Configuration Manager Admins" },
                @{ Name = "SQL_Admins"; Description = "SQL Administrators" },
                @{ Name = "Server_LocalAdmins"; Description = "Server Local Administrators" },
                @{ Name = "Workstation_LocalAdmins"; Description = "Workstation Local Administrators" },
                @{ Name = "CM_App_DeployUsers"; Description = "Configuration Manager Application Deployment Users" },
                @{ Name = "Certificate Admins"; Description = "Certificate Administrators" },
                @{ Name = "Web Server Cert Enrollment"; Description = "Web Server Certificate Enrollment" }
            )

            foreach ($group in $groups) {
                $groupName = $group.Name
                $groupDescription = $group.Description

                # Check if the group already exists using the SamAccountName
                $existingGroup = Get-ADGroup -Identity $groupName -ErrorAction SilentlyContinue

                if ($existingGroup) {
                    # Update the description if the group exists
                    Set-ADGroup -Identity $existingGroup -Description $groupDescription -ErrorAction Stop
                    Write-Output "Group '$groupName' already exists. Updating Information"
                }
                else {
                    Write-Output "OUPATH: $OUPath"
                    New-ADGroup -Name $groupName -SamAccountName $groupName -DisplayName $groupName -GroupCategory Security -GroupScope Global -Path $OUPath -Description $groupDescription -ErrorAction Stop
                    Write-Output "Group '$groupName' with description '$groupDescription' created successfully in Organizational Unit '$OUName'."
                }
            }
        }
        catch {
            Write-Error "Failed to create Groups: $_"
        }

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
                    Set-ADUser -Identity $existingUser -GivenName $userName -Description $userDescription -ErrorAction Stop
                    Write-Output "User account '$userName' already exists. Updating Information"
                }
                else {
                    # Use the provided UserPassword if available, otherwise randomly generate a password
                    if ($DefaultPassword) {
                        $userPassword = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force
                    }
                    else {
                        $userPassword = [System.Web.Security.Membership]::GeneratePassword(12, 2) | ConvertTo-SecureString -AsPlainText -Force
                    }

                    New-ADUser -Name $userName -GivenName $userName -AccountPassword $userPassword -UserPrincipalName $userPrincipalName -Path $OUName -Enabled $true -Description $userDescription -ErrorAction Stop
                    Write-Output "User account '$userName' with description '$userDescription' created successfully in Organizational Unit '$OUName'."
                }
            }
        }
        catch {
            Write-Error "Failed to create User accounts: $_"
        }
    }
}