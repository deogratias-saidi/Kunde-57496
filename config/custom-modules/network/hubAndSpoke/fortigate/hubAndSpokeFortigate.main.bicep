targetScope = 'managementGroup'

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

@description('''
Azure Region to deploy the resources into:
If nothing else is specified or agreed by the customer, the default deployment region will be Norway East.
- West Europe: westeurope
- North Europe: northeurope
- East Norway: norwayeast
''')
param parLocation string

@description('''
The location abbreviation for the region
- Norway East: NOE
- North Europe: NEU
- West Europe: WEU
''')
param parRegion string = parLocation == 'norwayeast'
  ? 'NOE'
  : parLocation == 'westeurope' ? 'WEU' : parLocation == 'northeurope' ? 'NEU' : 'NOE'

@sys.description('''
Prefix value which will be prepended to all resource names. KNR = Kundenr i VISMA
EX: 10000 = ECIT
''')
@maxLength(5)
param parCompanyPrefix string

@sys.description('Name for Hub Network.')
param parHubVirtualNetworkName string = toLower('VNET-${parCompanyPrefix}-${parRegion}-HUB')

@sys.description('The IP address range for Hub Network.')
param parHubVirtualNetworkAddressPrefixes string = '10.150.0.0/16'

@description('External Subnet Name')
param parExternalSubnetName string = toLower('SNET-${parCompanyPrefix}-HUB-NVA-EXT')

@description('IP address range for external subnet.')
param parExternalSubnetPrefix string = '10.150.0.0/26'

@description('Internal Subnet Name')
param parInternalSubnetName string = toLower('SNET-${parCompanyPrefix}-HUB-NVA-INT')

@description('IP address range for internal subnet.')
param parInternalSubnetPrefix string = '10.150.0.64/26'

@description('Protected Subnet Name')
param parProtectedSubnetName string = toLower('SNET-${parCompanyPrefix}-HUB-NVA-PROTECTED')
@description('IP address range for protected subnet.')
param parProtectedSubnetPrefix string = '10.150.1.0/26'

@sys.description('Name for Spoke Network.')
param parSpokeNetworkName string = toLower('VNET-${parCompanyPrefix}-${parRegion}-ID')

@sys.description('The IP address range for Spoke Network.')
param parSpokeNetworkAddressPrefix string = '10.151.0.0/16'

@sys.description('The IP address range for Spoke Subnet.')
param spokeSubnetPrefix string = '10.151.0.0/24'

@sys.description('The name of the spoke subnet.')
param spokeSubnetName string = toLower('SNET-${parCompanyPrefix}-SPOKE-NVA')

@sys.description('The IP address of the next hop.')
param parNextHopIpAddress string = '10.150.0.68'

@sys.description('The name of the route table.')
param modRouteTableName string = toLower('RT-${parCompanyPrefix}-SPOKE-NVA')

@sys.description('The subscription id for the connectivity subscription.')
param parPlatConnectivitySubcriptionId string

@sys.description('The resource group name for the hub resources.')
param parHubResourceGroupName string = toLower('RG-${parCompanyPrefix}-ECMS-${parRegion}-CONN')

@sys.description('The subscription id for the corporate subscription.')
param parLandingZoneCorpSubcriptionId string

@sys.description('The resource group name for the spoke resources.')
param parSpokeResourceGroupName string = toLower('RG-${parCompanyPrefix}-${parRegion}-ID')

@sys.description('Allow forwarded traffic.')
param parAllowSpokeForwardedTraffic bool = true

@sys.description('Allow gateway transit.')
param parAllowHubVpnGatewayTransit bool = false

param parNetworkScurityGroupName string = toLower('NSG-${parCompanyPrefix}-ID-DC')

param parSecurityGroupSecurityRules array = [
  // create a security rule thatt allowes all for inbound and outbound
  {
    name: 'AllowAllInbound'
    properties: {
      priority: 100
      direction: 'Inbound'
      access: 'Allow'
      destinationPortRange: '*'
      destinationAddressPrefix: '*'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      protocol: '*'
    }
  }
  {
    name: 'AllowAllOutbound'
    properties: {
      priority: 100
      direction: 'Outbound'
      access: 'Allow'
      destinationPortRange: '*'
      destinationAddressPrefix: '*'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      protocol: '*'
    }
  }
]

@sys.description('''
The name of the external nic.
''')
param parExternalNetworkInterfaceName string = toLower('NIC-${parCompanyPrefix}-HUB-NVA-EXT')

