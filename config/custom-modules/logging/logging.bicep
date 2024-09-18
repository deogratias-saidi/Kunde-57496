/*************************************************************
THIS SHOULD BE IN ALL MODULES FOR THE AZURE RESOURCE
**************************************************************/
@description('''
Azure Region to deploy the resources into:
If nothing else is specified or agreed by the customer, the default deployment region will be Norway East.
- West Europe: westeurope
- North Europe: northeurope
- East Norway: norwayeast
''')
param parLocation string = resourceGroup().location

@description('''
The location abbreviation for the region
- Norway East: NOE
- North Europe: NEU
- West Europe: WEU
''')
param parRegion string = parLocation == 'norwayeast' ? 'NOE' : parLocation == 'westeurope' ? 'WEU' : parLocation == 'northeurope' ? 'NEU' : 'NOE'

param parResposibleProvider string = 'ECIT'

@description('''
Landing Zone Environment, the environment that the resource is deployed in, the options are:
- Platform
- Corp
- Online
- Management
''')
@allowed([
  'Platform'
  'Corp'
  'Online'
  'Management'
  'Connectivity'
])
param parLandingZoneEnv string

@description('''
Tags for the resource
''')
param parTags object = {
  Region: parRegion
  ResponsibleProvider: parResposibleProvider
  LZ: parLandingZoneEnv
}

/*************************************************************
      THIS SHOULD BE IN ALL MODULES FOR THE AZURE RESOURCE
**************************************************************/

metadata name = 'ALZ Bicep - Logging Module'
metadata description = 'ALZ Bicep Module used to set up Logging'

@sys.description('Log Analytics Workspace name.')
param parLogAnalyticsWorkspaceName string = 'alz-log-analytics'

@sys.description('Log Analytics region name - Ensure the regions selected is a supported mapping as per: https://docs.microsoft.com/azure/automation/how-to/region-mappings.')
param parLogAnalyticsWorkspaceLocation string = resourceGroup().location

@sys.description('VM Insights Data Collection Rule name for AMA integration.')
param parDataCollectionRuleVMInsightsName string = 'alz-ama-vmi-dcr'



@sys.description('Change Tracking Data Collection Rule name for AMA integration.')
param parDataCollectionRuleChangeTrackingName string = 'alz-ama-ct-dcr'


@sys.description('MDFC for SQL Data Collection Rule name for AMA integration.')
param parDataCollectionRuleMDFCSQLName string = 'alz-ama-mdfcsql-dcr'



@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
@sys.description('Log Analytics Workspace sku name.')
param parLogAnalyticsWorkspaceSkuName string = 'PerGB2018'

@allowed([
  100
  200
  300
  400
  500
  1000
  2000
  5000
])
@sys.description('Log Analytics Workspace Capacity Reservation Level. Only used if parLogAnalyticsWorkspaceSkuName is set to CapacityReservation.')
param parLogAnalyticsWorkspaceCapacityReservationLevel int = 100

@minValue(30)
@maxValue(730)
@sys.description('Number of days of log retention for Log Analytics Workspace.')
param parLogAnalyticsWorkspaceLogRetentionInDays int = 90

@allowed([
  'SecurityInsights'
])
@sys.description('Solutions that will be added to the Log Analytics Workspace.')
param parLogAnalyticsWorkspaceSolutions array = [
  'SecurityInsights'
]

@sys.description('Name of the User Assigned Managed Identity required for authenticating Azure Monitoring Agent to Azure.')
param parUserAssignedManagedIdentityName string = 'alz-logging-mi'

@sys.description('User Assigned Managed Identity location.')
param parUserAssignedManagedIdentityLocation string = resourceGroup().location

@sys.description('Log Analytics Workspace should be linked with the automation account.')
param parLogAnalyticsWorkspaceLinkAutomationAccount bool = true

@sys.description('Automation account name.')
param parAutomationAccountName string = 'alz-automation-account'
@sys.description('Automation Account region name. - Ensure the regions selected is a supported mapping as per: https://docs.microsoft.com/azure/automation/how-to/region-mappings.')
param parAutomationAccountLocation string = resourceGroup().location

