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

@description('''
Tags for the resource
''')
param parTags object = {
  Region: parRegion
  ResponsibleProvider: parResposibleProvider
  LZ: parLandingZoneEnv
}


/*************************************************************
THIS SHOULD BE IN ALL MODULES FOR THE AZURE RESOURCE
**************************************************************/

 type subnetOptionsType = ({
  @description('Name of subnet.')
  name: string

  @description('IP-address range for subnet.')
  ipAddressRange: string

  @description('Id of Network Security Group to associate with subnet.')
  networkSecurityGroupId: string?

  @description('Id of Route Table to associate with subnet.')
  routeTableId: string?

  @description('Name of the delegation to create for the subnet.')
  delegation: string?
})[]

@sys.description('Name for Hub Network.')
param parHubVirtualNetworkName string

@sys.description('The IP address range for Hub Network.')
param parHubVirtualNetworkAddressPrefixes string


@sys.description('The name of the Network Security Group to associate with the subnet.')
param parNetworkScurityGroup string

@sys.description('The name of the delegation to create for the external subnet.')
param parExternalSubnetName string

@sys.description('The IP address range for the external subnet.')

param parExternalSubnetPrefix string

@sys.description('The name of the delegation to create for the internal subnet.')

param parInternalSubnetName string

@sys.description('The IP address range for the internal subnet.')
param parInternalSubnetPrefix string

@sys.description('The name of the delegation to create for the protected subnet.')
param parProtectedSubnetName string

@sys.description('The IP address range for the protected subnet.')
param parProtectedSubnetPrefix string

 @sys.description('The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param parSubnets subnetOptionsType = [
  {
    name: parExternalSubnetName
    ipAddressRange: parExternalSubnetPrefix
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: parInternalSubnetName
    ipAddressRange: parInternalSubnetPrefix
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: parProtectedSubnetName
    ipAddressRange: parProtectedSubnetPrefix
    networkSecurityGroupId: ''
    routeTableId: ''
  }
] 

@sys.description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array = []



var varSubnetMap = map(range(0, length(parSubnets)), i => {
  name: parSubnets[i].name
  ipAddressRange: parSubnets[i].ipAddressRange
  networkSecurityGroupId: parSubnets[i].?networkSecurityGroupId ?? ''
  routeTableId: parSubnets[i].?routeTableId ?? ''
  delegation: parSubnets[i].?delegation ?? ''
})

var varSubnetProperties = [
  for subnet in varSubnetMap: {
    name: subnet.name
    properties: {
      addressPrefix: subnet.ipAddressRange
      delegations: (empty(subnet.delegation))
        ? null
        : [
            {
              name: subnet.delegation
              properties: {
                serviceName: subnet.delegation
              }
            }
          ]
      networkSecurityGroup: (subnet.delegation == parExternalSubnetName)
        ? {
            id: '${resourceGroup().id}/providers/Microsoft.Network/networkSecurityGroups/${parNetworkScurityGroup}'
          }
        : (empty(subnet.networkSecurityGroupId))
            ? null
            : {
                id: subnet.networkSecurityGroupId
              }
      routeTable: (empty(subnet.routeTableId))
        ? null
        : {
            id: subnet.routeTableId
          }
    }
  }
] 


/* @sys.description('Name for Hub Network.')
param parHubVirtualNetworkName string

@sys.description('The IP address range for Hub Network.')
param parVirtualNetworkAddressPrefixes string

@sys.description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array

@sys.description('The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param parSubnets array */



resource resHubVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: parHubVirtualNetworkName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        parHubVirtualNetworkAddressPrefixes
      ]
    }
    dhcpOptions: {
      dnsServers: parDnsServerIps
    }
    subnets: varSubnetProperties
  }
}



@description('''
Output the Virtual Network resource id
''')
output outHubVirtualNetworkId string = resHubVirtualNetwork.id

@description('''
Output the Virtual Network resource name
''')
output outHubVirtualNetworkName string = resHubVirtualNetwork.name

@description('''
output Virtual Network address prefixes
''')
output outHubVirtualNetworkAddressPrefixes array = resHubVirtualNetwork.properties.addressSpace.addressPrefixes

output outHubSubnets array = resHubVirtualNetwork.properties.subnets
