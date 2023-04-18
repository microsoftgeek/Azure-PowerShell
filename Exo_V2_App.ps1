##Connect to AzureAD with Global Admin creds
#Import-Module AzureAD
#Connect-AzureAD


# CODE TO REGISTER APP, ASSIGN API PERMISSIONS, AND ENABLE SERVICE PRINCIPAL
## Define the client app name
$appName = 'Exo_V2_App'

## Get the Office 365 Exchange Online API details.
$api = (Get-AzureADServicePrincipal -Filter "AppID eq '00000002-0000-0ff1-ce00-000000000000'")

## Get the API permission ID
$permission = $api.AppRoles | Where-Object { $_.Value -eq 'Exchange.ManageAsApp' }

## Build the API permission object (TYPE: Role = Application, Scope = User)
$apiPermission = [Microsoft.Open.AzureAD.Model.RequiredResourceAccess]@{
    ResourceAppId  = $api.AppId ;
    ResourceAccess = [Microsoft.Open.AzureAD.Model.ResourceAccess]@{
        Id   = $permission.Id ;
        Type = "Role"
    }
}

## Register the new Azure AD App with API Permissions
$myApp = New-AzureADApplication -DisplayName $appName -ReplyUrls 'http://localhost' -RequiredResourceAccess $apiPermission

## Enable the Service Principal
$mySP = New-AzureADServicePrincipal -AppID $myApp.AppID

## Display the new app properties
$myApp | Format-List DisplayName,ObjectID,AppID


#STOP HERE#
#####################################################################################################
##Export the property values of the application using this command below
$myApp | Export-Csv -NoTypeInformation "$($appName).csv"



## The role to assign to your app
$directoryRole = 'Exchange Administrator'

## Find the ObjectID of 'Exchange Service Administrator'
$RoleId = (Get-AzureADDirectoryRole | Where-Object {$_.displayname -eq $directoryRole}).ObjectID

## Add the service principal to the directory role
Add-AzureADDirectoryRoleMember -ObjectId $RoleId -RefObjectId $mySP.ObjectID -Verbose



#STOP HERE#
#####################################################################################################
##Generating and Attach a Self-Signed Certificate to the Application
$appName = 'Exo_V2_App'

## Number of years of certificate validity
$certYears = 3

## Certificate (PFX) password
$certPassword = '#aMUdU*h$+UY27'

.\Create-SelfSignedCertificate.ps1 -CommonName $appName `
-StartDate (Get-Date).AddDays(-1) `
-EndDate (Get-Date).AddYears($certYears) `
-Password (ConvertTo-SecureString $certPassword -AsPlainText -Force) `
-Force


#STOP HERE#
#####################################################################################################
##The next step is to upload the certificate that you’ve just created to your Azure AD app

## Get the certificate file (.CER)
#$CertificateFilePath = (Resolve-Path ".\$($appName).cer").Path
$CertificateFilePath = "C:\Scripts\Azure\Exo_V2_App.cer"

## Create a new certificate object
$cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cer.Import("$($CertificateFilePath)")
$bin = $cer.GetRawCertData()
$base64Value = [System.Convert]::ToBase64String($bin)
$bin = $cer.GetCertHash()
$base64Thumbprint = [System.Convert]::ToBase64String($bin)

## Upload and assign the certificate to application in AzureAD
$null = New-AzureADApplicationKeyCredential -ObjectId $myApp.ObjectID `
-CustomKeyIdentifier $base64Thumbprint `
-Type AsymmetricX509Cert -Usage Verify `
-Value $base64Value `
-StartDate ($cer.NotBefore) `
-EndDate ($cer.NotAfter)


#STOP HERE#
#####################################################################################################
##Granting Admin Consent to the Application

## Get the TenantID
$tenantID = (Get-AzureADTenantDetail).ObjectID

## Browse this URL
$consentURL = "https://login.microsoftonline.com/$tenantID/adminconsent?client_id=$($myApp.AppId)"

## Display the consent URL
$consentURL

## Launch the consent URL using the default browser
Start-Process $consentURL


#STOP HERE#
#####################################################################################################
# CODE TO IMPORT THE PFX CERTIFICATE INTO THE CURRENT PERSONAL CERTIFICATE STORE
## Set the certificate file path (.pfx)
$CertificateFilePath = 'C:\scripts\exo_v2_demo\Exo_V2_App.pfx'

## Get the PFX password
$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'

## Import the PFX certificate to the current user's personal certificate store.
Import-PfxCertificate -FilePath $CertificateFilePath -CertStoreLocation Cert:\CurrentUser\My -Password $mypwd.Password