@sys.description('Automation Account - use managed identity.')
param parAutomationAccountUseManagedIdentity bool = true

@sys.description('Automation Account - Public network access.')
param parAutomationAccountPublicNetworkAccess bool = true


@sys.description('Tags you would like to be applied to Automation Account.')
param parAutomationAccountTags object = parTags

@sys.description('Tags you would like to be applied to Log Analytics Workspace.')
param parLogAnalyticsWorkspaceTags object = parTags

@sys.description('Set Parameter to true to use Sentinel Classic Pricing Tiers, following changes introduced in July 2023 as documented here: https://learn.microsoft.com/azure/sentinel/enroll-simplified-pricing-tier.')
param parUseSentinelClassicPricingTiers bool = false

@sys.description('Log Analytics LinkedService name for Automation Account.')
param parLogAnalyticsLinkedServiceAutomationAccountName string = 'Automation'


resource resUserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: parUserAssignedManagedIdentityName
  location: parUserAssignedManagedIdentityLocation
}

resource resAutomationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: parAutomationAccountName
  location: parAutomationAccountLocation
  tags: parAutomationAccountTags
  identity: parAutomationAccountUseManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    encryption: {
      keySource: 'Microsoft.Automation'
    }
    publicNetworkAccess: parAutomationAccountPublicNetworkAccess
    sku: {
      name: 'Basic'
    }
  }
}


resource resLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: parLogAnalyticsWorkspaceName
  location: parLogAnalyticsWorkspaceLocation
  tags: parLogAnalyticsWorkspaceTags
  properties: {
    sku: {
      name: parLogAnalyticsWorkspaceSkuName
      capacityReservationLevel: parLogAnalyticsWorkspaceSkuName == 'CapacityReservation' ? parLogAnalyticsWorkspaceCapacityReservationLevel : null
    }
    retentionInDays: parLogAnalyticsWorkspaceLogRetentionInDays
  }
}

resource resDataCollectionRuleVMInsights 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: parDataCollectionRuleVMInsightsName
  location: parLogAnalyticsWorkspaceLocation
  properties: {
    description: 'Data collection rule for VM Insights'
    dataSources: {
      performanceCounters: [
       {
         name: 'VMInsightsPerfCounters'
         streams: [
          'Microsoft-InsightsMetrics'
         ]
         counterSpecifiers: [
          '\\VMInsights\\DetailedMetrics'
         ]
         samplingFrequencyInSeconds: 60
       }
      ]
      extensions: [
        {
          streams: [
            'Microsoft-ServiceMap'
          ]
          extensionName: 'DependencyAgent'
          extensionSettings: {}
          name: 'DependencyAgentDataSource'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: resLogAnalyticsWorkspace.id
          name: 'VMInsightsPerf-Logs-Dest'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-InsightsMetrics'
        ]
        destinations: [
          'VMInsightsPerf-Logs-Dest'
        ]
      }
      {
        streams: [
          'Microsoft-ServiceMap'
        ]
        destinations: [
          'VMInsightsPerf-Logs-Dest'
        ]
      }
    ]
  }
}