@sys.description('''
The username for the Fortigate.
''')
param adminUsername string

@sys.description('''
The password for the Fortigate.
''')
@secure()
param adminPassword string
@sys.description('''
The name of the internal nic.
''')
param parInternalNetworkInterfaceName string = toLower('NIC-${parCompanyPrefix}-HUB-NVA-INT')

@sys.description('''
The name of the fortigate.
''')
param parFortigateName string = toLower('FGT-${parCompanyPrefix}-${parRegion}-HUB-NVA')

@sys.description('''
Public IP name for the Fortigate.
''')
param parPublicIpName string = toLower('PIP-${parFortigateName}')

// createa a resource group for hub network

module modHubResourceGroup '../../../resourceGroup/resourceGroup.bicep' = {
  scope: subscription(parPlatConnectivitySubcriptionId)
  name: 'hubResourceGroup'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parLocation: parLocation
    parResourceGroupName: parHubResourceGroupName
  }
}

// createa a resource group for spoke network
module modSpokeResourceGroup '../../../resourceGroup/resourceGroup.bicep' = {
  scope: subscription(parLandingZoneCorpSubcriptionId)
  name: 'spokeResourceGroup'
  params: {
    parLocation: parLocation
    parLandingZoneEnv: 'Corp'
    parResourceGroupName: parSpokeResourceGroupName
  }
}

module modHubVirtualNetwork '../../virtualNetwork/hubVirtualNetwork.bicep' = {
  scope: resourceGroup(parPlatConnectivitySubcriptionId, parHubResourceGroupName)
  name: 'HubVirtualNetwork'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parHubVirtualNetworkAddressPrefixes: parHubVirtualNetworkAddressPrefixes
    parHubVirtualNetworkName: parHubVirtualNetworkName
    parInternalSubnetPrefix: parInternalSubnetPrefix
    parExternalSubnetName: parExternalSubnetName
    parExternalSubnetPrefix: parExternalSubnetPrefix
    parInternalSubnetName: parInternalSubnetName
    parNetworkScurityGroup: parNetworkScurityGroupName
    parProtectedSubnetName: parProtectedSubnetName
    parProtectedSubnetPrefix: parProtectedSubnetPrefix
  }
  dependsOn: [
    modSpokeResourceGroup
    modHubResourceGroup
  ]
}

module modSpokeVirtualNetwork '../../virtualNetwork/spokeVirtualNetwork.bicep' = {
  scope: resourceGroup(parLandingZoneCorpSubcriptionId, parSpokeResourceGroupName)
  name: 'SpokeVirtualNetwork'
  params: {
    parLandingZoneEnv: 'Corp'
    parSpokeNetworkAddressPrefix: parSpokeNetworkAddressPrefix
    parSpokeNetworkName: parSpokeNetworkName
    resSpokeToHubRouteTableId: modRouteTable.outputs.resSpokeToHubRouteTableId
    spokeSubnetName: spokeSubnetName
    spokeSubnetPrefix: spokeSubnetPrefix
  }
  dependsOn: [
    modSpokeResourceGroup
    modHubResourceGroup
  ]
}

module modNetworkSecurityGroup '../../networkSecurityGroup/networkSecurityGroup.bicep' = {
  scope: resourceGroup(parPlatConnectivitySubcriptionId, parHubResourceGroupName)
  name: 'networkSecurityGroup'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parSecurityGroupName: parNetworkScurityGroupName
    parSecurityGroupSecurityRules: parSecurityGroupSecurityRules
  }
  dependsOn: [
    modHubResourceGroup
  ]
}

module modRouteTable '../../routeTable/routeTable.bicep' = {
  scope: resourceGroup(parLandingZoneCorpSubcriptionId, parSpokeResourceGroupName)
  name: 'modRouteTable'
  params: {
    parRouteTableName: modRouteTableName
    parLandingZoneEnv: 'Corp'
    parNextHopIpAddress: parNextHopIpAddress
  }
  dependsOn: [
    modSpokeResourceGroup
  ]
}

