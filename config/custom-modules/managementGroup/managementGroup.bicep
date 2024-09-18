targetScope = 'tenant'

metadata name = 'ALZ Bicep - Management Groups Module'
metadata description = 'ALZ Bicep Module to set up Management Group structure'

@sys.description('Prefix used for the management group hierarchy. This management group will be created as part of the deployment.')
@minLength(2)
@maxLength(10)
param parTopLevelManagementGroupPrefix string

param parCompanyPrefix string 

@sys.description('Optional suffix for the management group hierarchy. This suffix will be appended to management group names/IDs. Include a preceding dash if required. Example: -suffix')
@maxLength(10)
param parTopLevelManagementGroupSuffix string = ''

@sys.description('Display name for top level management group. This name will be applied to the management group prefix defined in parTopLevelManagementGroupPrefix parameter.')
@minLength(2)
param parTopLevelManagementGroupDisplayName string

@sys.description('Optional parent for Management Group hierarchy, used as intermediate root Management Group parent, if specified. If empty, default, will deploy beneath Tenant Root Management Group.')
param parTopLevelManagementGroupParentId string = ''

@sys.description('Deploys Corp & Online Management Groups beneath Landing Zones Management Group if set to true.')
param parLandingZoneMgAlzDefaultsEnable bool

@sys.description('Deploys Management, Identity and Connectivity Management Groups beneath Platform Management Group if set to true.')
param parPlatformMgmtAlzDefaultsEnable bool

@sys.description('Deploys Confidential Corp & Confidential Online Management Groups beneath Landing Zones Management Group if set to true.')
param parLandingZoneMgConfidentialEnable bool

@sys.description('Deploys Sandbox Management Group if set to true, Sandbox Management Group will be deployed')
param parSandboxMgDefaultsEnable bool

@sys.description('Deploy decommissioned Management Group? If set to true, decommissioned Management Group will be deployed.')
param parDecommissionedMgDefautsEnable bool

@sys.description('Dictionary Object to allow additional or different child Management Groups of Landing Zones Management Group to be deployed.')
param parLandingZoneMgChildren object = {}

@sys.description('Dictionary Object to allow additional or different child Management Groups of Platform Management Group to be deployed.')
param parPlatformMgChildren object = {}

// Platform and Child Management Groups
var varPlatformMg = {
  name: '${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-platform${parTopLevelManagementGroupSuffix}'
  displayName: 'Platform'
}

// Used if parPlatformMgAlzDefaultsEnable == true
var varPlatformMgChildrenAlzDefault = {
  connectivity: {
    displayName: 'Connectivity'
  }
  identity: {
    displayName: 'Identity'
  }
  management: {
    displayName: 'Management'
  }
}

// Landing Zones & Child Management Groups
var varLandingZoneMg = {
  name: '${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-landingzones${parTopLevelManagementGroupSuffix}'
  displayName: 'Landing Zones'
}

// Used if parLandingZoneMgAlzDefaultsEnable == true
var varLandingZoneMgChildrenAlzDefault = {
  corp: {
    displayName: 'Corp'
  }
  online: {
    displayName: 'Online'
  }
}

// Used if parLandingZoneMgConfidentialEnable == true
var varLandingZoneMgChildrenConfidential = {
  'confidential-corp': {
    displayName: 'Confidential Corp'
  }
  'confidential-online': {
    displayName: 'Confidential Online'
  }
}

// Sandbox Management Group
var varSandboxMg = {
  name: '${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-sandbox${parTopLevelManagementGroupSuffix}'
  displayName: 'Sandbox'
}

// Decomissioned Management Group
var varDecommissionedMg = {
  name: '${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-decommissioned${parTopLevelManagementGroupSuffix}'
  displayName: 'Decommissioned'
}

// Build final onject based on input parameters for child MGs of LZs
var varLandingZoneMgChildrenUnioned = (parLandingZoneMgAlzDefaultsEnable && parLandingZoneMgConfidentialEnable && (!empty(parLandingZoneMgChildren)))
  ? union(varLandingZoneMgChildrenAlzDefault, varLandingZoneMgChildrenConfidential, parLandingZoneMgChildren)
  : (parLandingZoneMgAlzDefaultsEnable && parLandingZoneMgConfidentialEnable && (empty(parLandingZoneMgChildren)))
      ? union(varLandingZoneMgChildrenAlzDefault, varLandingZoneMgChildrenConfidential)
      : (parLandingZoneMgAlzDefaultsEnable && !parLandingZoneMgConfidentialEnable && (!empty(parLandingZoneMgChildren)))
          ? union(varLandingZoneMgChildrenAlzDefault, parLandingZoneMgChildren)
          : (parLandingZoneMgAlzDefaultsEnable && !parLandingZoneMgConfidentialEnable && (empty(parLandingZoneMgChildren)))
              ? varLandingZoneMgChildrenAlzDefault
              : (!parLandingZoneMgAlzDefaultsEnable && parLandingZoneMgConfidentialEnable && (!empty(parLandingZoneMgChildren)))
                  ? union(varLandingZoneMgChildrenConfidential, parLandingZoneMgChildren)
                  : (!parLandingZoneMgAlzDefaultsEnable && parLandingZoneMgConfidentialEnable && (empty(parLandingZoneMgChildren)))
                      ? varLandingZoneMgChildrenConfidential
                      : (!parLandingZoneMgAlzDefaultsEnable && !parLandingZoneMgConfidentialEnable && (!empty(parLandingZoneMgChildren)))
                          ? parLandingZoneMgChildren
                          : (!parLandingZoneMgAlzDefaultsEnable && !parLandingZoneMgConfidentialEnable && (empty(parLandingZoneMgChildren)))
                              ? {}
                              : {}
