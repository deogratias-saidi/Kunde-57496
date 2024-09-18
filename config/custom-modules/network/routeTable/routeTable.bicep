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


@sys.description('Name of Route table to create for the default route of Hub.')
param parRouteTableName string

@sys.description('IP Address where network traffic should route to leveraged with DNS Proxy.')
param parNextHopIpAddress string

@sys.description('Switch to enable/disable BGP Propagation on route table.')
param parDisableBgpRoutePropagation bool = false

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
resource resSpokeToHubRouteTable 'Microsoft.Network/routeTables@2023-02-01' = if (!empty(parNextHopIpAddress)) {
  name: parRouteTableName
  location: parLocation
  tags: parTags
  properties: {
    
    routes: [
      {
        name: 'udr-default-to-hub-nva'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parNextHopIpAddress
        }
      }
    ]
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
  }
}





output resSpokeToHubRouteTableName string = resSpokeToHubRouteTable.name
output resSpokeToHubRouteTableId string = resSpokeToHubRouteTable.id



