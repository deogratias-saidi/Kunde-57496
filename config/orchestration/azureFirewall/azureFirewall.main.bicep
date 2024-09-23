targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Hub Networking Module'
metadata description = 'ALZ Bicep Module used to set up Hub Networking'

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

/*************************************************************
      THIS SHOULD BE IN ALL MODULES FOR THE AZURE RESOURCE
**************************************************************/

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

@sys.description('Prefix value which will be prepended to all resource names.')
param parCompanyPrefix string

@sys.description('Name for Hub Network.')
param parHubNetworkName string = toLower('VNET-${parCompanyPrefix}-NOE-HUB')

@sys.description('The IP address range for Hub Network.')
param parHubNetworkAddressPrefix string = '10.150.0.0/16'

@sys.description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array = []

@sys.description('Public IP Address SKU.')
@allowed([
  'Basic'
  'Standard'
])
param parPublicIpSku string = 'Standard'

@sys.description('Optional Suffix for Public IPs. Include a preceding dash if required. Example: -suffix')
param parPublicIpSuffix string = toLower('PIP')

@sys.description('Switch to enable/disable Azure Bastion deployment.')
param parAzBastionEnabled bool

@sys.description('Name Associated with Bastion Service.')
param parAzBastionName string = toLower('Bastion-${parCompanyPrefix}-${parRegion}-HUB')

@sys.description('Azure Bastion SKU.')
@allowed([
  'Basic'
  'Standard'
])
param parAzBastionSku string = 'Basic'

@sys.description('Switch to enable/disable Bastion native client support. This is only supported when the Standard SKU is used for Bastion as documented here: https://learn.microsoft.com/azure/bastion/native-client')
param parAzBastionTunneling bool = parAzBastionEnabled

@sys.description('Switch to enable/disable Azure Firewall deployment.')
param parAzFirewallEnabled bool

@sys.description('Azure Firewall Name.')
param parAzFirewallName string = toLower('AZFW-${parCompanyPrefix}-${parRegion}-HUB')

@sys.description('Set this to true for the initial deployment as one firewall policy is required. Set this to false in subsequent deployments if using custom policies.')
param parAzFirewallPoliciesEnabled bool

@sys.description('Azure Firewall Policies Name.')
param parAzFirewallPoliciesName string = toLower('AZFW-${parCompanyPrefix}-${parRegion}-Policy')

param parAzFirewallDnsProxyEnabled bool

param parAzFirewallAvailabilityZones array

param parDdosEnabled bool
param parDdosProtectionPlanId string = ''

param parConnectivitySubscriptionId string
param parLandingZoneCorpSubscriptionId string
param parSecurityGroupName string = toLower('NSG-${parCompanyPrefix}-${parRegion}-Policy')

@description('The resource group name for the hub resources.')
param parHubResourceGroupName string = toLower('RG-${parCompanyPrefix}-ECMS-${parRegion}-CONN')

@description('The resource group name for the spoke resources.')
param parSpokeResourceGroupName string = toLower('RG-${parCompanyPrefix}-${parRegion}-ID')

@sys.description('Name for Spoke Network.')
param parSpokeNetworkName string = toLower('VNET-${parCompanyPrefix}-${parRegion}-ID')

@sys.description('The IP address range for Spoke Network.')
param parSpokeNetworkAddressPrefix string = '10.151.0.0/16'

@sys.description('The IP address range for Spoke Subnet.')
param spokeSubnetPrefix string = '10.151.0.0/24'

@sys.description('The name of the spoke subnet.')
param spokeSubnetName string = toLower('SNET-${parCompanyPrefix}-ID-DC')

@sys.description('The IP address of the next hop.')
param parNextHopIpAddress string = '10.150.0.68'

@sys.description('The name of the route table.')
param modRouteTableName string = toLower('RT-${parCompanyPrefix}-ID-DC')

@sys.description('Allow forwarded traffic.')
param parAllowSpokeForwardedTraffic bool = true

@sys.description('Allow gateway transit.')
param parAllowHubVpnGatewayTransit bool = false

param parPeerHubId string = 'peer-${parCompanyPrefix}-hub-id'
param ParPeerIdHub string = 'peer-${parCompanyPrefix}-id-hub'

module modHubResourceGroup '../../custom-modules/resourceGroup/resourceGroup.bicep' = {
  scope: subscription(parConnectivitySubscriptionId)
  name: 'hubResourceGroup'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parLocation: parLocation
    parResourceGroupName: parHubResourceGroupName
  }
}

