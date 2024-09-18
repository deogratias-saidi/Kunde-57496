
# Construct the deployment command
$location = "norwayeast"
$templateFile = ".\config\orchestration\managementgroup\managementGroup.main.bicep"
$parametersFile = ".\config\orchestration\managementgroup\managementGroup.main.parameters.json"

# Execute the Azure deployment command
az deployment tenant create --location $location --template-file $templateFile --parameters $parametersFile `