resource resDataCollectionRuleChangeTracking 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: parDataCollectionRuleChangeTrackingName
  location: parLogAnalyticsWorkspaceLocation
  properties: {
    description: 'Data collection rule for CT.'
    dataSources: {
      extensions: [
        {
          streams: [
            'Microsoft-ConfigurationChange'
            'Microsoft-ConfigurationChangeV2'
            'Microsoft-ConfigurationData'
          ]
          extensionName: 'ChangeTracking-Windows'
          extensionSettings: {
            enableFiles: true
            enableSoftware: true
            enableRegistry: true
            enableServices: true
            enableInventory: true
            registrySettings: {
              registryCollectionFrequency: 3000
              registryInfo: [
                {
                  name: 'Registry_1'
                  groupTag: 'Recommended'
                  enabled: false
                  recurse: true
                  description: ''
                  keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Group Policy\\Scripts\\Startup'
                  valueName: ''
                }
                {
                    name: 'Registry_2'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Group Policy\\Scripts\\Shutdown'
                    valueName: ''
                }
                {
                    name: 'Registry_3'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Run'
                    valueName: ''
                }
                {
                    name: 'Registry_4'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Active Setup\\Installed Components'
                    valueName: ''
                }
                {
                    name: 'Registry_5'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Classes\\Directory\\ShellEx\\ContextMenuHandlers'
                    valueName: ''
                }
                {
                    name: 'Registry_6'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Classes\\Directory\\Background\\ShellEx\\ContextMenuHandlers'
                    valueName: ''
                }
                {
                    name: 'Registry_7'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Classes\\Directory\\Shellex\\CopyHookHandlers'
                    valueName: ''
                }
                {
                    name: 'Registry_8'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ShellIconOverlayIdentifiers'
                    valueName: ''
                }
                {
                    name: 'Registry_9'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ShellIconOverlayIdentifiers'
                    valueName: ''
                }
                {
                    name: 'Registry_10'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Browser Helper Objects'
                    valueName: ''
                }
                {
                    name: 'Registry_11'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Browser Helper Objects'
                    valueName: ''
                }
                {
                    name: 'Registry_12'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Internet Explorer\\Extensions'
                    valueName: ''
                }
                {
                    name: 'Registry_13'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Internet Explorer\\Extensions'
                    valueName: ''
                }
                {
                    name: 'Registry_14'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Drivers32'
                    valueName: ''
                }
                {
                    name: 'Registry_15'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Windows NT\\CurrentVersion\\Drivers32'
                    valueName: ''
                }
                {
                    name: 'Registry_16'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\KnownDlls'
                    valueName: ''
                }
                {
                    name: 'Registry_17'
                    groupTag: 'Recommended'
                    enabled: false
                    recurse: true
                    description: ''
                    keyName: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\Notify'
                    valueName: ''
                }
              ]
            }
            fileSettings: {
              fileCollectionFrequency: 2700
            }
            softwareSettings: {
              softwareCollectionFrequency: 1800
            }
            inventorySettings: {
              inventoryCollectionFrequency: 36000
            }
            serviceSettings: {
              serviceCollectionFrequency: 1800
            }
          }
          name: 'CTDataSource-Windows'
        }
        {
          streams: [
            'Microsoft-ConfigurationChange'
            'Microsoft-ConfigurationChangeV2'
            'Microsoft-ConfigurationData'
          ]
          extensionName: 'ChangeTracking-Linux'
          extensionSettings: {
            enableFiles: true
            enableSoftware: true
            enableRegistry: false
            enableServices: true
            enableInventory: true
            fileSettings: {
              fileCollectionFrequency: 900
              fileInfo: [
                {
                  name: 'ChangeTrackingLinuxPath_default'
                  enabled: true
                  destinationPath: '/etc/.*.conf'
                  useSudo: true
                  recurse: true
                  maxContentsReturnable: 5000000
                  pathType: 'File'
                  type: 'File'
                  links: 'Follow'
                  maxOutputSize: 500000
                  groupTag: 'Recommended'
                }
              ]
            }
            softwareSettings: {
              softwareCollectionFrequency: 300
            }
            inventorySettings: {
              inventoryCollectionFrequency: 36000
            }
            serviceSettings: {
              serviceCollectionFrequency: 300
            }
          }
          name: 'CTDataSource-Linux'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: resLogAnalyticsWorkspace.id
          name: 'Microsoft-CT-Dest'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-ConfigurationChange'
          'Microsoft-ConfigurationChangeV2'
          'Microsoft-ConfigurationData'
        ]
        destinations: [
          'Microsoft-CT-Dest'
        ]
      }
    ]
  }
}



