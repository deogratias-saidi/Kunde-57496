<# # Construct the deployment command
$managemetGroupId = "alz"
$location = "norwayeast"
$templateFile = ".\config\orchestration\subscription\subscriptionPlacement.main.bicep"
$parametersFile = ".\config\orchestration\subscription\subscriptionPlacement.main.parameters.json"

# Execute the Azure deployment command
az deployment mg create --management-group-id $managemetGroupId --name subscriptionDeployment  --location $location --template-file $templateFile --parameters $parametersFile
 #>



# For Azure global regions

$inputObject = @{
    DeploymentName        = -join ('alz-SubscriptionPlacementDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = 'norwayeast'
    ManagementGroupId     = 'alz'
    TemplateFile          = ".\config\orchestration\subscription\subscriptionPlacement.main.bicep"
    TemplateParameterFile = ".\config\orchestration\subscription\subscriptionPlacement.main.parameters.json"
  }
  
  New-AzManagementGroupDeployment @inputObject