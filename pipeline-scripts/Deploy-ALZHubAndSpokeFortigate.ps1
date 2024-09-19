<# param (
    [string]$companyPrefix,
    [string]$connectivitySubscriptionId,
    [string]$landigZoneCorpSubscriptionId,
    [string]$location,
    [string]$adminUsername,
    [SecureString]$adminPassword

)


# Parameters for deployment
$parameters = @{
    parCompanyPrefix = $companyPrefix
    parConnectivitySubscriptionId = $connectivitySubscriptionId
    parLandigZoneCorpSubscriptionId = $landigZoneCorpSubscriptionId
    parLocation = $location
    $adminUsername = $adminUsername
    $adminPassword = $adminPassword
}

if (-not (Test-Path ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep")) {
    throw "Bicep template file not found at the specified path."
}

# Actual deployment
New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-PolicyAssignment-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep" `
    -TemplateParameterObject $parameters
 #>

 param (
  [string]$companyPrefix,
  [string]$connectivitySubscriptionId,
  [string]$landigZoneCorpSubscriptionId,
  [string]$location,
  [string]$adminUsername,
  [string]$adminPassword,
  [switch]$WhatIf  # New switch for WhatIf
)

$secureAdminPassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force

# Parameters for deployment
$parameters = @{
  parCompanyPrefix = $companyPrefix
  parConnectivitySubscriptionId = $connectivitySubscriptionId
  parLandigZoneCorpSubscriptionId = $landigZoneCorpSubscriptionId
  parLocation = $location
  adminUsername = $adminUsername
  adminPassword = $secureAdminPassword
}

# Ensure Bicep template exists
if (-not (Test-Path ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep")) {
  throw "Bicep template file not found at the specified path."
}

# Run WhatIf if the switch is passed
if ($WhatIf) {
  Write-Output "Running WhatIf for the deployment..."
  New-AzManagementGroupDeployment `
      -ManagementGroupId 'alz' `
      -DeploymentName ("alz-PolicyAssignment-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
      -Location $location `
      -TemplateFile ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep" `
      -TemplateParameterObject $parameters `
      -WhatIf
} else {
  # Run the actual deployment
  Write-Output "Proceeding with the actual deployment..."
  New-AzManagementGroupDeployment `
      -ManagementGroupId 'alz' `
      -DeploymentName ("alz-PolicyAssignment-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
      -Location $location `
      -TemplateFile ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep" `
      -TemplateParameterObject $parameters
}
