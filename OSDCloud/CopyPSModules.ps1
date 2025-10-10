# Get all PowerShell modules in the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$modules = Get-ChildItem -Path $scriptDirectory -Recurse -Directory | Where-Object {
    Test-Path -Path (Join-Path -Path $_.FullName -ChildPath "*.psm1")
}

# Define the destination path for the modules
$destinationPath = Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell\Modules"

# Copy each module to the destination path
foreach ($module in $modules) {
    $destination = Join-Path -Path $destinationPath -ChildPath $module.Name
    Copy-Item -Path $module.FullName -Destination $destination -Recurse -Force
    Write-Host "Copied module '$($module.Name)' to '$destination'"
}

# Import the copied modules
foreach ($module in $modules) {
    $modulePath = Join-Path -Path $destinationPath -ChildPath $module.Name
    Import-Module -Name $modulePath -Force
    Write-Host "Imported module '$($module.Name)' from '$modulePath'"
}