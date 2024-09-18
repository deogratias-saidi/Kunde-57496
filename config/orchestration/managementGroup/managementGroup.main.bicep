targetScope = 'tenant'

param parCompanyPrefix string
param parTopLevelManagementGroupPrefix string = 'alz'
param parTopLevelManagementGroupDisplayName string = 'alz-${parCompanyPrefix}'
param parPlatformMgmtAlzDefaultsEnable bool = true
param parLandingZoneMgAlzDefaultsEnable bool = true
param parSandboxMgDefaultsEnable bool = true
param parDecommissionedMgDefautsEnable bool = true
param parLandingZoneMgConfidentialEnable bool = false


module modManagementGroup '../../custom-modules/managementGroup/managementGroup.bicep' = {
  name: 'CreatemanagementGroup'
  params: {
    parTopLevelManagementGroupPrefix: parTopLevelManagementGroupPrefix
    parTopLevelManagementGroupDisplayName: parTopLevelManagementGroupDisplayName
    parPlatformMgmtAlzDefaultsEnable: parPlatformMgmtAlzDefaultsEnable
    parLandingZoneMgAlzDefaultsEnable: parLandingZoneMgAlzDefaultsEnable
    parSandboxMgDefaultsEnable: parSandboxMgDefaultsEnable
    parDecommissionedMgDefautsEnable: parDecommissionedMgDefautsEnable
    parLandingZoneMgConfidentialEnable: parLandingZoneMgConfidentialEnable
    parCompanyPrefix:parCompanyPrefix
  }
}
