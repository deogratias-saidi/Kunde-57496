param (
  [string]$companyPrefix,
  [string]$platConnectivitySubcriptionId,
  [string]$LandingZoneCorpSubcriptionId,
  [string]$location,
  [switch]$WhatIf
)


# Parameters for deployment
$parameters = @{
  parCompanyPrefix                 = $companyPrefix
  parPlatConnectivitySubcriptionId = $platConnectivitySubcriptionId
  parLandingZoneCorpSubcriptionId  = $LandingZoneCorpSubcriptionId
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

# Check if a firewall already exists
$hubNva = Get-AzResource -ResourceGroupName "rg-$companyPrefix-$resourceLocationSuffix-hub" -ResourceName "FGT-$companyPrefix-$resourceLocationSuffix-HUB-NVA" -ResourceType "Microsoft.Compute/virtualMachines"

# and if the resource group does not exist continue with the deployment
if (-not (Get-AzResourceGroup -Name "rg-$companyPrefix-$resourceLocationSuffix-hub" -ErrorAction SilentlyContinue)) {
  Write-Output "Resource group rg-$companyPrefix-$resourceLocationSuffix-hub not found. Proceeding with the deployment..."
} elseif ($hubNva) {
  throw "An Azure Firewall FGT-$companyPrefix-$resourceLocationSuffix-HUB-NVA already exists in rg-$companyPrefix-$resourceLocationSuffix-hub. Only one firewall solution can be deployed. Deployment canceled."
} else {
  Write-Output "No Azure Firewall found in rg-$companyPrefix-$resourceLocationSuffix-hub. Proceeding with the deployment..."
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

