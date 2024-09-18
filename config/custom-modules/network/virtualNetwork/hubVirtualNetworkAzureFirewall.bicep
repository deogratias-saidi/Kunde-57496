
param parHubNetworkName string
param parLocation string
param parHubNetworkAddressPrefix string
param parDnsServerIps array
param parDdosEnabled bool
param parDdosProtectionPlanId string
param parAzFirewallEnabled bool
param parAzBastionEnabled bool
param parAzBastionNsgName string

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

@sys.description('The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param parSubnets subnetOptionsType = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.150.252.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.150.253.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.150.254.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallManagementSubnet'
    ipAddressRange: '10.150.255.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]


var varSubnetMap = map(range(0, length(parSubnets)), i => {
  name: parSubnets[i].name
  ipAddressRange: parSubnets[i].ipAddressRange
  networkSecurityGroupId: parSubnets[i].?networkSecurityGroupId ?? ''
  routeTableId: parSubnets[i].?routeTableId ?? ''
  delegation: parSubnets[i].?delegation ?? ''
})

var varSubnetProperties = [for subnet in varSubnetMap: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange

    delegations: (empty(subnet.delegation)) ? null : [
      {
        name: subnet.delegation
        properties: {
          serviceName: subnet.delegation
        }
      }
    ]

    networkSecurityGroup: (subnet.name == 'AzureBastionSubnet' && parAzBastionEnabled) ? {
      id: '${resourceGroup().id}/providers/Microsoft.Network/networkSecurityGroups/${parAzBastionNsgName}'
    } : (empty(subnet.networkSecurityGroupId)) ? null : {
      id: subnet.networkSecurityGroupId
    }

    routeTable: (empty(subnet.routeTableId)) ? null : {
      id: subnet.routeTableId
    }
  }
}]


resource resBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = if (parAzBastionEnabled && (contains(map(parSubnets, subnets => subnets.name), 'AzureBastionSubnet'))) {
  parent: resHubVnet
  name: 'AzureBastionSubnet'
}

resource resAzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = if (parAzFirewallEnabled && (contains(map(parSubnets, subnets => subnets.name), 'AzureFirewallSubnet'))) {
  parent: resHubVnet
  name: 'AzureFirewallSubnet'
}

resource resAzureFirewallMgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = if (parAzFirewallEnabled && (contains(map(parSubnets, subnets => subnets.name), 'AzureFirewallManagementSubnet'))) {
  parent: resHubVnet
  name: 'AzureFirewallManagementSubnet'
}

resource resVpnGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = if (parAzFirewallEnabled && (contains(map(parSubnets, subnets => subnets.name), 'GatewaySubnet'))) {
  parent: resHubVnet
  name: 'GatewaySubnet'
}

/* resource resHubSubnetExternal 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = if ( (contains(map(parSubnets, subnets => subnets.name), 'SNET-${parCompanyPrefix}-HUB-NVA-EXT'))) {
  name: 'External'
  parent:resHubVnet
}

resource resHubSubnetInternal 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = if ((contains(map(parSubnets, subnets => subnets.name), 'SNET-${parCompanyPrefix}-HUB-NVA-INT'))) {
  name: 'Internal'
  parent:resHubVnet
} */


resource resHubVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: parHubNetworkName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        parHubNetworkAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: parDnsServerIps
    }
    subnets: varSubnetProperties
    enableDdosProtection: parDdosEnabled
    ddosProtectionPlan: (parDdosEnabled) ? {
      id: parDdosProtectionPlanId
    } : null
  }
}


output outHubVnetId string = resHubVnet.id
output outHubVnetName string = resHubVnet.name
output outAzureFirewallSubnetId string = resAzureFirewallSubnet.id
output outAzureFirewallSubnetName string = resAzureFirewallSubnet.name
output outAzureFirewallMgmtSubnetId string = resAzureFirewallMgmtSubnet.id
output outAzureFirewallMgmtSubnetName string = resAzureFirewallMgmtSubnet.name
output outBastionSubnetId string = resBastionSubnet.id
output outBastionSubnetaName string = resBastionSubnet.name
output outGatewaySubnetId string = resVpnGatewaySubnet.id
/* output outExternalSubnetId string = resHubSubnetExternal.id
output outInternalSubnetId string = resHubSubnetInternal.id */
