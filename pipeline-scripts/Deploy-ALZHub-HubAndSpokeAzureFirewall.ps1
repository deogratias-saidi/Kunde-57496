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
  # Check if the resource group exists
  Get-AzResourceGroup -Name "rg-$companyPrefix-ecms-$resourceLocationSuffix-conn" -ErrorAction Stop
  Write-Output "Resource group rg-$companyPrefix-ecms-$resourceLocationSuffix-conn found. Checking for existing firewall..."

  # Check if the FortiGate VM or Azure Firewall exists
  $hubNva = Get-AzVM -ResourceGroupName "rg-$companyPrefix-ecms-$resourceLocationSuffix-conn" -Name "fgt-$companyPrefix-$resourceLocationSuffix-hub-nva" -ErrorAction SilentlyContinue

  # If $hubNva is not null, the firewall exists
  if ($hubNva) {
      throw "An Fortigate Firewall fgt-$companyPrefix-$resourceLocationSuffix-hub-nva already exists in rg-$companyPrefix-ecms-$resourceLocationSuffix-conn. Only one firewall solution can be deployed. Deployment canceled."
  } else {
      Write-Output "No Azure Firewall found in rg-$companyPrefix-ecms-$resourceLocationSuffix-conn. Proceeding with the deployment..."
  }
}
catch {
  # Handle the case where the resource group is not found
  if ($_.Exception.Message -like "*could not be found*") {
      Write-Output "Resource group rg-$companyPrefix-ecms-$resourceLocationSuffix-conn not found. Proceeding with the deployment..."
      # You can place your deployment logic here to proceed with the deployment
  } else {
      # If it's some other error, re-throw the exception for debugging
      throw $_
  }
}

# Continue with the deployment logic here if resource group is found or not
Write-Output "Running the deployment process..."



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

