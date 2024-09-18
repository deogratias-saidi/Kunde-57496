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
param parTags object = {
  Region: parRegion
  ResponsibleProvider: parResposibleProvider
  LZ: parLandingZoneEnv
}



/*************************************************************
      THIS SHOULD BE IN ALL MODULES FOR THE AZURE RESOURCE
**************************************************************/

param parAzFirewallEnabled bool
param parAzFirewallPoliciesEnabled bool

param parAzFirewallPoliciesName string
param parAzFirewallTier string
param parAzFirewallDnsProxyEnabled bool
param parAzFirewallDnsServers array = []
param parAzFirewallIntelMode string = 'Alert'

resource resFirewallPolicies 'Microsoft.Network/firewallPolicies@2023-02-01' = if (parAzFirewallEnabled && parAzFirewallPoliciesEnabled) {
  name: parAzFirewallPoliciesName
  location: parLocation
  tags: parTags
  properties: (parAzFirewallTier == parAzFirewallTier) ? {
    sku: {
      tier: parAzFirewallTier
    }
    threatIntelMode: 'Alert'
  } : {
    dnsSettings: {
      enableProxy: parAzFirewallDnsProxyEnabled
      servers: parAzFirewallDnsServers
    }
    sku: {
      tier: parAzFirewallTier
    }
    threatIntelMode: parAzFirewallIntelMode
  }
}


param parAzFirewallName string
param parAzFirewallCustomPublicIps array = []
param parAzFirewallAvailabilityZones array = []

var varAzFirewallUseCustomPublicIps = length(parAzFirewallCustomPublicIps) > 0

param parAzureFirewallSubnetId string
param parAzureFirewallPublicIpId string
param parAzureFirewallMgmtPublicIpId string
param parAzureFirewallMgmtSubnetId string

resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2023-02-01' = if (parAzFirewallEnabled) {
  name: parAzFirewallName
  location: parLocation
  tags: parTags
  zones: (!empty(parAzFirewallAvailabilityZones) ? parAzFirewallAvailabilityZones : [])
  properties: parAzFirewallTier == 'Basic' ? {
    ipConfigurations: varAzFirewallUseCustomPublicIps
     ? map(parAzFirewallCustomPublicIps, ip =>
       {
        name: 'ipconfig${uniqueString(ip)}'
        properties: ip == parAzFirewallCustomPublicIps[0]
         ? {
          subnet: {
            id: parAzureFirewallSubnetId
          }
          publicIPAddress: {
            id: parAzFirewallEnabled ? ip : ''
          }
        }
         : {
          publicIPAddress: {
            id: parAzFirewallEnabled ? ip : ''
          }
        }
      })
     : [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: parAzureFirewallSubnetId
          }
          publicIPAddress: {
            id: parAzFirewallEnabled ? parAzureFirewallPublicIpId : ''
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: 'mgmtIpConfig'
      properties: {
        publicIPAddress: {
          id: parAzFirewallEnabled ? parAzureFirewallMgmtPublicIpId : ''
        }
        subnet: {
          id: parAzureFirewallMgmtSubnetId
        }
      }
    }
    sku: {
      name: 'AZFW_VNet'
      tier: parAzFirewallTier
    }
    firewallPolicy: {
      id: resFirewallPolicies.id
    }
  } : {
    ipConfigurations: varAzFirewallUseCustomPublicIps
     ? map(parAzFirewallCustomPublicIps, ip =>
       {
        name: 'ipconfig${uniqueString(ip)}'
        properties: ip == parAzFirewallCustomPublicIps[0]
         ? {
          subnet: {
            id: parAzureFirewallSubnetId
          }
          publicIPAddress: {
            id: parAzFirewallEnabled ? ip : ''
          }
        }
         : {
          publicIPAddress: {
            id: parAzFirewallEnabled ? ip : ''
          }
        }
      })
     : [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: parAzureFirewallSubnetId
          }
          publicIPAddress: {
            id: parAzFirewallEnabled ? parAzureFirewallPublicIpId : ''
          }
        }
      }
    ]
    sku: {
      name: 'AZFW_VNet'
      tier: parAzFirewallTier
    }
    firewallPolicy: {
      id: resFirewallPolicies.id
    }
  }
  
  
}
