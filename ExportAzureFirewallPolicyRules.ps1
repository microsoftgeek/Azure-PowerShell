#Import-Module -Name Az -Force

#connect
#Connect-AzAccount -Tenant 'shutterfly.onmicrosoft.com' -SubscriptionId '5fbc0d4d-b0b0-4215-ba2b-b03dc3ec3526'


#Provide Input. Firewall Policy Name, Firewall Policy Resource Group & Firewall Policy Rule Collection Group Name
$fpname = "Azure-Firewall-Parent-Policy"
$fprg = "Network-Prod-RG"
$fprcgname = "DefaultApplicationRuleCollectionGroup"

$fp = Get-AzFirewallPolicy -Name $fpname -ResourceGroupName $fprg
$rcg = Get-AzFirewallPolicyRuleCollectionGroup -Name $fprcgname -AzureFirewallPolicy $fp

$returnObj = @()
foreach ($rulecol in $rcg.Properties.RuleCollection) {

foreach ($rule in $rulecol.rules)
{
$properties = [ordered]@{
    RuleCollectionName = $rulecol.Name;
    RulePriority = $rulecol.Priority;
    ActionType = $rulecol.Action.Type;
    RUleConnectionType = $rulecol.RuleCollectionType;
    Name = $rule.Name;
    protocols = $rule.protocols -join ", ";
    SourceAddresses = $rule.SourceAddresses -join ", ";
    #DestinationAddresses = $rule.DestinationAddresses -join ", ";
    DestinationAddresses = $rule.Destination -join ", ";
    SourceIPGroups = $rule.SourceIPGroups -join ", ";
    DestinationIPGroups = $rule.DestinationIPGroups -join ", ";
    DestinationPorts = $rule.DestinationPorts -join ", ";
    DestinationFQDNs = $rule.DestinationFQDNs -join ", ";
}
$obj = New-Object psobject -Property $properties
$returnObj += $obj
}

#change c:\temp to the path to export the CSV
$returnObj | Export-Csv c:\temp\west\app3rules.csv -NoTypeInformation
}
