Write-Output "$HR Connect Using A Service Principal and Secret Based Authentication

##########################################################################################
#
#                  *STAGE.COM AzureAD v1 Connect Script* 
#                                                                                
# Created by Cesar Duran                                                                                       
# Version:1.0                                                                                                                                        
#
#                                                                                                                                                                                                                                                                                                                                                                                                                                 
#                                                                                                                                                                                                          
###########################################################################################

$HR"

##Connect Using A Service Principal and Secret Based Authentication

# Line delimiter
$HR = "`n{0}`n" -f ('='*20)


########################################
Write-Output "$HR CONNECT TO AZUREAD $HR"
########################################


##Install MSFT Graph & MSAL.PS module for all users (requires admin rights)
#Install-Module MSAL.PS -Scope AllUsers -Force -Verbose
#Install-Module Microsoft.Graph -Scope AllUsers -Force -Verbose


############################
##PowerShell Function and Variable Issue Fix

# Increase the Function Count
$MaximumFunctionCount = 8192
$MaximumVariableCount = 8192
$MaximumAliasCount = 8192
$MaximumErrorCount = 8192
$MaximumHistoryCount = 8192
$MaximumDriveCount = 8192

#############################

 
#Generate Access Token to use in the connection string to MSGraph
$AppId = 'd6a8681c-851e-4c51-96d1-8455129a7355'
$TenantId = '85f78c4c-ad11-4735-9624-0b2c11611dff'
$ClientSecret = 'AWM8Q~TposzB43.bjtdJd1fAlNzE906GSWSJzcGd'

Import-Module MSAL.PS -Force -Verbose
#Import-Module Microsoft.Graph -Force -Verbose

$MsalToken = Get-MsalToken -TenantId $TenantId -ClientId $AppId -ClientSecret ($ClientSecret | ConvertTo-SecureString -AsPlainText -Force)
 
#Connect to Graph using access token
Connect-Graph -AccessToken $MsalToken.AccessToken

#Get Top 2 sample objects of Get-MgUser
Get-MgUser -Top 2 | select UserPrincipalName, DisplayName

###################################################################################################################################################################


######################################
Write-Output "$HR 5 SECOND PAUSE $HR"
# 5sec Pause

$Timeout = 5
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 5 seconds
######################################

Write-Output "$HR Connect Using A Service Principal and Secret Based Authentication

##########################################################################################
#
#                  *STAGE.COM AzureAD v2 Connect Script* 
#                                                                                
# Created by Cesar Duran                                                                                       
# Version:1.0                                                                                                                                        
#
#                                                                                                                                                                                                                                                                                                                                                                                                                                 
#                                                                                                                                                                                                          
###########################################################################################

$HR"

##Generate Access Token to use in the connection string to MSGraph
$AAD_MAuth_AppId = "d6a8681c-851e-4c51-96d1-8455129a7355"
$AAD_MAuth_secret = "AWM8Q~TposzB43.bjtdJd1fAlNzE906GSWSJzcGd"

$tenantID = "85f78c4c-ad11-4735-9624-0b2c11611dff"



#Connect to GRAPH API with credentials
$AAD_MAuth_tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $AAD_MAuth_AppId
    Client_Secret = $AAD_MAuth_secret
}
$AAD_MAuth_tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $AAD_MAuth_tokenBody

$AAD_MAuth_headers = @{
    "Authorization" = "Bearer $($AAD_OAuth_tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

#######################################################################################################################################################################


######################################
Write-Output "$HR 5 SECOND PAUSE $HR"
# 5sec Pause

$Timeout = 5
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 5 seconds
######################################



Write-Output "$HR Connect Using A Service Principal and Secret Based Authentication

##########################################################################################
#
#                  *EXOv2 Connect Script* 
#                                                                                
# Created by Cesar Duran                                                                                       
# Version:1.0                                                                                                                                        
#
#                                                                                                                                                                                                                                                                                                                                                                                                                                 
#                                                                                                                                                                                                          
###########################################################################################

$HR"


########################################
Write-Output "$HR CONNECT TO EXO $HR"
########################################

#use the EXO V2 Module for Unattended Scripts


#Step3: Pass the PSCredential to the EXO V2 module
#Install-Module -Name ExchangeOnlineManagement -Force -Verbose
Update-Module -Name ExchangeOnlineManagement -Force -Verbose
Import-Module -Name ExchangeOnlineManagement -Force -Verbose


##Connect to Exchange Online PowerShell using a local certificate
## set the tenant ID (directory ID or domain)
$tenantID = 'ind.onmicrosoft.com'

## Set the Exo_V2_App app id
$appID = 'd3003aec-cb3f-4147-a34a-595cfddb388e'

## Set the certificate file path (.pfx)
$CertificateFilePath = 'C:\Scripts\Azure\Exo_V2_App.pfx'

## Get the PFX password
$pfxPassword = '#aMUdU*h$+UY27'

## Connect to Exchange Online
Connect-ExchangeOnline -CertificateFilePath $CertificateFilePath `
-CertificatePassword (ConvertTo-SecureString -String $pfxPassword -AsPlainText -Force) `
-AppID $appID `
-Organization $tenantID


## Get All Mailbox
Write-Output "Getting sample mailboxes"
Get-EXOMailbox | Format-Table Name,DisplayName



#####################################################################################################
## THIS IS A SECOND METHOD TO AUTHENTICATE

## set the tenant ID (directory ID or domain)
#$tenantID = 'ind.onmicrosoft.com'

## Set the Exo_V2_App app id
#$appID = 'd3003aec-cb3f-4147-a34a-595cfddb388e'

## Set the certificate thumbprint
#$CertificateThumbPrint = 'THUMBPRINT-NUMBER-GOES-HERE'

## Connect to Exchange Online
#Connect-ExchangeOnline -CertificateThumbPrint $CertificateThumbPrint `
#-AppID $appID `
#-Organization $tenantID

## Get All Mailbox
#Write-Output "Getting sample mailboxes"
#Get-EXOMailbox | Format-Table Name,DisplayName