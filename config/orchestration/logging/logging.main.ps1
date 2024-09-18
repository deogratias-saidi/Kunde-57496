# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = -join ('alz-LoggingDeploy-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
  Location              = 'norwayeast'
  ManagementGroupId     = 'alz'
  TemplateFile          = ".\config\orchestration\logging\logging.main.bicep"
  TemplateParameterFile = ".\config\orchestration\logging\logging.main.parameters.json"
}

# Create Resource Group - optional when using an existing resource group
New-AzManagementGroupDeployment @inputObject