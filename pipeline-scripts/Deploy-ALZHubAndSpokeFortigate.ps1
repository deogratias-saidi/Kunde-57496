param (
  [Parameter()]
  [String]$Location = "$($env:LOCATION)",

  [Parameter()]
  [String]$ConnectivitySubscriptionId = "$($env:CONNECTIVITY_SUBSCRIPTION_ID)",

  [Parameter()]
  [String]$TemplateFile = "config\orchestration\fortigateHubAndSpoke\fortigateHubAndSpoke.main.bicep",

  [Parameter()]
  [String]$TemplateParameterFile = "config\custom-parameters\fortigateHubAndSpoke.parameters.all.json",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment
$inputObject = @{
  DeploymentName        = 'alz-ConnectivityRGDeploy-{0}' -f ( -join (Get-Date -Format 'yyyyMMddTHHMMssffffZ')[0..63])
  Location              = $Location
  TemplateFile          = $TemplateFile
  TemplateParameterFile = $TemplateParameterFile
  WhatIf                = $WhatIfEnabled
  Verbose               = $true
}

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

New-AzSubscriptionDeployment @inputObject
