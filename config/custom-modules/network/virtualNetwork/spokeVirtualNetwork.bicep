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

@description('Internal Subnet Name')
param spokeSubnetName string

@sys.description('Id of the DdosProtectionPlan which will be applied to the Virtual Network.')
param parDdosProtectionPlanId string = ''

@sys.description('The IP address range for all virtual networks to use.')
param parSpokeNetworkAddressPrefix string

@sys.description('The Name of the Spoke Virtual Network.')
param parSpokeNetworkName string

@sys.description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array = []

@description('IP address range for spoke subnet.')
param spokeSubnetPrefix string

@description('Route Table Id for the Spoke Virtual Network')
param resSpokeToHubRouteTableId string

//If Ddos parameter is true Ddos will be Enabled on the Virtual Network
//If Azure Firewall is enabled and Network DNS Proxy is enabled DNS will be configured to point to AzureFirewall
resource resSpokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: parSpokeNetworkName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        parSpokeNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: spokeSubnetName
        properties: {
          addressPrefix: spokeSubnetPrefix
          routeTable:{
          id: resSpokeToHubRouteTableId
        }
        }
      }
    ]
    enableDdosProtection: (!empty(parDdosProtectionPlanId) ? true : false)
    ddosProtectionPlan: (!empty(parDdosProtectionPlanId) ? true : false)
      ? {
          id: parDdosProtectionPlanId
        }
      : null
    dhcpOptions: (!empty(parDnsServerIps) ? true : false)
      ? {
          dnsServers: parDnsServerIps
        }
      : null
  }
}






output outSpokeVirtualNetworkName string = resSpokeVirtualNetwork.name
output outSpokeVirtualNetworkId string = resSpokeVirtualNetwork.id
