<#
    All stolen from Garytown.com

    It's his fault for being awesome.
#>

# OS and Agent URL
$URL_OSImage = "http://hpsr511.blob.core.windows.net/public/OSImages/$($build)/Custom.mft"
$URL_Agent = "http://hpsr511.blob.core.windows.net/public/SRAgent"

# OS Build
$OS_Build = 'Win11'

# Locations - Source Folder Structure
$HostRoot = "C:\HP"
$SureRecoverRoot = "$HostRoot\SureRecover" 
$SourceMedia = "$SureRecoverRoot\Sources"
$SourceOS = "$SourceMedia\OSImages\$OS_Build"
$SourceAgent = "$SourceMedia\SRAgent"

# Locations - Sure Recover
$SureRecoverWorkingpath = "$SureRecoverRoot\HPSRStaging"  #Staging Area
$SureRecoverWorkingpath = "$SureRecoverRoot\HPSRStaging_OSDCloud"  #Staging Area
$PayloadFiles = "$SureRecoverRoot\Payloads"
$KeyPath = "$HostRoot\SureRecover\Certificates"  #Location you're keeping your Certs
$ImagePath = "$SureRecoverWorkingpath\OSImages\$Build"  #Location of the Windows Install WIM #Used to split the image with DISM
$AgentPath = "$SureRecoverWorkingpath\SRAgent"

# Locations - Certificates
$CertPswd = 'Sy5gqJt8G4FKSk'
$EndorsementKeyFile = "$KeyPath\Secure Platform-Endorsement Key.pfx"  #Created & downloaded from HP Connect
$SigningKeyFile = "$KeyPath\Secure Platform-Signing Key.pfx"  #Created & downloaded from HP Connect
$CertSubject = "/C=US/ST=CA/L=Admin/O=MTA/OU=LAB/CN=michaeltheadmin.com"
$OSImageCertFile = "$KeyPath\os.pfx"
$AgentImageCertFile = "$KeyPath\re.pfx"

# Locations - OpenSSL
$OpenSSLPath = "C:\Program Files\OpenSSL-Win64\bin"
$OpenSSLFilePath = Join-Path $OpenSSLPath "openssl.exe"
Set-Location $OpenSSLPath  #Needs to be in this path to allow the openssl to create the certs.

### Create Folder Structure
# Source Folder Structure
if (!(Test-Path -path $HostRoot)) {
    New-Item -Path $HostRoot -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $SureRecoverRoot)) {
    New-Item -Path $SureRecoverRoot -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $SourceMedia)) {
    New-Item -Path $SourceMedia -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $SourceOS)) {
    New-Item -Path $SourceOS -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $SourceAgent)) {
    New-Item -Path $SourceAgent -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $SureRecoverWorkingpath)) {
    New-Item -Path $SureRecoverWorkingpath -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $KeyPath)) {
    New-Item -Path $KeyPath -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $ImagePath)) {
    New-Item -Path $ImagePath -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $AgentPath)) { 
    New-Item -Path $AgentPath -ItemType Directory -Force | Out-Null 
}
if (!(Test-Path -path $PayloadFiles)) { 
    New-Item -Path $PayloadFiles -ItemType Directory -Force | Out-Null 
}

### Generate Private & Public PEM Files - Do this Once and don't do it again... just don't lose those files
# Create CA Root Cert
if (!(Test-Path -Path "$KeyPath\ca.key")) {
    #Only Create Once
    .\openssl req -sha256 -nodes -x509 -newkey rsa:2048 -keyout "$KeyPath\ca.key" -out "$KeyPath\ca.crt" -subj "$CertSubject"
}
# OS
if (!(Test-Path -Path "$KeyPath\os.key")) {
    #Only Create Once
    .\openssl req -sha256 -nodes -newkey rsa:2048 -keyout "$KeyPath\os.key" -out "$KeyPath\os.csr" -subj "$CertSubject"
    .\openssl x509 -req -sha256 -in "$KeyPath\os.csr" -CA "$KeyPath\ca.crt" -CAkey "$KeyPath\ca.key" -CAcreateserial -out "$KeyPath\os.crt"
    .\openssl pkcs12 -inkey "$KeyPath\os.key" -in "$KeyPath\os.crt" -export -out "$KeyPath\os.pfx"  -CSP "Microsoft Enhanced RSA and AES Cryptographic Provider" -passout "pass:$CertPswd"
}
# RE
if (!(Test-Path -Path "$KeyPath\re.key")) {
    #Only Create Once
    .\openssl req -sha256 -nodes -newkey rsa:2048 -keyout "$KeyPath\re.key" -out "$KeyPath\re.csr" -subj "$CertSubject"
    .\openssl x509 -req -sha256 -in "$KeyPath\re.csr" -CA "$KeyPath\ca.crt" -CAkey "$KeyPath\ca.key" -CAcreateserial -out "$KeyPath\re.crt"
    .\openssl pkcs12 -inkey "$KeyPath\re.key" -in "$KeyPath\re.crt" -export -out "$KeyPath\re.pfx"  -CSP "Microsoft Enhanced RSA and AES Cryptographic Provider" -passout "pass:$CertPswd"
}

