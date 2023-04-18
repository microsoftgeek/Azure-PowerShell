#Get VM Reboot Logs

$today = get-date
$yest = $today.AddDays(-1)
Get-AzureDeploymentEvent -ServiceName kenaztestdemoservice -StartTime $yest -EndTime $today