targetScope = 'managementGroup'

param parCompanyPrefix string
param parDeployHubAndSpokeFortigate bool
param parDeployHubAndSpokeAzureFirewall bool
param parPlatConnectivitySubcriptionId string
param parLandingZoneCorpSubcriptionId string
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
    parPlatConnectivitySubcriptionId: parPlatConnectivitySubcriptionId
    parLandingZoneCorpSubcriptionId: parLandingZoneCorpSubcriptionId
  }  
}


module modAzureFirewall '../hubAndSpokeAzureFirewall/hubAndSpokeAzureFirewall.bicep' = if (parDeployHubAndSpokeAzureFirewall) {
  scope: managementGroup('alz-${parCompanyPrefix}-platform-connectivity')
  name: 'azureFirewall'
  params: {
    parCompanyPrefix: parCompanyPrefix
    parPlatConnectivitySubcriptionId: parPlatConnectivitySubcriptionId
    parLandingZoneCorpSubscriptionId: parLandingZoneCorpSubcriptionId
  }
}
