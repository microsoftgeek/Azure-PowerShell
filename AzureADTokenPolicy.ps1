# Azure AD v2 PowerShell Token Lifetime Policy

# Connect with Modern Authentication
Connect-AzureAD

# See if there are any existing Azure AD Policies defined
Get-AzureADPolicy

# Defaults for NEW tenants:
# Refresh Token Inactivity: 90 Days
# Single/Multi factor Refresh Token Max Age: until-revoked
# Refresh token Max Age for Confidential Clients: until-revoked

$newDefaultTokenLifetimePolicy = @('{
    "TokenLifetimePolicy":
    {
        "Version":1,
        "MaxInactiveTime":"90.00:00:00",
        "MaxAgeSingleFactor":"until-revoked",
        "MaxAgeMultiFactor":"until-revoked",
        "MaxAgeSessionSingleFactor":"until-revoked",
        "MaxAgeSessionMultiFactor":"until-revoked"
    }
}') 

# If you have an OLD tenant, run this command to create a default 
# organization policy that reflects the settings for new tenants
New-AzureADPolicy -Definition $newDefaultTokenLifetimePolicy `
    -DisplayName "OrganizationDefaultPolicyScenario" `
    -IsOrganizationDefault $true -Type "TokenLifetimePolicy"

# Defaults for OLD existing tenants:
# Refresh Token Inactivity: 14 Days
# Single/Multi factor Refresh Token Max Age: 90 days
# Refresh token Max Age for Confidential Clients: until-revoked

$oldDefaultTokenLifetimePolicy = @('{
    "TokenLifetimePolicy":
    {
        "Version":1,
        "MaxInactiveTime":"14.00:00:00",
        "MaxAgeSingleFactor":"90.00:00:00",
        "MaxAgeMultiFactor":"90.00:00:00",
        "MaxAgeSessionSingleFactor":"until-revoked",
        "MaxAgeSessionMultiFactor":"until-revoked"
    }
}') 

# If you have a NEW tenant, and want to use the old default values, 
# run this command to create a revert the default organization policy
New-AzureADPolicy -Definition $oldDefaultTokenLifetimePolicy `
    -DisplayName "OrganizationDefaultPolicyScenario" `
    -IsOrganizationDefault $true -Type "TokenLifetimePolicy"

# If you want to update any existing organization default token lifetime policy, use these commands
$orgDefaultPolicy = Get-AzureADPolicy | Where-Object `
    {$_.Type -eq "TokenLifetimePolicy" -and $_.IsOrganizationDefault -eq $true}

Set-AzureADPolicy -Id $orgDefaultPolicy.Id -DisplayName "OrganizationDefaultPolicyUpdatedScenario" `
    -Definition $newDefaultTokenLifetimePolicy

# Look at existing token lifetime polices and settings
$aadTokenLifetimePolicies = Get-AzureADPolicy | Where-Object {$_.Type -eq "TokenLifetimePolicy"} | `
    Select-Object DisplayName, Type, IsOrganizationDefault, Definition

# List existing settings
$aadTokenLifetimePolicies.Definition | ConvertFrom-Json |  Select-Object -ExpandProperty TokenLifetimePolicy | `
    Select-Object $aadTokenLifetimePolicies.DisplayName, `
    MaxInactiveTime, `
    MaxAgeSingleFactor, `
    MaxAgeMultiFactor, `
    MaxAgeSessionSingleFactor, `
    MaxAgeSessionMultiFactor
