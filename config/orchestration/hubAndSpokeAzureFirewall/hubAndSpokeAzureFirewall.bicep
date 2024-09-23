targetScope = 'managementGroup'

param parCompanyPrefix string
param parPlatConnectivitySubscriptionId string
param parLandingZoneCorpSubscriptionId string
param parLocation string 
param parAzFirewallTier string = 'Standard'


module modAzureFirewall '../azureFirewall/azureFirewall.main.bicep' = {
  scope: managementGroup('alz-${parCompanyPrefix}-platform-connectivity')
  name: 'azureFirewall'
  params: {
    parAzBastionEnabled: true
    parAzFirewallAvailabilityZones: ['2']
    parAzFirewallDnsProxyEnabled: false
    parAzFirewallEnabled: true
    parAzFirewallPoliciesEnabled: true
    parCompanyPrefix: parCompanyPrefix
    parConnectivitySubscriptionId: parPlatConnectivitySubscriptionId
    parLandingZoneCorpSubscriptionId: parLandingZoneCorpSubscriptionId
    parDdosEnabled: false
    parLocation: parLocation
    parLandingZoneEnv: 'Connectivity'
    parAzFirewallTier: parAzFirewallTier
  }
}
