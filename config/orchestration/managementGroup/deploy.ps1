# For Azure global regions

$inputObject = @{
    DeploymentName        = -join ('alz-MGDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = 'norwayeast'
    TemplateFile          = "config/orchestration/managementGroup/managementGroup.main.bicep"
    TemplateParameterFile = 'config/orchestration/managementGroup/managementGroup.main.parameters.json'
  }
  New-AzTenantDeployment @inputObject
