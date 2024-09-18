# Construct the deployment command
$mgid = "alz"
$location = "norwayeast"
$azurefirewall = "hubAndSpokeAzureFirewall"
$templateFile = ".\config\orchestration\hubAndSpokeAzureFirewall\hubAndSpokeAzureFirewall.bicep"
$parametersFile = ".\config\orchestration\hubAndSpokeAzureFirewall\hubAndSpokeAzureFirewall.parameters.json"

# Execute the Azure deployment command
az account set --subscription 4516fd20-da97-4ddc-aba6-392b67e99994
az deployment mg create --management-group-id $mgid --name $azurefirewall --location $location --template-file $templateFile --parameters $parametersFile `
