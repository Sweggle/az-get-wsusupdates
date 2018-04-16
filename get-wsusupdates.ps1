Start-Sleep -s 480
(Get-WsusServer).GetSubscription().StartSynchronization()