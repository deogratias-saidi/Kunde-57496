
param parAzBastionEnabled bool
param parAzBastionName string
param parAzBastionSku string
param parAzBastionTunneling bool
param parLocation string

param parPublicIp string
param parBastionSubnetId string

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



resource resBastion 'Microsoft.Network/bastionHosts@2023-02-01' = if (parAzBastionEnabled) {
  location: parLocation
  name: parAzBastionName
  tags: parTags
  sku: {
    name: parAzBastionSku
  }
  properties: {
    dnsName: uniqueString(resourceGroup().id)
    enableTunneling: (parAzBastionSku == 'Standard' && parAzBastionTunneling) ? parAzBastionTunneling : false
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: parBastionSubnetId
          }
          publicIPAddress: {
            id: parAzBastionEnabled ? parPublicIp : ''
          }
        }
      }
    ]
  }
}

output outBastionName string = resBastion.name

