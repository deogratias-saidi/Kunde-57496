param (
  [string]$parTargetManagementGroupId = 'alz',
  [string]$location,
  [switch]$WhatIf
)


# Parameters for deployment
$parameters = @{
  parTargetManagementGroupId = $parTargetManagementGroupId
}

# Ensure Bicep template exists
if (-not (Test-Path ".\config\custom-modules\policy\definitions\customPolicyDefinitions.bicep")) {
  throw "Bicep template file not found at the specified path."
}

# Run WhatIf if the switch is passed
if ($WhatIf) {
  Write-Output "Running WhatIf for the deployment..."
  New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-CustomPolicyDefinitions-WhatIf{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\custom-modules\policy\definitions\customPolicyDefinitions.bicep" `
    -TemplateParameterObject $parameters `
    -WhatIf
} 
else {
  # Run the actual deployment
  Write-Output "Proceeding with the actual deployment..."
  New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-CustomPolicyDefinitions-WhatIf{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\custom-modules\policy\definitions\customPolicyDefinitions.bicep" `
    -TemplateParameterObject $parameters
}