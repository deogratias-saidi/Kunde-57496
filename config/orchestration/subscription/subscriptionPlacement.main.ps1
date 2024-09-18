<# # Construct the deployment command
$managemetGroupId = "alz"
$location = "norwayeast"
$templateFile = ".\config\orchestration\subscription\subscriptionPlacement.main.bicep"
$parametersFile = ".\config\orchestration\subscription\subscriptionPlacement.main.parameters.json"

# Execute the Azure deployment command
az deployment mg create --management-group-id $managemetGroupId --name subscriptionDeployment  --location $location --template-file $templateFile --parameters $parametersFile
 #>



# For Azure global regions
<# 
$inputObject = @{
    DeploymentName        = -join ('alz-SubscriptionPlacementDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = 'norwayeast'
    ManagementGroupId     = 'alz'
    TemplateFile          = ".\config\orchestration\subscription\subscriptionPlacement.main.bicep"
    TemplateParameterFile = ".\config\orchestration\subscription\subscriptionPlacement.main.parameters.json"
  }
  
  New-AzManagementGroupDeployment @inputObject #>

  

$parametersFile = @{
  parPlatConnectivitySubcriptionId  = '6e8c0843-692d-4f71-8905-068a9c275baa'
  parPlatManagementSubcriptionId    = '4516fd20-da97-4ddc-aba6-392b67e99994'
  parLandingZoneCorpSubcriptionId   = '840dddbe-69f2-4fa8-85c0-e0e46e627411'
  parLandingZoneOnlineSubcriptionId = '8ca3f268-a56f-4677-8038-c9a686ce65ce'
  parDeploySubscriptions            = $true
  parCompanyPrefix                  = '57496'
    
}

New-AzManagementGroupDeployment `
  -Location 'norwayeast' `
  -DeploymentName  (-join ('alz-SubscriptionPlacementDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]) `
  -ManagementGroupId 'alz' `
  -TemplateFile ".\config\orchestration\subscription\subscriptionPlacement.main.bicep" -TemplateParameterObject $parametersFile -WhatIf

