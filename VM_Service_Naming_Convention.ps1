# Variables for common values

 

$resourceGroup = "AAA-Production3"

$location = "West US 2"

$vmName = "AAA-Prod-SVR1"

$SubnetName = "AAA-PROD-SUBNET01"

$NamevNET = "AAA-PROD-VNET"

$Namepublicdns = "AAA-PROD-ADF01-IP01"

$NameNetworkSecurityGroupRuleRDP = 'Default-allow-rdp'

$NameNetworkSecurityGroup = 'AAA-SVR1-NSG'

$NameVNic = "AAA-PROD-VNIC01"

$VMSize = 'Standard_D1_v2'

 

 

# Create user object 

$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

 

# Create a resource group 

New-AzureRmResourceGroup -Name $resourceGroup -Location $location

 

# Create a subnet configuration 

$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix 10.50.1.0/24

  

# Create a virtual network 

$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `

  -Name $NamevNET -AddressPrefix 10.50.1.0/24 -Subnet $subnetConfig

 

# Create a public IP address and specify a DNS name 

$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `

  -Name "$Namepublicdns$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4

 

# Create an inbound network security group rule for port 3389 

$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name $NameNetworkSecurityGroupRuleRDP  -Protocol Tcp `

  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `

  -DestinationPortRange 3389 -Access Allow

 

# Create a network security group 

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `

  -Name $NameNetworkSecurityGroup -SecurityRules $nsgRuleRDP

 

# Create a virtual network card and associate with public IP address and NSG

$nic = New-AzureRmNetworkInterface -Name $NameVNic -ResourceGroupName $resourceGroup -Location $location `

  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

 

# Create a virtual machine configuration

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $VMSize | `

Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `

Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `

Add-AzureRmVMNetworkInterface -Id $nic.Id

 

# Create a virtual machine

New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig 