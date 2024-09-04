# Install RSAT WSUS
Add-WindowsCapability -Online -Name Rsat.WSUS.Tools~~~~0.0.1.0

# Verify Install
Get-WindowsCapability -Online -Name Rsat.WSUS.Tools~~~~0.0.1.0

# Download Install
$Url_PMPInstaller = "https://patchmypc.com/msi"
$Path_PMPInstaller = "$($env:USERPROFILE)\Downloads"
Invoke-WebRequest -Uri $Url_PMPInstaller -OutFile $Path_PMPInstaller -PassThru
# Run Install
Start-Process 'msiexec.exe' -ArgumentList "/i $(Get-ChildItem -Path $Path_PMPInstaller\PatchMyPC*.msi)" -Wait


# Create PMP Intune Connector App Registration
$PMP_AppReg = New-MgApplication -DisplayName "PatchMyPC - Intune Connector - $(Get-Date -Format MM-dd-yyyy)" -RequiredResourceAccess @(
    @{
        ResourceAppId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API
        ResourceAccess = @(
            @{
                Id = "78145de6-330d-4800-a6ce-494ff2d33d07" # DeviceManagementApps.ReadWrite.All
                Type = "Role"
            },
            @{
                Id = "dc377aa6-52d8-4e23-b271-2a7ae04cedf3" # DeviceManagementConfiguration.Read.All
                Type = "Role"
            },
            @{
                Id = "2f51be20-0bb4-4fed-bf7b-db946066c75e" # DeviceManagementManagedDevices.Read.All
                Type = "Role"
            },
            @{
                Id = "58ca0d9a-1575-47e1-a3cb-007ef2e4583b" # DeviceManagementRBAC.Read.All
                Type = "Role"
            },
            @{
                Id = "5ac13192-7ace-4fcf-b828-1a26f28068ee" # DeviceManagementServiceConfig.ReadWrite.All
                Type = "Role"
            },
            @{
                Id = "98830695-27a2-44f7-8c18-0c3ebc9698f6" # GroupMember.Read.All
                Type = "Role"
            }
        )
    }
)

# Grant Admin Consent
$GraphServicePrincipalId = $(Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'").Id
$ServicePrincipal = New-MgServicePrincipal -AppId $PMP_AppReg.AppId
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipal.Id -PrincipalId $ServicePrincipal.Id -AppRoleId "78145de6-330d-4800-a6ce-494ff2d33d07" -ResourceId $GraphServicePrincipalId
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipal.Id -PrincipalId $ServicePrincipal.Id -AppRoleId "dc377aa6-52d8-4e23-b271-2a7ae04cedf3" -ResourceId $GraphServicePrincipalId
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipal.Id -PrincipalId $ServicePrincipal.Id -AppRoleId "2f51be20-0bb4-4fed-bf7b-db946066c75e" -ResourceId $GraphServicePrincipalId
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipal.Id -PrincipalId $ServicePrincipal.Id -AppRoleId "58ca0d9a-1575-47e1-a3cb-007ef2e4583b" -ResourceId $GraphServicePrincipalId
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipal.Id -PrincipalId $ServicePrincipal.Id -AppRoleId "5ac13192-7ace-4fcf-b828-1a26f28068ee" -ResourceId $GraphServicePrincipalId
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipal.Id -PrincipalId $ServicePrincipal.Id -AppRoleId "98830695-27a2-44f7-8c18-0c3ebc9698f6" -ResourceId $GraphServicePrincipalId

####
# Create Self-Signed Certificate
####
$SubjectName = 'PatchMyPCIntuneConnector'
$CertStore = 'LocalMachine'
$ValidityPeriod = 12
$NewCert = @{
    Subject = "CN=$($SubjectName)"
    CertStoreLocation = "Cert:\$($CertStore)\My"
    HashAlgorithm = 'sha256'
    KeyExportPolicy = 'NonExportable'
    KeyUsage = 'DigitalSignature'
    KeyAlgorithm = 'RSA'
    KeyLength = 2048
    KeySpec = 'Signature'
    NotAfter = (Get-Date).AddMonths($($ValidityPeriod))
    TextExtension = @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
}
$Cert = New-SelfSignedCertificate @NewCert
# Export Public Key
$CertFolder = "$($env:USERPROFILE)\Downloads"
New-Item -Path $CertFolder -ItemType Directory -Force | Out-Null
$CertExport = @{
Cert = $Cert
FilePath = "$($CertFolder)\$($SubjectName).cer"
}
Export-Certificate @CertExport



####
# Create Self-Signed Code-Signing Certificate
####
$SubjectName_CodeSigning = "PatchMyPCIntuneCodeSigning_$(Get-Date -Format "MM-dd-yyyy")"
$CertStore_CodeSigning = 'LocalMachine'
$ValidityPeriod_CodeSigning = 12
$NewCert_CodeSigning = @{
    Subject = "CN=$($SubjectName_CodeSigning)"
    CertStoreLocation = "Cert:\$($CertStore_CodeSigning)\My"
    Type = "CodeSigningCert"
    HashAlgorithm = 'sha256'
    KeyExportPolicy = 'NonExportable'
    KeyUsage = 'DigitalSignature'
    KeyAlgorithm = 'RSA'
    KeyLength = 2048
    KeySpec = 'Signature'
    NotAfter = (Get-Date).AddMonths($($ValidityPeriod_CodeSigning))
}
$Cert_CodeSigning = New-SelfSignedCertificate @NewCert_CodeSigning

# Export Public Key
$CertFolder = "$($env:USERPROFILE)\Downloads"
New-Item -Path $CertFolder -ItemType Directory -Force | Out-Null
$CertExport_CodeSigning = @{
Cert = $Cert_CodeSigning
FilePath = "$($CertFolder)\$($SubjectName_CodeSigning).cer"
}
Export-Certificate @CertExport_CodeSigning
