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

param parVpnGatewayEnabled bool
/* param parVpnGatewayConfig object = {}
param parExpressRouteGatewayEnabled bool
param parExpressRouteGatewayConfig object = {}
 */

param parHubVnetId string
param parGatewaySubnetId string
param parGatewayPublicIpId string

param parCompanyPrefix string

/* var varVpnGwConfig = ((parVpnGatewayEnabled) && (!empty(parVpnGatewayConfig)) ? parVpnGatewayConfig : json('{"name": "noconfigVpn"}'))

var varErGwConfig = ((parExpressRouteGatewayEnabled) && !empty(parExpressRouteGatewayConfig) ? parExpressRouteGatewayConfig : json('{"name": "noconfigEr"}'))
 */
/* var varGwConfig = [
  varVpnGwConfig
  varErGwConfig
] */


/* resource resGateway 'Microsoft.Network/virtualNetworkGateways@2023-02-01' = [for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
  name: gateway.name
  location: parLocation
  tags: parTags
  properties: {
    activeActive: gateway.activeActive
    enableBgp: gateway.enableBgp
    enableBgpRouteTranslationForNat: gateway.enableBgpRouteTranslationForNat
    enableDnsForwarding: gateway.enableDnsForwarding
    bgpSettings: (gateway.enableBgp) ? gateway.bgpSettings : null
    gatewayType: gateway.gatewayType
    vpnGatewayGeneration: (toLower(gateway.gatewayType) == 'vpn') ? gateway.generation : 'None'
    vpnType: gateway.vpnType
    sku: {
      name: gateway.sku
      tier: gateway.sku
    }
    vpnClientConfiguration: (toLower(gateway.gatewayType) == 'vpn') ? {
      vpnClientAddressPool: contains(gateway.vpnClientConfiguration, 'vpnClientAddressPool') ? gateway.vpnClientConfiguration.vpnClientAddressPool : ''
      vpnClientProtocols: contains(gateway.vpnClientConfiguration, 'vpnClientProtocols') ? gateway.vpnClientConfiguration.vpnClientProtocols : ''
      vpnAuthenticationTypes: contains(gateway.vpnClientConfiguration, 'vpnAuthenticationTypes') ? gateway.vpnClientConfiguration.vpnAuthenticationTypes : ''
      aadTenant: contains(gateway.vpnClientConfiguration, 'aadTenant') ? gateway.vpnClientConfiguration.aadTenant : ''
      aadAudience: contains(gateway.vpnClientConfiguration, 'aadAudience') ? gateway.vpnClientConfiguration.aadAudience : ''
      aadIssuer: contains(gateway.vpnClientConfiguration, 'aadIssuer') ? gateway.vpnClientConfiguration.aadIssuer : ''
      vpnClientRootCertificates: contains(gateway.vpnClientConfiguration, 'vpnClientRootCertificates') ? gateway.vpnClientConfiguration.vpnClientRootCertificates : ''
      radiusServerAddress: contains(gateway.vpnClientConfiguration, 'radiusServerAddress') ? gateway.vpnClientConfiguration.radiusServerAddress : ''
      radiusServerSecret: contains(gateway.vpnClientConfiguration, 'radiusServerSecret') ? gateway.vpnClientConfiguration.radiusServerSecret : ''
    } : null
    ipConfigurations: [
      {
        id: parHubVnetId
        name: 'vnetGatewayConfig'
        properties: {
          publicIPAddress: {
            id: (((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) ? parGatewayPublicIpId : 'na')
          }
          subnet: {
            id: parGatewaySubnetId
          }
        }
      }
    ]
  }
}] */

param parGwSku string

@description('The is the regional VPN gateway, configured with basic settings. Only deployed if requested.')
resource vgwHub 'Microsoft.Network/virtualNetworkGateways@2023-04-01' = if (parVpnGatewayEnabled) {
  name: toLower('GW-${parCompanyPrefix}-${parRegion}-HUB')
  location: parLocation
  tags: parTags
  properties: {
    enableBgp: true
    sku: {
      name: parGwSku
      tier: parGwSku
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    ipConfigurations: [
      {
        id: parHubVnetId
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: parGatewayPublicIpId
          }
          subnet: {
            id: parGatewaySubnetId
          }
        }
      }
    ]
  }
}