resource resDataCollectionRuleMDFCSQL'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: parDataCollectionRuleMDFCSQLName
  location: parLogAnalyticsWorkspaceLocation
  properties: {
    description: 'Data collection rule for Defender for SQL.'
    dataSources: {
      extensions: [
        {
          extensionName: 'MicrosoftDefenderForSQL'
          name: 'MicrosoftDefenderForSQL'
          streams: [
            'Microsoft-DefenderForSqlAlerts'
            'Microsoft-DefenderForSqlLogins'
            'Microsoft-DefenderForSqlTelemetry'
            'Microsoft-DefenderForSqlScanEvents'
            'Microsoft-DefenderForSqlScanResults'
          ]
          extensionSettings: {
            enableCollectionOfSqlQueriesForSecurityResearch: true
          }
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: resLogAnalyticsWorkspace.id
          name: 'Microsoft-DefenderForSQL-Dest'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-DefenderForSqlAlerts'
          'Microsoft-DefenderForSqlLogins'
          'Microsoft-DefenderForSqlTelemetry'
          'Microsoft-DefenderForSqlScanEvents'
          'Microsoft-DefenderForSqlScanResults'
        ]
        destinations: [
          'Microsoft-DefenderForSQL-Dest'
        ]
      }
    ]
  }
}



// Onboard the Log Analytics Workspace to Sentinel if SecurityInsights is in parLogAnalyticsWorkspaceSolutions
resource resSentinelOnboarding 'Microsoft.SecurityInsights/onboardingStates@2024-03-01' = if (contains(parLogAnalyticsWorkspaceSolutions, 'SecurityInsights')) {
  name: 'default'
  scope: resLogAnalyticsWorkspace
  properties: {}
}

resource resLogAnalyticsWorkspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in parLogAnalyticsWorkspaceSolutions: {
  name: '${solution}(${resLogAnalyticsWorkspace.name})'
  location: parLogAnalyticsWorkspaceLocation
  tags: parTags
#disable-next-line BCP037
  properties: solution == 'SecurityInsights' ? {
    workspaceResourceId: resLogAnalyticsWorkspace.id
    sku: parUseSentinelClassicPricingTiers ? null : {
      name: 'Unified'
    }
  } : {
    workspaceResourceId: resLogAnalyticsWorkspace.id
  }
  plan: {
    name: '${solution}(${resLogAnalyticsWorkspace.name})'
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}]



resource resLogAnalyticsLinkedServiceForAutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = if (parLogAnalyticsWorkspaceLinkAutomationAccount) {
  parent: resLogAnalyticsWorkspace
  name: parLogAnalyticsLinkedServiceAutomationAccountName
  properties: {
    resourceId: resAutomationAccount.id
  }
}


output outUserAssignedManagedIdentityId string = resUserAssignedManagedIdentity.id
output outUserAssignedManagedIdentityName string = resUserAssignedManagedIdentity.name
output outUserAssignedManagedIdentityPrincipalId string = resUserAssignedManagedIdentity.properties.principalId

output outDataCollectionRuleVMInsightsName string = resDataCollectionRuleVMInsights.name
output outDataCollectionRuleVMInsightsId string = resDataCollectionRuleVMInsights.id

output outDataCollectionRuleChangeTrackingName string = resDataCollectionRuleChangeTracking.name
output outDataCollectionRuleChangeTrackingId string = resDataCollectionRuleChangeTracking.id

output outDataCollectionRuleMDFCSQLName string = resDataCollectionRuleMDFCSQL.name
output outDataCollectionRuleMDFCSQLId string = resDataCollectionRuleMDFCSQL.id

output outLogAnalyticsWorkspaceName string = resLogAnalyticsWorkspace.name
output outLogAnalyticsWorkspaceId string = resLogAnalyticsWorkspace.id
output outLogAnalyticsCustomerId string = resLogAnalyticsWorkspace.properties.customerId
output outLogAnalyticsSolutions array = parLogAnalyticsWorkspaceSolutions

output outAutomationAccountName string = resAutomationAccount.name
output outAutomationAccountId string = resAutomationAccount.id
output outAutomationAccountLocation string = resAutomationAccount.location

output outDeploymentLocationId string = resLogAnalyticsWorkspace.location

