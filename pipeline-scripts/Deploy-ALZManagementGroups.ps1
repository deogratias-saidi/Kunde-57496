param (
  [Parameter()]
  [String]$NonRootParentManagementGroupId = "$($env:NONROOTPARENTMANAGEMENTGROUPID)",

  [Parameter()]
  [String]$Location = "$($env:LOCATION)",

  [Parameter()]
  [String]$TemplateFile = ".\config\orchestration\managementGroup\managementGroup.main.bicep",

  [Parameter()]
  [String]$TemplateParameterFile = ".\config\orchestration\managementGroup\managementGroup.main.parameters.json",

  [Parameter()]
  [Boolean]$WhatIfEnabled = [System.Convert]::ToBoolean($($env:IS_PULL_REQUEST))
)

# Parameters necessary for deployment

if ($NonRootParentManagementGroupId -eq '') {
  $inputObject = @{
    DeploymentName        = -join ('alz-MGDeployment-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $Location
    TemplateFile          = $TemplateFile + "managementGroup.main.bicep"
    TemplateParameterFile = $TemplateParameterFile
    WhatIf                = $WhatIfEnabled
    Verbose               = $true
  }

  New-AzTenantDeployment @inputObject
}
