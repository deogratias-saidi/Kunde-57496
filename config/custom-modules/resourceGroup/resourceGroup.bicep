targetScope = 'subscription'

metadata name = 'ALZ Bicep - Resource Group creation module'
metadata description = 'Module used to create Resource Groups for Azure Landing Zones'

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. The lock settings of the service.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')

  @description('Optional. Notes about this lock.')
  notes: string?
}

@sys.description('Azure Region where Resource Group will be created.')
param parLocation string

@sys.description('Name of Resource Group to be created.')
param parResourceGroupName string 

@description('''
The location abbreviation for the region
- Norway East: NOE
- North Europe: NEU
- West Europe: WEU
''')
param parRegion string = parLocation == 'norwayeast'
  ? 'NOE'
  : parLocation == 'westeurope' ? 'WEU' : parLocation == 'northeurope' ? 'NEU' : 'NOE'

param parResposibleProvider string = 'ECIT'


@description('''
Landing Zone Environment, the environment that the resource is deployed in, the options are:
- Platform
- Corp
- Online
- Management
- Connectivity
''')
@allowed([
  'Platform'
  'Corp'
  'Online'
  'Management'
  'Connectivity'
])
param parLandingZoneEnv string

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {
  Region: parRegion
  ResponsibleProvider: parResposibleProvider
  LZ: parLandingZoneEnv
}

resource resResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: parLocation
  name: parResourceGroupName
  tags: parTags
}




output outResourceGroupName string = resResourceGroup.name
output outResourceGroupId string = resResourceGroup.id
