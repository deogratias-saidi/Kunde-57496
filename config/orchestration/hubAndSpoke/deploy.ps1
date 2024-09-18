

# Set the subscription if provided
$subscriptionId = "4516fd20-da97-4ddc-aba6-392b67e99994"
if ($subscriptionId) {
    az account set --subscription $subscriptionId
}

# Construct the deployment command
$managemetGroupId = "alz-${companyCode}"
$location = "norwayeast"
$templateFile = ".\config\orchestration\hubAndSpoke\hubAndSpoke.main.bicep"
$parametersFile = ".\config\orchestration\hubAndSpoke\hubAndSpoke.main.parameters.json"

# Execute the Azure deployment command
az deployment mg create --management-group-id $managemetGroupId --name deployment-hub-and-spoke --location $location --template-file $templateFile --parameters $parametersFile