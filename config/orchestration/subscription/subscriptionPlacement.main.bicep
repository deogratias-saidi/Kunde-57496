targetScope = 'managementGroup'

param parCompanyPrefix string

// Management Group Names to place subscriptions in.

@sys.description('Name of the Platform Management Management Group')
param parPlatManagementMgmtGroupName string = 'alz-${parCompanyPrefix}-platform-management'

@sys.description('Name of the Platform Connectivity Management Group')
param parPlatConnectivityMgmtGroupName string = 'alz-${parCompanyPrefix}-platform-connectivity'

@sys.description('Name of the Landing Zone Corp Management Group')
param parLandingZoneCorpMgmtGroupName string = 'alz-${parCompanyPrefix}-landingzones-corp'

@sys.description('Name of the Landing Zone Online Management Group')
param parLandingZoneOnlineMgmtGroupName string = 'alz-${parCompanyPrefix}-landingzones-online'

// Subscription IDs for Management Groups

@sys.description('Subscription ID for the Platform Management Management Group')
param parPlatManagementSubcriptionId string

@sys.description('Subscription ID for the Platform Connectivity Management Group')
param parPlatConnectivitySubcriptionId string

@sys.description('Subscription ID for the Landing Zone Corp Management Group')
param parLandingZoneCorpSubcriptionId string

@sys.description('Subscription ID for the Landing Zone Online Management Group')
param parLandingZoneOnlineSubcriptionId string

@sys.description('Flag to whether deploy subscriptions to Management Groups')
param parDeploySubscriptions bool

// Modules to place subscriptions in Management Groups

module modSubctionPlacement '../../custom-modules/subscriptionPlacement/subscription.bicep' = if (parDeploySubscriptions) {
  name: 'subscriptionPlacement'
  params: {
    parLandingZoneCorpMgmtGroupName: parLandingZoneCorpMgmtGroupName
    parLandingZoneCorpSubcriptionId: parLandingZoneCorpSubcriptionId

    parPlatConnectivityMgmtGroupName: parPlatConnectivityMgmtGroupName
    parPlatConnectivitySubcriptionId: parPlatConnectivitySubcriptionId

    parPlatManagementMgmtGroupName: parPlatManagementMgmtGroupName
    parPlatManagementSubcriptionId: parPlatManagementSubcriptionId

    parLandingZoneOnlineMgmtGroupName: parLandingZoneOnlineMgmtGroupName
    parLandingZoneOnlineSubcriptionId: parLandingZoneOnlineSubcriptionId
  }
}
