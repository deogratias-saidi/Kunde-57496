targetScope = 'managementGroup'

param parPlatManagementMgmtGroupName string
param parPlatManagementSubcriptionId string

/* param parPlatIdentityMgmtGroupName string
param parPlatIdentityMgmtGroupSubId string
param parIfPlatIdentityEnabled bool */

param parPlatConnectivityMgmtGroupName string
param parPlatConnectivitySubcriptionId string

param parLandingZoneCorpMgmtGroupName string
param parLandingZoneCorpSubcriptionId string

param parLandingZoneOnlineMgmtGroupName string
param parLandingZoneOnlineSubcriptionId string

/*
param parDecommissionedMgmtGroupName string
param parDecommissionedMgmtGroupSubId string
param parIfDecommissionedEnabled bool

param parSandboxMgmtGroupName string
param parSandboxMgmtGroupSubId string
param parIfSandboxesEnabled bool */

resource resPlatMgmtGroupSub 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = {
  scope: tenant()
  name: '${parPlatManagementMgmtGroupName}/${parPlatManagementSubcriptionId}'
}

/* resource resPlatIdentityMgmtGroupSub 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = if (parIfPlatIdentityEnabled) {
  scope: tenant()
  name: '${parPlatIdentityMgmtGroupName}/${parPlatIdentitySubcriptionId}'
} */

resource resPlatConnectivityMgmtGroupSub 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = {
  scope: tenant()
  name: '${parPlatConnectivityMgmtGroupName}/${parPlatConnectivitySubcriptionId}'
}

resource resLandingZoneCorpMgmtGroupSub 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = {
  scope: tenant()
  name: '${parLandingZoneCorpMgmtGroupName}/${parLandingZoneCorpSubcriptionId}'
}

resource resLandingZoneOnlineMgmtGroupSub 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' =  {
  scope: tenant()
  name: '${parLandingZoneOnlineMgmtGroupName}/${parLandingZoneOnlineSubcriptionId}'
}

/*
resource resDecommissionedMgmtGroupSub 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = if (parIfDecommissionedEnabled) {
  scope: tenant()
  name: '${parDecommissionedMgmtGroupName}/${parDecommissionedSubcriptionId}'
}

resource resSandboxMgmtGroupSub 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = if (parIfSandboxesEnabled) {
  scope: tenant()
  name: '${parSandboxMgmtGroupName}/${parSandboxSubcriptionId}'
} */

