﻿# Outlook REST Api functions

function Send-OutlookMessage
<#
    .SYNOPSIS
    Sends mail message using Outlook REST API

    .DESCRIPTION
    Sends mail using Outlook REST API using the account of given credentials. 
    Message MUST be html (or plaintext).

    
    .Example
    PS C:\>$At=Get-AADIntAccessTokenForEXO
    PS C:\>Send-AADIntOutlookMessage -AccessToken $At -Recipient someone@company.com -Subject "An email" -Message "This is a message!"
   
#>
{
    Param(
        [Parameter(Mandatory=$False)]
        [String]$AccessToken,
        [Parameter(Mandatory=$True)]
        [String]$Recipient,
        [Parameter(Mandatory=$True)]
        [String]$Subject,
        [Parameter(Mandatory=$True)]
        [String]$Message,
        [Parameter(Mandatory=$False)]
        [Switch]$SaveToSentItems
    )

    Process
    {
        # Get from cache if not provided
        $AccessToken = Get-AccessTokenFromCache -AccessToken $AccessToken -Resource "https://outlook.office365.com" -ClientId "d3590ed6-52b3-4102-aeff-aad2292ab01c"
    
        $Request=@"
        {
          "Message": {
            "Subject": $(Escape-StringToJson $Subject),
            "Body": {
                "ContentType": "HTML",
                "Content": $(Escape-StringToJson $Message)
            },
            "ToRecipients": [
              {
                "EmailAddress": {
                  "Address": "$Recipient"
                }
              }
            ]
          },
          "SaveToSentItems": "$(if($SaveToSentItems){"true"}else{"false"})"
        }
"@

        $Cmd="me/sendmail"

        # Convert to UTF-8 bytes
        $Request_bytes = [system.Text.Encoding]::UTF8.getBytes($Request)

        Call-OutlookAPI -AccessToken $AccessToken -Command $Cmd -Method Post -Request $Request_bytes
    }
}

# Returns Outlook activities, a.k.a. the secrect forensics api
# MS has blocked the API but here it is anyways
# Apr 10th 2019
function Get-OutlookActivities
{
    Param(
        [Parameter(Mandatory=$False)]
        [String]$AccessToken
    )
    Process
    {
        # Get from cache if not provided
        $AccessToken = Get-AccessTokenFromCache -AccessToken $AccessToken -Resource "https://outlook.office365.com" -ClientId "d3590ed6-52b3-4102-aeff-aad2292ab01c"

        $Cmd="me/Activities"
        Call-OutlookAPI -AccessToken $AccessToken -Command $Cmd -Method Get -Api v1.0
    }
}


# Opens OWA as the given user
# Sep 1st 2021
function Open-OWA
{
<#
    .SYNOPSIS
    Opens OWA in a browser control window

    .DESCRIPTION
    Opens OWA in a browser control window as the given user

    .Example
    PS C:\>Get-AADIntAccessTokenForEXO -Resource "https://outlook.office.com" -SaveToCache
    PS C:\>Open-AADIntOWA

    .Example
    PS C:\>Get-AADIntAccessTokenForEXO -Resource "https://substrate.office.com" -SaveToCache
    PS C:\>Open-AADIntOWA -Mode Substrate
#>
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [String]$AccessToken,
        [Parameter(Mandatory=$False)]
        [ValidateSet("Outlook","Substrate")]
        [String]$Mode="Outlook"
    )
    Begin
    {
        $icon = Convert-B64ToByteArray -B64 "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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//////////////////AH///gAf//gAD//wAAf/4AAD/+AAAf/AAAH/wAAA/8AAAP+AAAD/gAAA/4AAAP+AAAD/wAAA/8AAAP/AAAH/wAAA/8AAAP+AAAD/gAAA/4AAAP+PAHz/////////////////////////////////////8="
    }
    Process
    {
        $Mode = $Mode.ToLower()
        # Get from cache if not provided
        $AccessToken = Get-AccessTokenFromCache -AccessToken $AccessToken -Resource "https://$($Mode).office.com" -ClientId "d3590ed6-52b3-4102-aeff-aad2292ab01c"

        # Create the form and add a WebBrowser control to it
        [Windows.Forms.Form]$form = New-Object Windows.Forms.Form
        $form.Width = 1024
        $form.Height = 768
        $form.FormBorderStyle=[System.Windows.Forms.FormBorderStyle]::Sizable
        $form.Icon = [System.Drawing.Icon]::new([System.IO.MemoryStream]::new($icon))
        $form.Text = "AADInternals | $($mode).office.com"
        
        [Windows.Forms.WebBrowser]$web = New-Object Windows.Forms.WebBrowser
        $web.Size = $form.ClientSize
        $web.Anchor = "Left,Top,Right,Bottom"

        $form.Controls.Add($web)

        # Clear WebBrowser control cache
        Clear-WebBrowser

        $web.ScriptErrorsSuppressed = $True
        $web.Navigate("https://outlook.office.com/owa/","",$null,"Authorization: Bearer $AccessToken")

        $form.ShowDialog()

        $web.Dispose()
        $form.Dispose()
    }
}