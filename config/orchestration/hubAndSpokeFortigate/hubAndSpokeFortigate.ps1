# Construct the deployment command
$managemetGroupId = "alz"
$location = "norwayeast"
$templateFile = ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.bicep"
$parametersFile = ".\config\orchestration\hubAndSpokeFortigate\hubAndSpokeFortigate.parameters.json"

# Accept the terms for the fortinet vm image
az vm image terms accept --publisher fortinet --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm

# Execute the Azure deployment command
az deployment mg create --management-group-id $managemetGroupId --name hunAndSpoke  --location $location --template-file $templateFile --parameters $parametersFile