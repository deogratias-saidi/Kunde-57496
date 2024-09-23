param (
  [string]$companyPrefix,
  [string]$platConnectivitySubcriptionId,
  [string]$LandingZoneCorpSubcriptionId,
  [string]$location,
  [string]$adminUsername,
  [string]$adminPassword,
  [switch]$WhatIf
)


# Parameters for deployment
$parameters = @{
  parCompanyPrefix                 = $companyPrefix
  parPlatConnectivitySubcriptionId = $platConnectivitySubcriptionId
  parLandingZoneCorpSubcriptionId  = $LandingZoneCorpSubcriptionId
  parLocation                      = $location
  adminUsername                    = $adminUsername
  adminPassword                    = $adminPassword
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
if (-not (Test-Path ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep")) {
  throw "Bicep template file not found at the specified path."
}

# Check if a firewall already exists
$hubNva = Get-AzResource -ResourceGroupName "rg-$companyPrefix-$resourceLocationSuffix-hub" -ResourceName "AZFW-$companyPrefix-$resourceLocationSuffix-hub" -ResourceType "Microsoft.Network/azureFirewalls"

if ($hubNva) {
  throw "An Azure Firewall azfw-$companyPrefix-$resourceLocationSuffix-hub already exists in rg-$companyPrefix-$resourceLocationSuffix-hub. Only one firewall solution can be deployed. Deployment canceled."
} else {
  <# Action when all if and elseif conditions are false #>
  Write-Output "No Azure Firewall found in rg-$companyPrefix-$resourceLocationSuffix-hub. Proceeding with the deployment..."
}

# Run WhatIf if the switch is passed
if ($WhatIf) {
  Write-Output "Running WhatIf for the deployment..."
  New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-HubAndSpokeFortigate-WhatIf{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep" `
    -TemplateParameterObject $parameters `
    -WhatIf
} 
else {
  # Run the actual deployment
  Write-Output "Proceeding with the actual deployment..."
  New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-HubAndSpokeFortigate-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep" `
    -TemplateParameterObject $parameters
}

