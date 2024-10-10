<#

Stolen from:
https://www.recastsoftware.com/resources/configmgr-docs/configmgr-community-tools/osd-cloud-with-configmgr/
https://github.com/gwblok/garytown/blob/master/OSD/CloudOSD/CreateCloudOSDUnattendXML.ps1

This Script will: 

Pre-populate the Unattend that is automatically generated by ConfigMgr's OSD "Apply OS Image" Step.
 - Add Command to support OSDCloud
Create TS Variables required for the following steps to still work without the "Apply OS Image" Step
 - Apply Windows Settings
 - Apply Network Settings
 - Setup Windows and Configuration Manager
 
TS Variables Created:
 - OSArchitecture
 - OSDAnswerFilePath
 - OSDInstallType
 - OSDTargetSystemRoot
 - OSVersionNumber
 - OSDTargetSystemDrive
 - OSDTargetSystemPartition
 
#>

try {
    # Initialize the Task Sequence Environment
    $TSEnviornment = New-Object -ComObject Microsoft.SMS.TSEnvironment
}
catch {
    # Output message if not in a Task Sequence environment
    Write-Output "Not in Task Sequence"
}

if ($TSEnviornment) {
    #region Create the Group Policies
    $TSVariables = @(
        @{ Name = "OSArchitecture"; Value = "X64" },
        @{ Name = "OSDAnswerFilePath"; Value = "C:\WINDOWS\panther\unattend\unattend.xml" },
        @{ Name = "OSDInstallType"; Value = "Sysprep" },
        @{ Name = "OSDTargetSystemRoot"; Value = "C:\WINDOWS" },
        @{ Name = "OSVersionNumber"; Value = "10.0" },
        @{ Name = "OSDTargetSystemDrive"; Value = "C:" },
        @{ Name = "OSDTargetSystemPartition"; Value = "0-3" }
    )

    foreach ($TSVariable in $TSVariables) {
        # Create and set the Task Sequence Variable
        Write-Output "Creating Task Sequence Variable: [$($TSVariable.Name)] | Set to: [$($TSVariable.Value)]"
        $TSEnviornment.Value("$($TSVariable.Name)") = "$($TSVariable.Value)"
    }
}
else {
    Write-Output "Not in Task Sequence"
}

# Default ConfigMgr XML auto generated by CM OSD's Apply OS Image Step
[XML]$XMLUnattend = @"
<?xml version="1.0"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
	<settings xmlns="urn:schemas-microsoft-com:unattend"
	          pass="oobeSystem">
		<component name="Microsoft-Windows-Shell-Setup"
		           language="neutral"
		           processorArchitecture="amd64"
		           publicKeyToken="31bf3856ad364e35"
		           versionScope="nonSxS"
		           xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
		           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<OOBE>
				<NetworkLocation>Work</NetworkLocation>
				<ProtectYourPC>1</ProtectYourPC>
				<HideEULAPage>true</HideEULAPage>
			</OOBE>
		</component>
		<component name="Microsoft-Windows-International-Core"
		           language="neutral"
		           processorArchitecture="amd64"
		           publicKeyToken="31bf3856ad364e35"
		           versionScope="nonSxS"
		           xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
		           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<SystemLocale>en-US</SystemLocale>
		</component>
	</settings>
	<settings xmlns="urn:schemas-microsoft-com:unattend"
	          pass="specialize">
		<component name="Microsoft-Windows-Deployment"
		           language="neutral"
		           processorArchitecture="amd64"
		           publicKeyToken="31bf3856ad364e35"
		           versionScope="nonSxS"
		           xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
		           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<RunSynchronous>
				<RunSynchronousCommand>
					<Order>1</Order>
					<Description>disable user account page</Description>
					<Path>reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Setup\OOBE /v UnattendCreatedUser /t REG_DWORD /d 1 /f</Path>
				</RunSynchronousCommand>
			</RunSynchronous>
		</component>
	</settings>
</unattend>
"@

# OSDCloud Specialize XML - Remove if it exists as this is for the OOBE Phase
$OSDCloudXMLPath = "C:\windows\panther\Invoke-OSDSpecialize.xml"
if (Test-Path $OSDCloudXMLPath) {
    # Remove File
    Write-Output "Remove File: [$($OSDCloudXMLPath)]"
    Remove-Item $OSDCloudXMLPath -Force
}

# Set the Unattend Folder Path
$UnattendFolderPath = "C:\WINDOWS\panther\unattend"
$UnattendFilePath = "$UnattendFolderPath\unattend.xml"

### Create the Unattend Folder
Write-Output "Create Unattend folder: [$($UnattendFolderPath)]"
$null = New-Item -ItemType Directory -Path $UnattendFolderPath -Force
# Create a temporary file
$XMLUnattend.Save("$UnattendFolderPath\unattend.tmp")


### Create the Unattend XML File
Write-Output "Creating Unattend File: [$($UnattendFilePath)]"
# Create a new UTF8 encoding object without a byte order mark (BOM)
$Encoding = New-Object System.Text.UTF8Encoding($false)
# Create a new XMLTextWriter object to write the XML file with UTF8 encoding
$XMLTextWriter = New-Object System.XML.XMLTextWriter("$($UnattendFilePath)", $Encoding)
# Set the formatting of the XML to be indented
$XMLTextWriter.Formatting = 'Indented'
# Save the XML content to the file using the XMLTextWriter
$XMLUnattend.Save($XMLTextWriter)
# Close the XMLTextWriter to release resources
$XMLTextWriter.Close()

if (Test-Path -Path "$UnattendFilePath") {
    Write-CMTraceLog -Message "Successfully Created Unattend File: [$($UnattendFilePath)]" -Type 1
}