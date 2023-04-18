$outputfinal=@()
foreach ( $Subscription in $(Get-AzSubscription| Where-Object {$_.State -ne "Disabled"}) )
{
Select-AzSubscription -SubscriptionId $Subscription.SubscriptionId
$nets=Get-AzVirtualNetwork
foreach ($net in $nets)
{
$snets=$net.Subnets
foreach ($snet in $snets)
{
$outputtemp = "" | SELECT  VNET,VNET_AddressSpace,VNET_Location,ResourceGroup,Subnet_Name,Subnet_AddressPrefix
$outputtemp.VNET=$net.Name
$outputtemp.VNET_AddressSpace=$net.AddressSpace.AddressPrefixes.trim('{}')
$outputtemp.VNET_Location=$net.Location
$outputtemp.ResourceGroup=$net.ResourceGroupName
$outputtemp.Subnet_Name=$snet.Name
$outputtemp.Subnet_AddressPrefix=$snet.AddressPrefix.trim('{}')
$outputfinal += $outputtemp
}
}
}
#$outputfinal | Format-Table
$outputfinal | Export-Csv ./clouddrive/.cloudconsole/NETS_"$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv" -NoTypeInformation