metadata name = 'ALZ Bicep - Public IP creation module'
metadata description = 'Module used to set up Public IP for Azure Landing Zones'


@sys.description('Azure Region to deploy Public IP Address to.')
param parLocation string = resourceGroup().location

@sys.description('Name of Public IP to create in Azure.')
param parPublicIpName string

@sys.description('Public IP Address SKU.')
param parPublicIpSku object 

@sys.description('Properties of Public IP to be deployed.')
param parPublicIpProperties object = {
  publicIPAllocationMethod: 'Static'
}

@allowed([
  '1'
  '2'
  '3'
])
@sys.description('Availability Zones to deploy the Public IP across. Region must support Availability Zones to use. If it does not then leave empty.')
param parAvailabilityZones array = ['1']

@description('''
The location abbreviation for the region
- Norway East: NOE
- North Europe: NEU
- West Europe: WEU
''')
param parRegion string = parLocation == 'norwayeast'
  ? 'NOE'
  : parLocation == 'westeurope' ? 'WEU' : parLocation == 'northeurope' ? 'NEU' : 'NOE'

param parResposibleProvider string = 'ECIT'

@description('''
Landing Zone Environment, the environment that the resource is deployed in, the options are:
- Platform
- Corp
- Online
- Management
- Connectivity
''')
@allowed([
  'Platform'
  'Corp'
  'Online'
  'Management'
  'Connectivity'
])
param parLandingZoneEnv string

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {
  Region: parRegion
  ResponsibleProvider: parResposibleProvider
  LZ: parLandingZoneEnv
}

resource resPublicIp 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: parPublicIpName
  tags: parTags
  location: parLocation
  zones: parAvailabilityZones
  sku: parPublicIpSku
  properties: parPublicIpProperties
  
}


output outPublicIpId string = resPublicIp.id
output outPublicIpName string = resPublicIp.name


