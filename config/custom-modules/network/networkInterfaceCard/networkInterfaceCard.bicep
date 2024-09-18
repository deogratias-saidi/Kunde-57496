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

/*************************************************************
      THIS SHOULD BE IN ALL MODULES FOR THE AZURE RESOURCE
**************************************************************/


@sys.description('The name of the network security group')
param parNetworkInterfaceName string

@sys.description('The security rules for the network security group')
param parNetworkSecurityGroudId string

@sys.description('The subnet id')
param parSubnetId string

@sys.description('The public IP address id')
param parPublicIPAddressId string

resource resNetworkInterfaceCard 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: parNetworkInterfaceName
  location: parLocation
  tags: parTags
  properties: {
    enableIPForwarding: true
    enableAcceleratedNetworking:false
    networkSecurityGroup: {
      id: parNetworkSecurityGroudId
    }
    
    ipConfigurations: [
      {
        name: 'IpConfig-${parNetworkInterfaceName}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: parSubnetId
          }
          publicIPAddress: {
            id: parPublicIPAddressId
          }
        }
      }
    ]
  }
}




output outNetworkInterfaceCardName string = resNetworkInterfaceCard.name
output outNetworkInterfaceCardId string = resNetworkInterfaceCard.id
