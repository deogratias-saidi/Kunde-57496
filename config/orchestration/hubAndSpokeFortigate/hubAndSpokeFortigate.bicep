targetScope = 'managementGroup'

param parCompanyPrefix string
param parLandingZoneCorpSubscriptionId string
param parPlatConnectivitySubscriptionId string

@secure()
param adminPassword string
param adminUsername string
param parLocation string = 'norwayeast'


module modFortigateHubAndSpoke '../../custom-modules/network/hubAndSpoke/fortigate/hubAndSpokeFortigate.main.bicep' = {
  scope:managementGroup('alz-${parCompanyPrefix}-platform-connectivity')
  name: 'fortigateHubAndSpoke'
  params: {
    adminPassword:adminPassword
    adminUsername:adminUsername
    parCompanyPrefix: parCompanyPrefix
    parPlatConnectivitySubscriptionId:parPlatConnectivitySubscriptionId
    parLandingZoneCorpSubscriptionId:parLandingZoneCorpSubscriptionId
    parLocation:parLocation
  }
} 


