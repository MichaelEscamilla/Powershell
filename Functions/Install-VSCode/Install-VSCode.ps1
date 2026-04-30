$winget = Get-Command -Name 'winget' -ErrorAction SilentlyContinue

$OverrideCommands = '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'

& $winget.Source install --id Microsoft.VisualStudioCode -e -h --override $OverrideCommands --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) {
    throw "[$(Get-Date -format s)] [$($MyInvocation.MyCommand.Name)] Visual Studio Code installation failed with exit code $LASTEXITCODE."
}
    

Write-Host "[$(Get-Date -format s)] Visual Studio Code installation completed successfully." -ForegroundColor Green
