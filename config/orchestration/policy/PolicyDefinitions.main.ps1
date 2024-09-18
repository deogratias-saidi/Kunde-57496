# For Azure global regions
# For Azure global regions

$inputObject = @{
    DeploymentName        = -join ('alz-PolicyDefsDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = 'norwayeast'
    ManagementGroupId     = 'alz'
    TemplateFile          = "config/custom-modules/policy/definitions/customPolicyDefinitions.bicep"
    TemplateParameterFile = 'config/custom-modules/policy/definitions/parameters/customPolicyDefinitions.parameters.all.json'
  }
  
  New-AzManagementGroupDeployment @inputObject