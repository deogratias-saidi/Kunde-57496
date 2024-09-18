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
param parCompanyPrefix string

@sys.description('Switch to enable/disable VPN virtual network gateway deployment.')
param parVpnGatewayEnabled bool = true

//ASN must be 65515 if deploying VPN & ER for co-existence to work: https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-coexist-resource-manager#limits-and-limitations
@sys.description('Configuration for VPN virtual network gateway to be deployed.')
param parVpnGatewayConfig object = {
  name: '${parCompanyPrefix}-Vpn-Gateway'
  gatewayType: 'Vpn'
  sku: 'VpnGw1AZ'
  vpnType: 'RouteBased'
  generation: 'Generation1'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: 65515
    bgpPeeringAddress: ''
    peerWeight: 5
  }
  vpnClientConfiguration: {}
}

@sys.description('Switch to enable/disable ExpressRoute virtual network gateway deployment.')
param parExpressRouteGatewayEnabled bool = false

@sys.description('Configuration for ExpressRoute virtual network gateway to be deployed.')
param parExpressRouteGatewayConfig object = {
  name: '${parCompanyPrefix}-ExpressRoute-Gateway'
  gatewayType: 'ExpressRoute'
  sku: 'ErGw1AZ'
  vpnType: 'RouteBased'
  vpnGatewayGeneration: 'None'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: '65515'
    bgpPeeringAddress: ''
    peerWeight: '5'
  }
}

param parHubVnetId string
param parGatewaySubnetId string
param parGatewayPublicIpId string

var varVpnGwConfig = ((parVpnGatewayEnabled) && (!empty(parVpnGatewayConfig)) ? parVpnGatewayConfig : json('{"name": "noconfigVpn"}'))

var varErGwConfig = ((parExpressRouteGatewayEnabled) && !empty(parExpressRouteGatewayConfig) ? parExpressRouteGatewayConfig : json('{"name": "noconfigEr"}'))

var varGwConfig = [
  varVpnGwConfig
  varErGwConfig
]


//Minumum subnet size is /27 supporting documentation https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub
resource resGateway 'Microsoft.Network/virtualNetworkGateways@2023-02-01' = [for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
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
      vpnClientAddressPool: gateway.vpnClientConfiguration.?vpnClientAddressPool ?? ''
      vpnClientProtocols: gateway.vpnClientConfiguration.?vpnClientProtocols ?? ''
      vpnAuthenticationTypes: gateway.vpnClientConfiguration.?vpnAuthenticationTypes ?? ''
      aadTenant: gateway.vpnClientConfiguration.?aadTenant ?? ''
      aadAudience: gateway.vpnClientConfiguration.?aadAudience ?? ''
      aadIssuer: gateway.vpnClientConfiguration.?aadIssuer ?? ''
      vpnClientRootCertificates: gateway.vpnClientConfiguration.?vpnClientRootCertificates ?? ''
      radiusServerAddress: gateway.vpnClientConfiguration.?radiusServerAddress ?? ''
      radiusServerSecret: gateway.vpnClientConfiguration.?radiusServerSecret ?? ''
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
}]
