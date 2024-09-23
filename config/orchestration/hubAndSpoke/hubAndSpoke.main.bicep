targetScope = 'managementGroup'

param parCompanyPrefix string
param parDeployHubAndSpokeFortigate bool
param parDeployHubAndSpokeAzureFirewall bool
param parPlatConnectivitySubscriptionId string
param parLandingZoneCorpSubscriptionId string
param parPlatManagementSubcriptionId string

@secure()
param adminPassword string
param adminUsername string
param parLocation string = 'norwayeast'

module modLogging '../logging/logging.main.bicep' = {
  scope: managementGroup('alz-${parCompanyPrefix}-platform-management')
  name: 'logging'
  params: {
    parCompanyPrefix: parCompanyPrefix
    parLocation: parLocation
    parPlatManagementSubcriptionId:parPlatManagementSubcriptionId
  }
}

module modFortigateHubAndSpoke '../hubAndSpokeFortigate/hubAndSpokeFortigate.bicep' = if (parDeployHubAndSpokeFortigate) {
  scope: managementGroup('alz-${parCompanyPrefix}-platform-connectivity')
  name: 'fortigateHubAndSpoke'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    parCompanyPrefix: parCompanyPrefix
    parLocation: parLocation
    parPlatConnectivitySubscriptionId: parPlatConnectivitySubscriptionId
    parLandingZoneCorpSubscriptionId: parLandingZoneCorpSubscriptionId
  }  
}


module modAzureFirewall '../hubAndSpokeAzureFirewall/hubAndSpokeAzureFirewall.bicep' = if (parDeployHubAndSpokeAzureFirewall) {
  scope: managementGroup('alz-${parCompanyPrefix}-platform-connectivity')
  name: 'azureFirewall'
  params: {
    parCompanyPrefix: parCompanyPrefix
    parPlatConnectivitySubscriptionId: parPlatConnectivitySubscriptionId
    parLandingZoneCorpSubscriptionId: parLandingZoneCorpSubscriptionId
    parLocation: parCompanyPrefix
  }
}
