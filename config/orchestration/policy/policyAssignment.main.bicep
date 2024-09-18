targetScope = 'managementGroup'

param deploymentLocaton string = deployment().location
param parLogAnalyticsWorkspaceSubscription string
param parLogAnalyticsWorkspaceResourceGroupName string = 'rg-${parCompanyPrefix}-ecms-noe-logging'
param parCompanyPrefix string
param parMsDefenderForCloudEmailSecurityContact string

module modLogging '../../custom-modules/logging/logging.bicep' = {
  scope: resourceGroup(parLogAnalyticsWorkspaceSubscription, parLogAnalyticsWorkspaceResourceGroupName )
  name: 'login'
  params: {
    parLandingZoneEnv: 'Management'
    parLocation: deploymentLocaton
    parLogAnalyticsWorkspaceLocation: deploymentLocaton
    parUserAssignedManagedIdentityLocation: deploymentLocaton
    parAutomationAccountLocation: deploymentLocaton
  }
}

module modPolicy '../../custom-modules/policy/assignments/alzDefaults/defaultPolicyAssignments.bicep' = {
  name: 'deploy-policy'
  params:{
    parCompanyPrefix:parCompanyPrefix
    parAutomationAccountName:modLogging.outputs.outAutomationAccountName
    parDataCollectionRuleChangeTrackingResourceId:modLogging.outputs.outDataCollectionRuleChangeTrackingId
    parDataCollectionRuleMDFCSQLResourceId:modLogging.outputs.outDataCollectionRuleMDFCSQLId
    parDataCollectionRuleVMInsightsResourceId:modLogging.outputs.outDataCollectionRuleVMInsightsId
    parLogAnalyticsWorkSpaceAndAutomationAccountLocation:modLogging.outputs.outAutomationAccountLocation
    parLogAnalyticsWorkspaceName:modLogging.outputs.outLogAnalyticsWorkspaceName
    parLogAnalyticsWorkspaceResourceGroupName:parLogAnalyticsWorkspaceResourceGroupName
    parLogAnalyticsWorkspaceResourceId:modLogging.outputs.outLogAnalyticsWorkspaceId
    parLogAnalyticsWorkspaceSubscription:parLogAnalyticsWorkspaceSubscription
    parMsDefenderForCloudEmailSecurityContact:parMsDefenderForCloudEmailSecurityContact
    parUserAssignedManagedIdentityResourceId: modLogging.outputs.outUserAssignedManagedIdentityId
    parUserAssignedManagedIdentityResourceName:modLogging.outputs.outUserAssignedManagedIdentityName
  }
  dependsOn:[ 
    modLogging
  ]
}
