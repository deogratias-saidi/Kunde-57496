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
$hubNva = Get-AzResource -ResourceGroupName "rg-$companyPrefix-ecms-$resourceLocationSuffix-conn" -ResourceName "fgt-$companyPrefix-$resourceLocationSuffix-hub-nva" -ResourceType "Microsoft.Compute/virtualMachines"

try {
  # Check if the resource group exists
  Get-AzResourceGroup -Name "rg-$companyPrefix-ecms-$resourceLocationSuffix-conn" -ErrorAction Stop
  Write-Output "Resource group rg-$companyPrefix-ecms-$resourceLocationSuffix-conn found. Checking for existing firewall..."

  # Check if the FortiGate VM or Azure Firewall exists
  if ($hubNva) {
      throw "An Azure Firewall azfw-$companyPrefix-$resourceLocationSuffix-hub already exists in rg-$companyPrefix-ecms-$resourceLocationSuffix-conn. Only one firewall solution can be deployed. Deployment canceled."
  } else {
      Write-Output "No Azure Firewall found in rg-$companyPrefix-ecms-$resourceLocationSuffix-conn. Proceeding with the deployment..."
  }
}
catch {
  # Handle the case where the resource group is not found
  Write-Output "Resource group rg-$companyPrefix-$resourceLocationSuffix-hub not found. Proceeding with the deployment..."
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

