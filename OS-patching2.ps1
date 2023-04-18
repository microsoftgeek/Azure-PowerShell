#Disclaimer 

#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever 
#(including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages. 
 
#******************************************************************************************* 
# Sign in to your Azure account 
#******************************************************************************************* 
Connect-AzAccount


#******************************************************************************************* 
# Get your AD subscription ID 
#******************************************************************************************* 
Get-AzSubscription | Sort Name,SubscriptionID | Select Name,SubscriptionID


#******************************************************************************************* 
# Set your Azure subscription. Replace everything within the quotes, 
# including the < and > characters, with the correct SubscriptionID 
#******************************************************************************************* 
$subscrID="<SubscriptionID>" 
Select-AzSubscription -SubscriptionID $subscrID 


#******************************************************************************************* 
# Set parameters 
#******************************************************************************************* 
$rgName="Tier0Infrastructure" 
$locName="West Europe" 
$AutoAccName="Tier0InfrastructureAutomation" 
$WSName="Tier0InfrastructureWS" 
$solution="Updates" 


#******************************************************************************************* 
# Create new resource group. Adjust location if you want a different one 
#******************************************************************************************* 
New-AzResourceGroup -Name $rgName -Location $locName 
New-AzAutomationAccount -Name $AutoAccName -Location $locName -ResourceGroupName $rgName 
New-AzOperationalInsightsWorkspace -Location $locName -Name $WSName -Sku Standard -ResourceGroupName $rgName 
Set-AzOperationalInsightsIntelligencePack -ResourceGroupName $rgName -WorkspaceName $WSName -IntelligencePackName $solution -Enabled $true 