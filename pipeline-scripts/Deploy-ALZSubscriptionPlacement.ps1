param (
  [string]$parCompanyPrefix,
  [string]$parPlatConnectivitySubcriptionId,
  [string]$parPlatManagementSubcriptionId,
  [string]$parLandingZoneCorpSubcriptionId,
  [string]$parLandingZoneOnlineSubcriptionId,
  [bool]$parDeploySubscriptions = $true,
  [string]$location,
  [switch]$WhatIf
)

$parametersFile = @{
  parCompanyPrefix                  = $parCompanyPrefix
  parPlatConnectivitySubcriptionId  = $parPlatConnectivitySubcriptionId
  parPlatManagementSubcriptionId    = $parPlatManagementSubcriptionId
  parLandingZoneCorpSubcriptionId   = $parLandingZoneCorpSubcriptionId
  parLandingZoneOnlineSubcriptionId = $parLandingZoneOnlineSubcriptionId
  parDeploySubscriptions            = $parDeploySubscriptions
}

if($WhatIf){
  Write-Output "Running WhatIf for the deployment..."

  New-AzManagementGroupDeployment `
    -Location $location `
    -DeploymentName  (-join ('alz-SubscriptionPlacementDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]) `
    -ManagementGroupId 'alz' `
    -TemplateFile ".\config\orchestration\subscription\subscriptionPlacement.main.bicep" `
    -TemplateParameterObject $parametersFile `
    -WhatIf
} else {
  Write-Host "Executing actual deployment for Subscription Placement"


  New-AzManagementGroupDeployment `
    -Location $location `
    -DeploymentName  (-join ('alz-SubscriptionPlacementDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]) `
    -ManagementGroupId 'alz' `
    -TemplateFile ".\config\orchestration\subscription\subscriptionPlacement.main.bicep" `
    -TemplateParameterObject $parametersFile
}

