# Check for the WindowsUpdate module and if it doesnt exist - Install it. 
if((Test-Path -Path 'C:\Program Files\WindowsPowerShell\Modules\WindowsUpdate\WindowsUpdate.psm1') -eq $null) { 

    mkdir 'C:\Program Files\WindowsPowerShell\Modules\WindowsUpdate'

    Invoke-WebRequest -Uri https://raw.githubusercontent.com/adbertram/Random-PowerShell-Work/master/Software%20Updates/WindowsUpdate.psm1 -OutFile 'C:\Program Files\WindowsPowerShell\Modules\WindowsUpdate\WindowsUpdate.psm1'

}

Import-Module WindowsUpdate

Get-WindowsUpdate -ComputerName $env:COMPUTERNAME -Verbose

Install-WindowsUpdate -ComputerName $env:COMPUTERNAME -Verbose

Restart-Computer -Force