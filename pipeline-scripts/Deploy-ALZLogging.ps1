param (
    [string]$companyPrefix,
    [string]$parTargetManagementGroupId,
    [string]$location,
    [switch]$WhatIf
)

# Determine the correct resource group suffix based on the location
if ($location -eq "norwayeast") {
    $resourceGroupSuffix = "noe"
} elseif ($location -eq "westeurope") {
    $resourceGroupSuffix = "weu"
} elseif ($location -eq "northeurope") {
    $resourceGroupSuffix = "neu"
} else {
    throw "Unsupported location: $location. Only norwayeast, westeurope, and northeurope are allowed."
}

# Set resource group names dynamically based on the location
$logAnalyticsWorkspaceResourceGroupName = "rg-$companyPrefix-ecms-$resourceGroupSuffix-logging"
$logAnalyticsWorkspaceResourceId = "/subscriptions/$parTargetManagementGroupId/resourcegroups/$logAnalyticsWorkspaceResourceGroupName/providers/microsoft.operationalinsights/workspaces/alz-$companyPrefix-log-analytics"
$dataCollectionRuleVMInsightsResourceId = "/subscriptions/$parTargetManagementGroupId/resourceGroups/$logAnalyticsWorkspaceResourceGroupName/providers/Microsoft.Insights/dataCollectionRules/alz-$companyPrefix-ama-vmi-dcr"
$dataCollectionRuleChangeTrackingResourceId = "/subscriptions/$parTargetManagementGroupId/resourceGroups/$logAnalyticsWorkspaceResourceGroupName/providers/Microsoft.Insights/dataCollectionRules/alz-$companyPrefix-ama-ct-dcr"
$dataCollectionRuleMDFCSQLResourceId = "/subscriptions/$parTargetManagementGroupId/resourceGroups/$logAnalyticsWorkspaceResourceGroupName/providers/Microsoft.Insights/dataCollectionRules/alz-$companyPrefix-ama-mdfcsql-dcr"
$userAssignedManagedIdentityResourceId = "/subscriptions/$parTargetManagementGroupId/resourceGroups/$logAnalyticsWorkspaceResourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/alz-$companyPrefix-logging-mi"

# Output the resource group names and resource IDs for verification
Write-Output "Log Analytics Workspace Resource Group Name: $logAnalyticsWorkspaceResourceGroupName"
Write-Output "Log Analytics Workspace Resource ID: $logAnalyticsWorkspaceResourceId"
Write-Output "VM Insights Data Collection Rule Resource ID: $dataCollectionRuleVMInsightsResourceId"
Write-Output "Change Tracking Data Collection Rule Resource ID: $dataCollectionRuleChangeTrackingResourceId"
Write-Output "MDFCSQL Data Collection Rule Resource ID: $dataCollectionRuleMDFCSQLResourceId"
Write-Output "User Assigned Managed Identity Resource ID: $userAssignedManagedIdentityResourceId"

# Parameters for deployment
$parameters = @{
    parCompanyPrefix = $companyPrefix
    parLogAnalyticsWorkSpaceAndAutomationAccountLocation = $location
    parLogAnalyticsWorkspaceResourceId = $logAnalyticsWorkspaceResourceId
    parDataCollectionRuleVMInsightsResourceId = $dataCollectionRuleVMInsightsResourceId
    parDataCollectionRuleChangeTrackingResourceId = $dataCollectionRuleChangeTrackingResourceId
    parDataCollectionRuleMDFCSQLResourceId = $dataCollectionRuleMDFCSQLResourceId
    parUserAssignedManagedIdentityResourceId = $userAssignedManagedIdentityResourceId
    parUserAssignedManagedIdentityResourceName = "alz-$companyPrefix-logging-mi"
    parLogAnalyticsWorkspaceName = "alz-$companyPrefix-log-analytics"
    parLogAnalyticsWorkspaceResourceGroupName = $logAnalyticsWorkspaceResourceGroupName
    parLogAnalyticsWorkspaceSubscription = $parTargetManagementGroupId
    parAutomationAccountName = "alz-$companyPrefix-automation-account"
    parMsDefenderForCloudEmailSecurityContact = "deogratias.saidi@ecit.no"
}

if (-not (Test-Path "./config/custom-modules/policy/assignments/alzDefaults/alzDefaultPolicyAssignments.bicep")) {
    throw "Bicep template file not found at the specified path."
}

if($whatIf){

    # WhatIf deployment

    Write-Output "Run  the WhatIf for deployment.... "

    New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-PolicyAssignment-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\custom-modules\policy\assignments\alzDefaults\alzDefaultPolicyAssignments.bicep" `
    -TemplateParameterObject $parameters
    -WhatIf
}else {
    
    Write-Output "Proceeding with the actual deployment..."

    New-AzManagementGroupDeployment `
    -ManagementGroupId 'alz' `
    -DeploymentName ("alz-PolicyAssignment-{0}" -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ')) `
    -Location $location `
    -TemplateFile ".\config\custom-modules\policy\assignments\alzDefaults\alzDefaultPolicyAssignments.bicep" `
    -TemplateParameterObject $parameters
}
