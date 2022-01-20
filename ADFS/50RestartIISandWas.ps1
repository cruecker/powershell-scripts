$ExchangeServer = Get-ExchangeServer
ForEach ($Server in $ExchangeServer) {Invoke-Command -ScriptBlock {Restart-Service W3SVC,WAS -force}}
ForEach ($Server in $ExchangeServer) {Invoke-Command -ScriptBlock {get-Service W3SVC,WAS}}