var varPlatformMgChildrenUnioned = (parPlatformMgmtAlzDefaultsEnable && (!empty(parPlatformMgChildren)))
  ? union(varPlatformMgChildrenAlzDefault, parPlatformMgChildren)
  : (parPlatformMgmtAlzDefaultsEnable && (empty(parPlatformMgChildren)))
      ? varPlatformMgChildrenAlzDefault
      : (!parPlatformMgmtAlzDefaultsEnable && (!empty(parPlatformMgChildren)))
          ? parPlatformMgChildren
          : (!parPlatformMgmtAlzDefaultsEnable && (empty(parPlatformMgChildren))) ? {} : {}

// Level 1
resource resTopLevelMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${parTopLevelManagementGroupPrefix}${parTopLevelManagementGroupSuffix}'
  properties: {
    displayName: parTopLevelManagementGroupDisplayName
    details: {
      parent: {
        id: empty(parTopLevelManagementGroupParentId)
          ? '/providers/Microsoft.Management/managementGroups/${tenant().tenantId}'
          : contains(
                toLower(parTopLevelManagementGroupParentId),
                toLower('/providers/Microsoft.Management/managementGroups/')
              )
              ? parTopLevelManagementGroupParentId
              : '/providers/Microsoft.Management/managementGroups/${parTopLevelManagementGroupParentId}'
      }
    }
  }
}

// Level 2
resource resPlatformMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: varPlatformMg.name
  properties: {
    displayName: varPlatformMg.displayName
    details: {
      parent: {
        id: resTopLevelMg.id
      }
    }
  }
}

resource resLandingZonesMg 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: varLandingZoneMg.name
  properties: {
    displayName: varLandingZoneMg.displayName
    details: {
      parent: {
        id: resTopLevelMg.id
      }
    }
  }
}

resource resSandboxMg 'Microsoft.Management/managementGroups@2023-04-01' = if (parSandboxMgDefaultsEnable) {
  name: varSandboxMg.name
  properties: {
    displayName: varSandboxMg.displayName
    details: {
      parent: {
        id: resTopLevelMg.id
      }
    }
  }
}

resource resDecommissionedMg 'Microsoft.Management/managementGroups@2023-04-01' = if (parDecommissionedMgDefautsEnable) {
  name: varDecommissionedMg.name
  properties: {
    displayName: varDecommissionedMg.displayName
    details: {
      parent: {
        id: resTopLevelMg.id
      }
    }
  }
}

// Level 3 - Child Management Groups under Landing Zones MG
resource resLandingZonesChildMgs 'Microsoft.Management/managementGroups@2023-04-01' = [
  for mg in items(varLandingZoneMgChildrenUnioned): if (!empty(varLandingZoneMgChildrenUnioned)) {
    name: '${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-landingzones-${mg.key}${parTopLevelManagementGroupSuffix}'
    properties: {
      displayName: mg.value.displayName
      details: {
        parent: {
          id: resLandingZonesMg.id
        }
      }
    }
  }
]

//Level 3 - Child Management Groups under Platform MG
resource resPlatformChildMgs 'Microsoft.Management/managementGroups@2023-04-01' = [
  for mg in items(varPlatformMgChildrenUnioned): if (!empty(varPlatformMgChildrenUnioned)) {
    name: '${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-platform-${mg.key}${parTopLevelManagementGroupSuffix}'
    properties: {
      displayName: mg.value.displayName
      details: {
        parent: {
          id: resPlatformMg.id
        }
      }
    }
  }
]

// Output Management Group IDs
output outTopLevelManagementGroupId string = resTopLevelMg.id

output outPlatformManagementGroupId string = resPlatformMg.id
output outPlatformChildrenManagementGroupIds array = [
  for mg in items(varPlatformMgChildrenUnioned): '/providers/Microsoft.Management/managementGroups/${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-platform-${mg.key}${parTopLevelManagementGroupSuffix}'
]

output outLandingZonesManagementGroupId string = resLandingZonesMg.id
output outLandingZoneChildrenManagementGroupIds array = [
  for mg in items(varLandingZoneMgChildrenUnioned): '/providers/Microsoft.Management/managementGroups/${parTopLevelManagementGroupPrefix}-${parCompanyPrefix}-landingzones-${mg.key}${parTopLevelManagementGroupSuffix}'
]

output outSandboxManagementGroupId string = resSandboxMg.id

output outDecommissionedManagementGroupId string = resDecommissionedMg.id

// Output Management Group Names
output outTopLevelManagementGroupName string = resTopLevelMg.name

output outPlatformManagementGroupName string = resPlatformMg.name
output outPlatformChildrenManagementGroupNames array = [
  for mg in items(varPlatformMgChildrenUnioned): mg.value.displayName
]

output outLandingZonesManagementGroupName string = resLandingZonesMg.name
output outLandingZoneChildrenManagementGroupNames array = [
  for mg in items(varLandingZoneMgChildrenUnioned): mg.value.displayName
]

output outSandboxManagementGroupName string = resSandboxMg.name

output outDecommissionedManagementGroupName string = resDecommissionedMg.name
