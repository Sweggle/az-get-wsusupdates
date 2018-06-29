$VerbosePreference = 'Continue'
# Set Log Location
$LogPath = 'C:\WSUSLogs\'
# Log Path Test
if(!(Test-Path -Path $LogPath)) { mkdir $LogPath }
# Set Log File Name
$LogFileName = 'Chocolatey-Updates-' + (Get-Date -Format ddMMyy-HHmmss) + '.log'
# Start Log Transcript
$ErrorActionPreference = 'SilentlyContinue'
Stop-Transcript | Out-Null
$ErrorActionPreference = 'Stop'
Start-Transcript -Path $($LogPath + $LogFileName) -Force
# Upgrade all packages
choco upgrade all --yes --verbose
# Finished!
Stop-Transcript | Out-Null