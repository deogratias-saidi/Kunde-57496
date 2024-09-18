targetScope = 'managementGroup'

param parCompanyPrefix string
param parLandingZoneCorpSubcriptionId string
param parPlatConnectivitySubcriptionId string

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
    parPlatConnectivitySubcriptionId:parPlatConnectivitySubcriptionId
    parLandingZoneCorpSubcriptionId:parLandingZoneCorpSubcriptionId
    parLocation:parLocation
  }
} 


