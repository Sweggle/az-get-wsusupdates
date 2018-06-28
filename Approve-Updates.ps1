<#

Windows Update WSUS Approver
Last Modified: 28-06-18

Run this on the WSUS Server. You'll need the WindowsUpdate PS Module which can be installed from the PSGallery.
Install-Module WindowsUpdate should do it (with admin creds)

#>

param(

    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetGroup = 'Pilot Group'

)

# Module required to proceed
Import-Module -Name WindowsUpdate

$VerbosePreference = 'Continue'
# Set Log Location
$LogPath = 'C:\WSUSLogs\'
# Log Path Test
if(!(Test-Path -Path $LogPath)) { mkdir $LogPath }
# Set Log File Name
$LogFileName = 'Approve-PilotUpdates-Logfile-' + (Get-Date -Format ddMMyy-HHmmss) + '.log'
# Start Log Transcript
$ErrorActionPreference = 'SilentlyContinue'
Stop-Transcript | Out-Null
$ErrorActionPreference = 'Stop'
Start-Transcript -Path $($LogPath + $LogFileName) -Force

function Approve-Updates {
    
    [CmdletBinding()]
    param(

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Classification,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetGroup,

        [switch]$CheckForMissedApprovals

    )

    # Get the waiting updates for the classification
    $Updates = Get-WsusUpdate -Approval Unapproved -Status FailedOrNeeded -Classification $Classification

    # Approve the updates
    foreach($Update in $Updates) {

        #Approve-WsusUpdate -Update $Update -TargetGroupName $TargetGroup -Action Install -Verbose
        $Message = 'Update Approved: ' + $Update.Update.Title + ' to Target Group ' + $TargetGroup
        Write-Event -Level Information -EventID 10 -Source 'PSWindowsUpdate' -Message $Message
        Write-Verbose $Message

    }

    # If the CheckForMissedApprovals param has been set, we'll go through and check for any updates which were approved previously, but not to this target group
    if($CheckForMissedApprovals) {

        # Get the previously approved updates
        $Updates = Get-WsusUpdate -Classification $Classification -Status FailedOrNeeded -Approval Approved

        # Approve the updates
        foreach($Update in $Updates) {

            #Approve-WsusUpdate -Update $Update -TargetGroupName $TargetGroup -Action Install -Verbose
            $Message = 'Update Approved: ' + $Update.Update.Title + ' to Target Group ' + $TargetGroup
            Write-Event -Level Information -EventID 10 -Source 'PSWindowsUpdate' -Message $Message
            Write-Verbose $Message

        }

    }   
    
} 

function Write-Event {
param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Message,
 
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Error", "Warning", "Information", "FailureAudit", "SuccessAudit")]
    [string]$Level,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int]$EventID,

    [parameter(Mandatory=$false)]
    [string]$Log = "Application",

    [parameter(Mandatory=$false)]
    [string]$Source
)

    if ([System.Diagnostics.EventLog]::SourceExists($source) -eq $false) {
        [System.Diagnostics.EventLog]::CreateEventSource($source, $log)
    }

    Write-EventLog –LogName $log –Source $source –EntryType $level –EventID $eventID –Message $message
}

# Approve the Critical updates
Approve-Updates -Classification Critical -TargetGroup $TargetGroup -CheckForMissedApprovals -Verbose

# Approve the Security updates
Approve-Updates -Classification Security -TargetGroup $TargetGroup -CheckForMissedApprovals -Verbose

# Approve the WSUS updates
Approve-Updates -Classification WSUS -TargetGroup $TargetGroup -CheckForMissedApprovals -Verbose

Stop-Transcript | Out-Null