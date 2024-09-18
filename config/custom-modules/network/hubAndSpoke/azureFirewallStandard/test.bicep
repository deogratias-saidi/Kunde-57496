param location string
param resourceGroup string
param azureFirewallName string
param azureFirewallTier string
param vnetName string
param vnetAddressSpace string
param subnetAddressSpace string
param zones array
param publicIpAddressName string
param publicIpZones array


resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: publicIpZones
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  tags: {}
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefixes: null
          addressPrefix: subnetAddressSpace
        }
      }
    ]
  }
  tags: {}
  dependsOn: []
}

resource stards 'Microsoft.Network/firewallPolicies@2022-07-01' = {
  properties: {
    sku: {
      tier: 'Standard'
    }
  }
  name: 'stards'
  location: 'norwayeast'
  tags: {}
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: azureFirewallName
  location: location
  zones: zones
  properties: {
    ipConfigurations: [
      {
        name: publicIpAddressName
        properties: {
          subnet: {
            id: resourceId(resourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureFirewallSubnet')
          }
          publicIPAddress: {
            id: resourceId(resourceGroup, 'Microsoft.Network/publicIPAddresses', publicIpAddressName)
          }
        }
      }
    ]
    sku: {
      tier: azureFirewallTier
    }
    firewallPolicy: {
      id: resourceId(resourceGroup, 'Microsoft.Network/firewallPolicies', 'stards')
    }
  }
  tags: {}
  
}