// createa a resource group for spoke network
module modSpokeResourceGroup '../../custom-modules/resourceGroup/resourceGroup.bicep' = {
  scope: subscription(parLandingZoneCorpSubscriptionId)
  name: 'spokeResourceGroup'
  params: {
    parLocation: parLocation
    parLandingZoneEnv: 'Corp'
    parResourceGroupName: parSpokeResourceGroupName
  }
}

param parBastinPublicIpName string = toLower('${parPublicIpSuffix}-${parCompanyPrefix}-${parRegion}-Bastion')

module modBastionPublicIP '../../custom-modules/network/publicIp/publicIp.bicep' = if (parAzBastionEnabled) {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'BastionPublicIP'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parPublicIpName: parBastinPublicIpName
    parPublicIpSku: {
      name: parPublicIpSku
    }
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
  }
  dependsOn: [
    
    modHubResourceGroup
  ]
}

param parAzBastionNsgName string = toLower('NSG-${parCompanyPrefix}-${parRegion}-Bastion')
module modBastionNsg '../../custom-modules/network/networkSecurityGroup/bastionNetworkSecuirityGroup.bicep' = if (parAzBastionEnabled) {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'bastion-nsg'
  params: {
    parAzBastionEnabled: parAzBastionEnabled
    parLocation: parLocation
    parLandingZoneEnv: 'Connectivity'
    parAzBastionNsgName: parAzBastionNsgName
  }
  dependsOn: [
    modHubResourceGroup
    
  ]
}

module modDcNsg '../../custom-modules/network/networkSecurityGroup/networkSecurityGroup.bicep' = {
  scope: resourceGroup(parLandingZoneCorpSubscriptionId, parSpokeResourceGroupName)
  name: 'dc-nsg'
  params: {
    parLocation: parLocation
    parLandingZoneEnv: 'Corp'
    parSecurityGroupName: parSecurityGroupName
  }
  dependsOn: [
    modSpokeResourceGroup
  ]
}

module modBastion '../../custom-modules/network/bastion/bastion.bicep' = if (parAzBastionEnabled) {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'Bastion'
  params: {
    parAzBastionEnabled: parAzBastionEnabled
    parAzBastionName: parAzBastionName
    parAzBastionSku: parAzBastionSku
    parAzBastionTunneling: parAzBastionTunneling
    parBastionSubnetId: modHubVnet.outputs.outBastionSubnetId
    parLocation: parLocation
    parPublicIp: modBastionPublicIP.outputs.outPublicIpId
    parLandingZoneEnv: 'Connectivity'
  }
  dependsOn: [
    modGateway
    modHubResourceGroup
  ]
}

module modHubVnet '../../custom-modules/network/virtualNetwork/hubVirtualNetworkAzureFirewall.bicep' = {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'HubVnet'
  params: {
    parDdosEnabled: parDdosEnabled
    parDdosProtectionPlanId: parDdosProtectionPlanId
    parDnsServerIps: parDnsServerIps
    parHubNetworkAddressPrefix: parHubNetworkAddressPrefix
    parHubNetworkName: parHubNetworkName
    parLocation: parLocation
    parAzFirewallEnabled: parAzFirewallEnabled
    parAzBastionEnabled: parAzBastionEnabled
    parAzBastionNsgName: modBastionNsg.outputs.outBastionNameNgsName
    parLandingZoneEnv: 'Connectivity'
  }
  dependsOn: [
    modHubResourceGroup
    modBastionNsg
  ]
}

