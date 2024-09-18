targetScope = 'managementGroup'

@sys.description('Subscription ID for Platform Management')
param parPlatManagementSubcriptionId string 

@sys.description('Location for the resources')
param parLocation string

@sys.description('''
The location abbreviation for the region
- Norway East: NOE
- North Europe: NEU
- West Europe: WEU
''')
param parRegion string = parLocation == 'norwayeast'
? 'NOE'
: parLocation == 'westeurope' ? 'WEU' : parLocation == 'northeurope' ? 'NEU' : 'NOE'

@sys.description('''
Prefix value which will be prepended to all resource names. KNR = Kundenr i VISMA
EX: 10000 = ECIT
''')
@maxLength(5)
param parCompanyPrefix string

@sys.description('Resource Group Name for Logging')
param parLoggingResourceGroupName string = toLower('RG-${parCompanyPrefix}-ECMS-${parRegion}-logging')

module modResourceGroup '../../custom-modules/resourceGroup/resourceGroup.bicep' = {
  scope: subscription(parPlatManagementSubcriptionId)
  name: 'logResourceGroup'
  params: {
   parLandingZoneEnv: 'Management'
   parLocation: parLocation
   parResourceGroupName: parLoggingResourceGroupName
  }
}

module modLogging '../../custom-modules/logging/logging.bicep' = {
  scope: resourceGroup(parPlatManagementSubcriptionId, parLoggingResourceGroupName)
  name: 'AZL-Logging'
  params: {
    parLandingZoneEnv: 'Management'
  }
  dependsOn: [
    modResourceGroup
  ]
}
