## Enter your domain name e.g. azureadmin 
## Enter your admin password e.g. P@ssw0rd
## Enter svrname = server name that you will deploy IIS on it e.g. Server1 
## Enter servicename = Cloud service name that you will deploy IIS on it e.g. Server1 

$adminname  = '<username>'
$adminPassword = '<password>'

$svrname = "Server1"
$servicename =  "Server1"

Function Install-IIS ($svrname, $servicename)

{

# Install the WinRM Certificate first to access the VM via Remote PS
Install-WinRMCertificateForVM $servicename $svrname

# Return back the correct URI for Remote PowerShell
$uri = Get-AzureWinRMUri -ServiceName $servicename -Name $svrname
$SecurePassword = $adminpassword | ConvertTo-SecureString -AsPlainText -Force
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $adminname,$SecurePassword

# Install IIS
Invoke-Command -ConnectionUri $uri.ToString() -Credential $credential -ScriptBlock {
  Install-WindowsFeature -Name Web-Server -IncludeManagementTools -Source C:\Windows\WinSxS
}

# Disable Windows Firewall:
Invoke-Command -ConnectionUri $uri.ToString() -Credential $credential -ScriptBlock {
  Set-NetFirewallProfile -All -Enabled False 
}

}
