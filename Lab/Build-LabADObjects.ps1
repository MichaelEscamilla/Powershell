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
            New-ADOrganizationalUnit -Name $OUName -Path "DC=$($DomainName -replace '\.', ',DC=')" -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to create Organizational Unit: $_"
        }
        Write-Output "Organizational Unit '$OUName' created successfully in domain '$DomainName'."

        # Create the Users Accounts
        try {
            $userNames = @("CMAdmin", "CM_NA", "CM_DJ", "CM_CP_Workstations", "CM_CP_Servers")
            foreach ($userName in $userNames) {
                # Use the provided UserPassword if available, otherwise Randonly generate a password
                if ($DefaultPassword) {
                    $userPassword = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force
                }
                else {
                    $userPassword = [System.Web.Security.Membership]::GeneratePassword(12, 2) | ConvertTo-SecureString -AsPlainText -Force
                }
                $userPrincipalName = "$userName@$DomainName"
                New-ADUser -Name $userName -AccountPassword $userPassword -UserPrincipalName $userPrincipalName -Path $ouPath -Enabled $true -ErrorAction Stop
                Write-Output "User account '$userName' created successfully in Organizational Unit '$OUName'."

            }
        }
        catch {
            Write-Error "Failed to create User accounts: $_"
        }
    }
}