param (
    [string]$companyPrefix,
    [string]$platManagementSubcriptionId,
    [string]$location,
    [switch]$WhatIf
)

# Parameters for deployment
$parameters = @{
    parCompanyPrefix               = $companyPrefix
    parPlatManagementSubcriptionId = $platManagementSubcriptionId
    parLocation                    = $location
}


# Ensure Bicep template exists
if (-not (Test-Path ".\config\orchestration\logging\logging.main.bicep")) {
    throw "Bicep template file not found."
}



if ($WhatIf) {
    Write-Output "Running WhatIf for the deployment..."
    New-AzManagementGroupDeployment `
        -ManagementGroupId 'alz' `
        -DeploymentName ("alz-Logging-WhatIf{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
        -Location $parLocation `
        -TemplateFile ".\config\orchestration\logging\logging.main.bicep" `
        -TemplateParameterObject $parameters `
        -WhatIf
}
else {
    Write-Output "Proceeding with the actual deployment..."
    New-AzManagementGroupDeployment `
        -ManagementGroupId 'alz' `
        -DeploymentName ("alz-Logging-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
        -Location $parLocation `
        -TemplateFile ".\config\orchestration\logging\logging.main.bicep" `
        -TemplateParameterObject $parameters
}

