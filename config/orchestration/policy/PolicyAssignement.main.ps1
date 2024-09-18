
$inputObject = @{
    DeploymentName        = -join ('alz-alzPolicyAssignmentDefaultsDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = 'norwayeast'
    ManagementGroupId     = 'alz'
    TemplateFile          = ".\config\custom-modules\policy\assignments\alzDefaults\defaultPolicyAssignments.bicep"
    TemplateParameterFile = ".\config\custom-modules\policy\assignments\alzDefaults\parameters\defaultPolicyAssignments.parameters.json"
  }
  
  # Create Resource Group - optional when using an existing resource group
  New-AzManagementGroupDeployment @inputObject