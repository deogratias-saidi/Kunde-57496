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

 Get-AzMarketplaceTerms -Publisher "fortinet" -Product "fortinet_fortigate-vm_v5" -Name "fortinet_fg-vm" | Set-AzMarketplaceTerms -Accept
 
 param (
  [string]$companyPrefix,
  [string]$platConnectivitySubcriptionId,
  [string]$LandingZoneCorpSubcriptionId,
  [string]$location,
  [string]$adminUsername,
  [string]$adminPassword,
  [switch]$WhatIf  # New switch for WhatIf
)


# Parameters for deployment
$parameters = @{
  parCompanyPrefix = $companyPrefix
  parPlatConnectivitySubcriptionId = $platConnectivitySubcriptionId
  parLandingZoneCorpSubcriptionId = $LandingZoneCorpSubcriptionId
  parLocation = $location
  adminUsername = $adminUsername
  adminPassword = $adminPassword
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
