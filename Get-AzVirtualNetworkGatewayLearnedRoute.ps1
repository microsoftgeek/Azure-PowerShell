﻿Get-AzVirtualNetworkGatewayLearnedRoute -VirtualNetworkGatewayName <virutal-gateway-name> -ResourceGroupName <vng-resource-group-name> | Sort-Object -Property Network | Format-Table