param (
  [string]$companyPrefix,
  [string]$parTopLevelManagementGroupPrefix = "alz",
  [string]$location,
  [string]$parTopLevelManagementGroupDisplayName,
  [bool]$parPlatformMgmtAlzDefaultsEnable = $true,
  [bool]$parLandingZoneMgAlzDefaultsEnable = $true,
  [bool]$parSandboxMgDefaultsEnable = $true,
  [bool]$parDecommissionedMgDefautsEnable = $true,
  [bool]$parLandingZoneMgConfidentialEnable = $false,
  [switch]$WhatIf
)


# Parameters for deployment
$parameters = @{
  parCompanyPrefix = $companyPrefix
  parTopLevelManagementGroupPrefix = $parTopLevelManagementGroupPrefix
  parTopLevelManagementGroupDisplayName = $parTopLevelManagementGroupDisplayName
  parPlatformMgmtAlzDefaultsEnable = $parPlatformMgmtAlzDefaultsEnable
  parLandingZoneMgAlzDefaultsEnable = $parLandingZoneMgAlzDefaultsEnable
  parSandboxMgDefaultsEnable = $parSandboxMgDefaultsEnable
  parDecommissionedMgDefautsEnable = $parDecommissionedMgDefautsEnable
  parLandingZoneMgConfidentialEnable = $parLandingZoneMgConfidentialEnable
}

# Ensure Bicep template exists
if (-not (Test-Path ".\config\orchestration\managementGroup\managementGroup.main.bicep")) {
  throw "Bicep template file not found at the specified path."
}

# Run WhatIf if the switch is passed
if ($WhatIf) {
  Write-Output "Running WhatIf for the deployment..."
  New-AzTenantDeployment `
    -Location $location `
    -TemplateFile ".\config\orchestration\managementGroup\managementGroup.main.bicep" `
    -TemplateParameterObject $parameters `
    -WhatIf
} 
else {
  # Run the actual deployment
  Write-Output "Proceeding with the actual deployment..."
  New-AzTenantDeployment `
    -Location $location `
    -TemplateFile ".\config\orchestration\managementGroup\managementGroup.main.bicep" `
    -TemplateParameterObject $parameters
}