// Module - Hub to Spoke peering.
module modHubPeeringToSpoke '../../networkPeering/networkPeering.bicep' = {
  scope: resourceGroup(parPlatConnectivitySubcriptionId, parHubResourceGroupName)
  name: 'hubPeeringToSpoke'
  params: {
    parDestinationVirtualNetworkId: modSpokeVirtualNetwork.outputs.outSpokeVirtualNetworkId
    parDestinationVirtualNetworkName: parSpokeNetworkName
    parAllowForwardedTraffic: parAllowSpokeForwardedTraffic
    parSourceVirtualNetworkName: parHubVirtualNetworkName
    parAllowGatewayTransit: parAllowHubVpnGatewayTransit
  }
  dependsOn: [
    modHubVirtualNetwork
    modSpokeVirtualNetwork
  ]
}

// Module - Spoke to Hub peering.
module modSpokePeeringToHub '../../networkPeering/networkPeering.bicep' = {
  scope: resourceGroup(parLandingZoneCorpSubcriptionId, parSpokeResourceGroupName)
  name: 'spokePeeringToHub'
  params: {
    parDestinationVirtualNetworkId: modHubVirtualNetwork.outputs.outHubVirtualNetworkId
    parDestinationVirtualNetworkName: parHubVirtualNetworkName
    parAllowForwardedTraffic: parAllowSpokeForwardedTraffic
    parSourceVirtualNetworkName: modSpokeVirtualNetwork.outputs.outSpokeVirtualNetworkName
    parUseRemoteGateways: parAllowHubVpnGatewayTransit
  }
  dependsOn: [
    modHubVirtualNetwork
    modSpokeVirtualNetwork
    modSpokeResourceGroup
  ]
}

module modPublicIp '../../publicIp/publicIp.bicep' = {
  scope: resourceGroup(parPlatConnectivitySubcriptionId, parHubResourceGroupName)
  name: 'publicIp'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parPublicIpName: parPublicIpName
    parPublicIpProperties: {
      publicIpAllocationMethod: 'Static'
      publicIpAddressVersion: 'IPv4'
    }
    parPublicIpSku: {
      name: 'Standard'
    }
  }
  dependsOn: [
    modHubResourceGroup
    modSpokeResourceGroup
  ]
}

module modExternalNetorkInterfaceCard '../../networkInterfaceCard/networkInterfaceCard.bicep' = {
  scope: resourceGroup(parPlatConnectivitySubcriptionId, parHubResourceGroupName)
  name: 'networkInterfaceCard'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parSubnetId: modHubVirtualNetwork.outputs.outHubSubnets[0].id
    parNetworkInterfaceName: parExternalNetworkInterfaceName
    parNetworkSecurityGroudId: modNetworkSecurityGroup.outputs.resNetworkSecurityGroupId
    parPublicIPAddressId: modPublicIp.outputs.outPublicIpId
  }
  dependsOn: [
    modHubResourceGroup
    modPublicIp
    modSpokeResourceGroup
  ]
}

module modInternalNetorkInterfaceCard '../../networkInterfaceCard/networkInterfaceCardNoPIP.bicep' = {
  scope: resourceGroup(parPlatConnectivitySubcriptionId, parHubResourceGroupName)
  name: 'networkInterfaceCardNoPublicIP'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parSubnetId: modHubVirtualNetwork.outputs.outHubSubnets[1].id
    parNetworkInterfaceName: parInternalNetworkInterfaceName
    parNetworkSecurityGroudId: modNetworkSecurityGroup.outputs.resNetworkSecurityGroupId
  }
  dependsOn: [
    modHubResourceGroup
    modSpokeResourceGroup
  ]
}

module modFortigateVirtualAppliance '../../hubAndSpoke/fortigate/fortigateVirtualMachine.bicep' = {
  scope: resourceGroup(parPlatConnectivitySubcriptionId, parHubResourceGroupName)
  name: 'fortigateVirtualAppliance'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    externalNicId: modExternalNetorkInterfaceCard.outputs.outNetworkInterfaceCardId
    externalStartAddress: '10.150.0.4'
    externalSubnetPrefix: parExternalSubnetPrefix
    internalNicId: modInternalNetorkInterfaceCard.outputs.outNetworkInterfaceCardId
    internalStartAddress: '10.150.0.68'
    internalSubnetPrefix: parInternalSubnetPrefix
    parFortigateName: parFortigateName
    parLandingZoneEnv: 'Connectivity'
    vnetAddressPrefix: modHubVirtualNetwork.outputs.outHubVirtualNetworkAddressPrefixes
  }
  dependsOn: [
    modHubResourceGroup
    modExternalNetorkInterfaceCard
    modInternalNetorkInterfaceCard
    modSpokeResourceGroup
  ]
}