### Build Manifest File - Agent / Boot image
# MFT File
$MFT_Filename = "recovery.mft"
# SIG File
$SIG_FileName = "recovery.sig"
# Remove existing versions of the Files
Remove-Item -Path "$AgentPath\$MFT_Filename" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$AgentPath\$SIG_FileName" -Force -ErrorAction SilentlyContinue
# Image Version : Not extactly sure what this is for - Any 16-bit Integer
$ImageVersion = '2023'
# Build Header
$Header = "mft_version=1, image_version=$ImageVersion"
# Create the File - MFT File
Out-File -Encoding UTF8 -FilePath $SureRecoverWorkingpath\$MFT_Filename -InputObject $header
# Get all the files within the $AgentPath
$Files = Get-ChildItem -Path $AgentPath -Recurse | Where-Object { $_.PSIsContainer -eq $false }
# Sorting Command
$ToNatural = { [regex]::Replace($_, '\d*\....$', { $args[0].Value.PadLeft(50) }) }
# Sort Files
$Files = $Files | Sort-Object $ToNatural
# Files Count
$Total = $Files.Count
$Current_File = 1
# Manifest Folder
$Manifest_Path = $AgentPath
# Loop through the Files
foreach ($File in $Files) {
    #Write-Progress -Activity "Generating manifest" -Status "$Current_File of $Total ($File)" -PercentComplete ($Current_File / $Total * 100)
    Write-Host "File: [$($File.Name)]"
    # Get Hash of current file
    $hashObject = Get-FileHash -Algorithm SHA256 -Path $File.FullName
    # Set Hash to all Lowercase
    $fileHash = $hashObject.Hash.ToLower()
    # Remove the beginging part of the Path
    $filePath = $hashObject.Path.Replace($Manifest_Path + '\', '').ToLower()
    # Get File Name Length
    $fileSize = (Get-Item $File.FullName).length
    # Build Manifest Content
    $manifestContent = "$fileHash $filePath $fileSize"
    # Add Manifest Content to File
    Out-File -Encoding utf8 -FilePath $SureRecoverWorkingpath\$MFT_Filename -InputObject $manifestContent -Append
    # Increment Counter
    $Current_File = $Current_File + 1
}
# Get Manifest File Content
$Content = Get-Content $SureRecoverWorkingpath\$MFT_Filename
# Encoding Object
$Encoding = New-Object System.Text.UTF8Encoding $False
# Encode Manifest
[System.IO.File]::WriteAllLines($Manifest_Path + '\' + $MFT_Filename, $Content, $Encoding)


# You can sign the agent manifest with this command
Write-Host "Signing Manifest File"
.\openssl dgst -sha256 -sign $AgentImageCertFile -passin pass:$CertPswd -out "$AgentPath\$SIG_FileName" "$AgentPath\$MFT_Filename"

# Increment this number each time you make a change to the Payload file (like change the URL).  It does NOT need to be changed if you update an image or agent media.  Only if you change certificates or URLs.
[int16]$Version = 13

#Create the HP Secure Platform Payload Files - Provisining Secure Platform - Endorsement & Signing Payloads
Write-Host "Creating Payload - Endorsement Key..."
New-HPSecurePlatformEndorsementKeyProvisioningPayload -EndorsementKeyFile $EndorsementKeyFile -EndorsementKeyPassword $CertPswd -OutputFile "$PayloadFiles\SPEndorsementKeyPP.dat"

Write-Host "Creating Payload - Signing Key..."
New-HPSecurePlatformSigningKeyProvisioningPayload -EndorsementKeyFile $EndorsementKeyFile -EndorsementKeyPassword $CertPswd -SigningKeyFile $SigningKeyFile -SigningKeyPassword $CertPswd -OutputFile "$PayloadFiles\SPSigningKeyPP.dat"

# Create Payload - AgentFile - Only needed if hosting your own Agent (which is optional)
Write-Host "Creating Payload - Agent Image..."
New-HPSureRecoverImageConfigurationPayload -Image agent -SigningKeyFile $SigningKeyFile -SigningKeyPassword $CertPswd -ImageCertificateFile $AgentImageCertFile -ImageCertificatePassword $CertPswd -Url $URL_Agent -Version $Version  -OutputFile "$PayloadFiles\AgentPayload.dat" -Verbose

# Create Payload - Trigger
New-HPSureRecoverTriggerRecoveryPayload -SigningKeyFile $SigningKeyFile -SigningKeyPassword $CertPswd -ErasePolicy EraseSecureStorage -OutputFile "$PayloadFiles\TriggerPayload.dat"

#Create Deprovisioning Payloads - For when you want to change your Sure Recover Settings, you need to deprovision first (or at least I've had to in my test machine)
New-HPSureRecoverDeprovisionPayload -SigningKeyFile $SigningKeyFile -SigningKeyPassword $CertPswd -OutputFile "$PayloadFiles\SureRecoverDeprovision.dat"
New-HPSecurePlatformDeprovisioningPayload -Verbose -EndorsementKeyFile $EndorsementKeyFile -EndorsementKeyPassword $CertPswd -OutputFile "$PayloadFiles\SecurePlatformDeprovision.dat"