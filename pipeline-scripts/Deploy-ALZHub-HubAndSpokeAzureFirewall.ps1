param (
  [string]$companyPrefix,
  [string]$platConnectivitySubscriptionId,
  [string]$LandingZoneCorpSubscriptionId,
  [string]$location,
  [switch]$WhatIf
)


# Parameters for deployment
$parameters = @{
  parCompanyPrefix                 = $companyPrefix
  parPlatConnectivitySubscriptionId = $platConnectivitySubscriptionId
  parLandingZoneCorpSubscriptionId = $LandingZoneCorpSubscriptionId
  parLocation                      = $location
}


if ($location -eq "norwayeast") {
  $resourceLocationSuffix = "noe"
} elseif ($location -eq "westeurope") {
  $resourceLocationSuffix = "weu"
} elseif ($location -eq "northeurope") {
  $resourceLocationSuffix = "neu"
} else {
  throw "Unsupported location: $location. Only norwayeast, westeurope, and northeurope are allowed."
}


# Ensure Bicep template exists
if (-not (Test-Path ".\config\orchestration\hubAndSpokeAzureFirewall\hubAndSpokeAzureFirewall.bicep")) {
  throw "Bicep template file not found at the specified path."
}

try {
  # Check if the resource group exists, but use -ErrorAction SilentlyContinue to prevent a thrown exception
  $resourceGroup = Get-AzResourceGroup -Name "rg-$companyPrefix-ecms-$resourceLocationSuffix-conn" -ErrorAction SilentlyContinue
  
  if ($resourceGroup) {
      Write-Output "Resource group rg-$companyPrefix-ecms-$resourceLocationSuffix-conn found. Checking for existing firewall..."

      # Check if the FortiGate VM or Azure Firewall exists
      $hubNva = Get-AzVM -ResourceGroupName "rg-$companyPrefix-ecms-$resourceLocationSuffix-conn" -Name "fgt-$companyPrefix-$resourceLocationSuffix-hub-nva" -ErrorAction SilentlyContinue

      if ($hubNva) {
          throw "An Azure Firewall fgt-$companyPrefix-$resourceLocationSuffix-hub-nva already exists in rg-$companyPrefix-ecms-$resourceLocationSuffix-conn. Only one firewall solution can be deployed. Deployment canceled."
      } else {
          Write-Output "No Azure Firewall found in rg-$companyPrefix-ecms-$resourceLocationSuffix-conn. Proceeding with the deployment..."
      }
  } else {
      # If the resource group is not found, handle this scenario
      Write-Output "Resource group rg-$companyPrefix-ecms-$resourceLocationSuffix-conn not found. Proceeding with the deployment..."
  }
}
catch {
  # Re-throw any other unexpected errors for proper debugging
  throw $_
}

# Run WhatIf if the switch is passed
if ($WhatIf) {
  Write-Output "Running WhatIf for the deployment..."


  New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-HubAndSpokeAzureFirewall-WhatIf{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\orchestration\hubAndSpokeAzureFirewall\hubAndSpokeAzureFirewall.bicep" `
    -TemplateParameterObject $parameters `
    -WhatIf
} 
else {
  # Run the actual deployment
  Write-Output "Proceeding with the actual deployment..."
  New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-HubAndSpokeAzureFirewall-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\orchestration\hubAndSpokeAzureFirewall\hubAndSpokeAzureFirewall.bicep" `
    -TemplateParameterObject $parameters
}

