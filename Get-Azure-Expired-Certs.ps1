﻿#Monitor your Azure Secrets, Certs and SPN’s Expire Date with PowerShell


#Settings
$TimeSpanInDays=90
$MailSender="no-reply@company.com"
$MailRecipient="Cesar.Duran@company.com"

#Azure App Credentials to get Apps and SP
$EXPIRE_AppId = "G4V8Q~sAW4ZzSxUQyzmOownO.q8YNBM9-EihedAC"
$EXPIRE_secret = "2cc70eb0-0ab7-4552-9390-5de2d1c52c26"

$tenantID = "Azure Tenant ID"

#Azure App Credentials to send the Mail
$MAIL_AppId = "G4V8Q~sAW4ZzSxUQyzmOownO.q8YNBM9-EihedAC"
$MAIL_secret = "2cc70eb0-0ab7-4552-9390-5de2d1c52c26"

#STOP HERE!

#Connect to GRAPH API with EXPIRE credentials
$EXPIRE_tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $EXPIRE_AppId
    Client_Secret = $EXPIRE_secret
}
$EXPIRE_tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $EXPIRE_tokenBody
$EXPIRE_headers = @{
    "Authorization" = "Bearer $($EXPIRE_tokenResponse.access_token)"
    "Content-type"  = "application/json"
}



#Connect to GRAPH API with MAIL Credentials
$MAIL_tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $MAIL_AppId
    Client_Secret = $MAIL_secret
}
$MAIL_tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $MAIL_tokenBody
$MAIL_headers = @{
    "Authorization" = "Bearer $($MAIL_tokenResponse.access_token)"
    "Content-type"  = "application/json"
}



#Build Array to store PSCustomObject
$Array = @()



# List Get all Apps from Azure
$URLGetApps = "https://graph.microsoft.com/v1.0/applications"
$AllApps = Invoke-RestMethod -Method GET -Uri $URLGetApps -Headers $EXPIRE_headers



#Go through each App and add to our Array
foreach ($App in $AllApps.value) {

    $URLGetApp = "https://graph.microsoft.com/v1.0/applications/$($App.ID)"
    $App = Invoke-RestMethod -Method GET -Uri $URLGetApp -Headers $EXPIRE_headers

    if ($App.passwordCredentials) {
        foreach ($item in $App.passwordCredentials) {
            $Array += [PSCustomObject]@{
                "Type"           = "AZAPP"
                "displayName"    = $app.displayName
                "ID"             = $App.ID
                "AppID"          = $app.appId
                "SecType"        = "Secret"
                "Secret"         = $item.displayName
                "Secret-EndDate" = (Get-date $item.endDateTime)
            }
        }
    }
    

    if ($App.keyCredentials) {
        foreach ($item in $App.keyCredentials) {
            $Array += [PSCustomObject]@{
                'Type'           = "AZAPP"
                'displayName'    = $app.displayName
                'ID'             = $App.ID
                'AppID'          = $app.appId
                'SecType'        = "Zert"
                'Secret'         = $item.displayName
                'Secret-EndDate' = (Get-date $item.endDateTime)
            }
        }
    }
}




#Get all Service Principals
$servicePrincipals = "https://graph.microsoft.com/v1.0/servicePrincipals"
$SP = Invoke-RestMethod -Method GET -Uri $servicePrincipals -Headers $EXPIRE_headers

$SPList = $SP.value 
$UserNextLink = $SP."@odata.nextLink"

while ($UserNextLink -ne $null) {

    $SP = (Invoke-RestMethod -Uri $UserNextLink -Headers $EXPIRE_headers -Method Get )
    $UserNextLink = $SP."@odata.nextLink"
    $SPList += $SP.value
}

#Go through each SP and add to our Array
foreach ($SAML in $SPList) {
    if ($Saml.passwordCredentials) {
        foreach ($PW in $Saml.passwordCredentials) {
            $Array += [PSCustomObject]@{
                'Type'           = "SP"
                'displayName'    = $SAML.displayName
                'ID'             = $SAML.id
                'AppID'          = $Saml.appId
                'SecType'        = "Secret"
                'Secret'         = $PW.displayName
                'Secret-EndDate' = (Get-date $PW.endDateTime)
            }
        }
    }
}



$ExpireringZerts = $Array | Where-Object -Property Secret-EndDate -Value (Get-Date).AddDays($TimeSpanInDays) -lt  | Where-Object -Property Secret-EndDate -Value (Get-Date) -gt

foreach ($Zert in $ExpireringZerts) {
    $HTML = $Zert | Convertto-HTML -Fragment -As List

    $URLsend = "https://graph.microsoft.com/v1.0/users/$MailSender/sendMail"
    
    $BodyJsonsend = @"
                        {
                            "message": {
                              "subject": "Azure App or SPN will expire soon $($Zert.displayName)",
                              "body": {
                                "contentType": "HTML",
                                "content": "$HTML
                                <br>
                                Michael Seidl (au2mator)
                                <br>

                                "
                              },
                              "toRecipients": [
                                {
                                  "emailAddress": {
                                    "address": "$MailRecipient"
                                  }
                                }
                              ]
                            },
                            "saveToSentItems": "false"
                          }
"@
    
    Invoke-RestMethod -Method POST -Uri $URLsend -Headers $MAIL_headers -Body $BodyJsonsend
}