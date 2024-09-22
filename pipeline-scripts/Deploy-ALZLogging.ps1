param (
    [string]$parCompanyPrefix,
    [string]$parPlatManagementSubcriptionId,
    [string]$parLocation,
    [switch]$WhatIf
)

# Parameters for deployment
$parameters = @{
    parCompanyPrefix               = $parCompanyPrefix
    parPlatManagementSubcriptionId = $parPlatManagementSubcriptionId
    parLocation                    = $parLocation
}

# Log the parameters
Write-Output "Company Prefix: $parCompanyPrefix"
Write-Output "Management Subscription ID: $parPlatManagementSubcriptionId"
Write-Output "Location: $parLocation"

# Check and log the current directory
Write-Output "Current Directory: $(Get-Location)"

# Ensure Bicep template exists
if (-not (Test-Path ".\config\orchestration\logging\logging.main.bicep")) {
    Write-Error "Bicep template not found in path: $(Get-Location)\config\orchestration\logging\logging.main.bicep"
    throw "Bicep template file not found."
}

try {
    if ($WhatIf) {
        Write-Output "Running WhatIf for the deployment..."
        New-AzManagementGroupDeployment `
            -ManagementGroupId 'alz' `
            -DeploymentName ("alz-Logging-WhatIf{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
            -Location $parLocation `
            -TemplateFile ".\config\orchestration\logging\logging.main.bicep" `
            -TemplateParameterObject $parameters `
            -WhatIf
    } else {
        Write-Output "Proceeding with the actual deployment..."
        New-AzManagementGroupDeployment `
            -ManagementGroupId 'alz' `
            -DeploymentName ("alz-Logging-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
            -Location $parLocation `
            -TemplateFile ".\config\orchestration\logging\logging.main.bicep" `
            -TemplateParameterObject $parameters
    }
} catch {
    Write-Error "Deployment failed: $_"
    throw $_
}
