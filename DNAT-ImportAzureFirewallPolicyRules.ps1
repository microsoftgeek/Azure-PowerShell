#Provide Input. Firewall Policy Name, Firewall Policy Resource Group & Firewall Policy Rule Collection Group Name
$fpname = "Cesar-TESTFirewall-Policy"
$fprg = "Network-Prod-RG"
$fprcgname = "DefaultApplicationRuleCollectionGroup"

$targetfp = Get-AzFirewallPolicy -Name $fpname -ResourceGroupName $fprg
$targetrcg = New-AzFirewallPolicyRuleCollectionGroup -Name $fprcgname -Priority 300 -FirewallPolicyObject $targetfp

$RulesfromCSV = @()
# Change the folder where the CSV is located
$readObj = import-csv C:\temp\west\apprules.csv
foreach ($entry in $readObj)
{
    $properties = [ordered]@{
        RuleCollectionName = $entry.RuleCollectionName;
        RulePriority = $entry.RulePriority;
        ActionType = $entry.ActionType;
        Name = $entry.Name;
        protocols = $entry.protocols -split ", ";
        SourceAddresses = $entry.SourceAddresses -split ", ";
        DestinationAddresses = $entry.DestinationAddresses -split ", ";
        SourceIPGroups = $entry.SourceIPGroups -split ", ";
        DestinationIPGroups = $entry.DestinationIPGroups -split ", ";
        DestinationPorts = $entry.DestinationPorts -split ", ";
        DestinationFQDNs = $entry.DestinationFQDNs -split ", ";
    }
    $obj = New-Object psobject -Property $properties
    $RulesfromCSV += $obj
}

$RulesfromCSV
#Clear-Variable -Name rules
$rules = @()
foreach ($entry in $RulesfromCSV)
{
    $RuleParameter = @{
        Name = $entry.Name;
        Protocol = $entry.protocols
        sourceAddress = $entry.SourceAddresses
        DestinationAddress = $entry.DestinationAddresses
        DestinationPort = $entry.DestinationPorts
    }
    $rule = New-AzFirewallPolicyNetworkRule @RuleParameter
    $ApplicationRuleCollection = @{
        Name = $entry.RuleCollectionName
        Priority = $entry.RulePriority
        ActionType = $entry.ActionType
        Rule       = $rules += $rule
    }
}

# Create a network rule collection
$ApplicationRuleCategoryCollection = New-AzFirewallPolicyFilterRuleCollection @ApplicationRuleCollection

# Deploy to created rule collection group
Set-AzFirewallPolicyRuleCollectionGroup -Name $targetrcg.Name -Priority 300 -RuleCollection $ApplicationRuleCategoryCollection -FirewallPolicyObject $targetfp