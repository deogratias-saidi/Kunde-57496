/*************************************************************
THIS SHOULD BE IN ALL MODULES FOR THE AZURE RESOURCE
**************************************************************/
@description('''
Azure Region to deploy the resources into:
If nothing else is specified or agreed by the customer, the default deployment region will be Norway East.
- West Europe: westeurope
- North Europe: northeurope
- East Norway: norwayeast
''')
param parLocation string = resourceGroup().location

@description('''
The location abbreviation for the region
- Norway East: NOE
- North Europe: NEU
- West Europe: WEU
''')
param parRegion string = parLocation == 'norwayeast' ? 'NOE' : parLocation == 'westeurope' ? 'WEU' : parLocation == 'northeurope' ? 'NEU' : 'NOE'

param parResposibleProvider string = 'ECIT'

@description('''
Landing Zone Environment, the environment that the resource is deployed in, the options are:
- Platform
- Corp
- Online
- Management
''')
@allowed([
  'Platform'
  'Corp'
  'Online'
  'Management'
  'Connectivity'
])
param parLandingZoneEnv string

@description('''
Tags for the resource
''')
param parTags object =  {

  Region: parRegion
  ResponsibleProvider: parResposibleProvider
  LZ: parLandingZoneEnv
}

@sys.description('The name of the network security group')
param parSecurityGroupName string

@sys.description('The security rules for the network security group')
param parSecurityGroupSecurityRules array?

resource resNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: parSecurityGroupName
  location: parLocation
  tags: parTags
  properties: {
    securityRules: parSecurityGroupSecurityRules
  }
}

output resNetworkSecurityGroupName string = resNetworkSecurityGroup.name
output resNetworkSecurityGroupId string = resNetworkSecurityGroup.id