module modSpokeVirtualNetwork '../../custom-modules/network/virtualNetwork/spokeVirtualNetwork.bicep' = {
  scope: resourceGroup(parLandingZoneCorpSubscriptionId, parSpokeResourceGroupName)
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

// Module - Hub to Spoke peering.
module modHubPeeringToSpoke '../../custom-modules/network/networkPeering/networkPeering.bicep' = {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'hubPeeringToSpoke'
  params: {
    parDestinationVirtualNetworkId: modSpokeVirtualNetwork.outputs.outSpokeVirtualNetworkId
    parDestinationVirtualNetworkName: parPeerHubId
    parAllowForwardedTraffic: parAllowSpokeForwardedTraffic
    parSourceVirtualNetworkName: modHubVnet.outputs.outHubVnetName
    parAllowGatewayTransit: parAllowHubVpnGatewayTransit
  }
  dependsOn: [
    modHubVnet
    modSpokeVirtualNetwork
  ]
}

// Module - Spoke to Hub peering.
module modSpokePeeringToHub '../../custom-modules/network/networkPeering/networkPeering.bicep' = {
  scope: resourceGroup(parLandingZoneCorpSubscriptionId, parSpokeResourceGroupName)
  name: 'spokePeeringToHub'
  params: {
    parDestinationVirtualNetworkId: modHubVnet.outputs.outHubVnetId
    parDestinationVirtualNetworkName: ParPeerIdHub
    parAllowForwardedTraffic: parAllowSpokeForwardedTraffic
    parSourceVirtualNetworkName: modSpokeVirtualNetwork.outputs.outSpokeVirtualNetworkName
    parUseRemoteGateways: parAllowHubVpnGatewayTransit
  }
  dependsOn: [
    modHubVnet
    modSpokeVirtualNetwork
    modSpokeResourceGroup
  ]
}

module modRouteTable '../../custom-modules/network/routeTable/routeTable.bicep' = {
  scope: resourceGroup(parLandingZoneCorpSubscriptionId, parSpokeResourceGroupName)
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

module modAzureFirewallMgmtPublicIp '../../custom-modules/network/publicIp/publicIp.bicep' = {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'AzureFirewallMgmtPublicIP'
  params: {
    parLandingZoneEnv: 'Connectivity'
    parPublicIpName: toLower('${parPublicIpSuffix}-MGMT-${parCompanyPrefix}-${parRegion}-CONN')
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parPublicIpSku: {
      name: 'Standard'
    }
  }
  dependsOn: [
    modHubResourceGroup
  ]
}

module modAzureFirewallPublicIp '../../custom-modules/network/publicIp/publicIp.bicep' = if (parAzFirewallEnabled) {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'deploy-Firewall-Public-IP'
  params: {
    parLocation: parLocation
    parAvailabilityZones: parAzFirewallAvailabilityZones
    parPublicIpName: toLower('${parPublicIpSuffix}-FW-${parCompanyPrefix}-${parRegion}-CONN')
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parPublicIpSku: {
      name: parPublicIpSku
    }
    parLandingZoneEnv: 'Connectivity'
  }
  dependsOn: [
    modHubResourceGroup
  ]
}
module modGatewayPublicIp '../../custom-modules/network/publicIp/publicIp.bicep' = if (parVpnGatewayEnabled) {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'deployGatewayPublicIP'
  params: {
    parTags: parTags
    parLocation: parLocation
    parAvailabilityZones: parAzFirewallAvailabilityZones
    parPublicIpName: toLower('${parPublicIpSuffix}-GW-${parCompanyPrefix}-${parRegion}-CONN')
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parPublicIpSku: {
      name: parPublicIpSku
    }
    parLandingZoneEnv: 'Connectivity'
  }
  dependsOn: [
    modHubResourceGroup
  ]
}
@allowed([
  'Basic'
  'Standard'
])
param parAzFirewallTier string

module modAzureFirewall '../../custom-modules/network/hubAndSpoke/azureFirewallBasic/azureFirewall.bicep' = {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'AzureFirewall'
  params: {
    parAzFirewallDnsProxyEnabled: parAzFirewallDnsProxyEnabled
    parAzFirewallEnabled: parAzFirewallEnabled
    parAzFirewallName: parAzFirewallName
    parAzFirewallPoliciesEnabled: parAzFirewallPoliciesEnabled
    parAzureFirewallMgmtPublicIpId: modAzureFirewallMgmtPublicIp.outputs.outPublicIpId
    parAzureFirewallMgmtSubnetId: modHubVnet.outputs.outAzureFirewallMgmtSubnetId
    parAzureFirewallPublicIpId: modAzureFirewallPublicIp.outputs.outPublicIpId
    parAzureFirewallSubnetId: modHubVnet.outputs.outAzureFirewallSubnetId
    parLandingZoneEnv: 'Connectivity'
    parAzFirewallPoliciesName: parAzFirewallPoliciesName
    parAzFirewallTier: parAzFirewallTier
  }
  dependsOn: [
    modHubResourceGroup
  ]
}

param parVpnGatewayEnabled bool = true
module modGateway '../../custom-modules/network/gateway/newGateway.bicep' = {
  scope: resourceGroup(parConnectivitySubscriptionId, parHubResourceGroupName)
  name: 'gateway'
  params: {
    parGatewayPublicIpId: modGatewayPublicIp.outputs.outPublicIpId
    parGatewaySubnetId: modHubVnet.outputs.outGatewaySubnetId
    parHubVnetId: modHubVnet.outputs.outHubVnetId
    parLandingZoneEnv: 'Connectivity'
    parVpnGatewayEnabled: parVpnGatewayEnabled
    parCompanyPrefix: parCompanyPrefix
  }
  dependsOn: [
    modAzureFirewall
    modGatewayPublicIp
    modHubResourceGroup
    modHubVnet
  ]
}
