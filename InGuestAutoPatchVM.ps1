# Register AzProvider
Register-AzProviderFeature -FeatureName InGuestAutoPatchVMPreview -ProviderNamespace Microsoft.Compute
  
# Check the registration status
Get-AzProviderFeature -FeatureName InGuestAutoPatchVMPreview -ProviderNamespace Microsoft.Compute
  
# Once the feature is registered for your subscription, complete the opt-in process by changing the Compute resource provider.
Register-AzResourceProvider -ProviderNamespace Microsoft.Compute
 
#Set VM Properties to enable automatic VM guest OS patching
Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate -PatchMode "AutomaticByPlatform"