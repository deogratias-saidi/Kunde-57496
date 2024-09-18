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


@description('Username for the FortiGate VM')
param adminUsername string

@description('Password for the FortiGate VM')
@secure()
param adminPassword string


@description('Identifies whether to to use PAYG (on demand licensing) or BYOL license model (where license is purchased separately')
param fortiGateImageSKU string = 'fortinet_fg-vm'

@description('Select the image version')
@allowed([
  '6.4.15'
  '7.0.15'
  '7.0.14'
  '7.2.8'
  '7.2.7'
  '7.4.4'
  '7.4.3'
  'latest'
])
param fortiGateImageVersion string = '6.4.15'

@description('The ARM template provides a basic configuration. Additional configuration can be added here.')
param fortiGateAdditionalCustomData string = '''
show system Interface

config system global
set admin-https-redirect disable
set admin-sport 9443
set admintimeout 30
set gui-theme eclipse
set timezone 26
end
config firewall address
edit "ESO_FBU_allowed_addresses"
set subnet 217.144.235.43/32
next
edit "ESO_JUMP01_allowed_addresses"
set subnet 79.135.19.25/32
next
edit "ESO_ASP_allowed_addresses"
set subnet 77.40.251.193/32
next
edit "ESO_Drammen_allowed_addresses"
set subnet 62.101.199.98/32
next
end
config firewall addrgrp
edit "MGMT_IPs"
set member "ESO_FBU_allowed_addresses" "ESO_JUMP01_allowed_addresses" "ESO_ASP_allowed_addresses" "ESO_Drammen_allowed_addresses"
next
end
config firewall service custom
edit ADM_GUI_HTTPS
set tcp-portrange 9443
end
config firewall local-in-policy
edit 1
set intf port1
set srcaddr "MGMT_IPs"
set dstaddr "all"
set action accept
set service ADM_GUI_HTTPS SSH PING
set schedule "always"
set status enable
next
edit 2
set intf "any"
set srcaddr "all"
set dstaddr "all"
set action deny
set service ADM_GUI_HTTPS SSH PING
set schedule "always"
set status enable
end
'''

@description('Virtual Machine size selection - must be F4 or other instance that supports 4 NICs')
param instanceType string = 'Standard_DS2_v2'


@description('Virtual Network Address prefix')
param vnetAddressPrefix array


@description('External Subnet Prefix')
param externalSubnetPrefix string 

@description('External Subnet start address, 1 consecutive private IPs are required')
param externalStartAddress string 

@description('Internal Subnet Prefix')
param internalSubnetPrefix string

@description('Internal Subnet, 1 consecutive private IPs are required')
param internalStartAddress string


@description('Enable Serial Console')
@allowed([
  'yes'
  'no'
])
param serialConsole string = 'yes'

@description('Connect to FortiManager')
@allowed([
  'yes'
  'no'
])
param fortiManager string = 'no'

@description('FortiManager IP or DNS name to connect to on port TCP/541')
param fortiManagerIP string = ''

@description('FortiManager serial number to add the deployed FortiGate into the FortiManager')
param fortiManagerSerial string = ''

@description('FortiGate BYOL license content')
param fortiGateLicenseBYOL string = ''

@description('FortiGate BYOL FortiFlex license token')
param fortiGateLicenseFortiFlex string = ''

@description('By default, the deployment will use Azure Marketplace images. In specific cases, using BYOL custom FortiGate images can be deployed. This requires a reference ')
param customImageReference string = ''


param externalNicId string
param internalNicId string

var imagePublisher = 'fortinet'
var imageOffer = 'fortinet_fortigate-vm_v5'

// set the resource names based on the input parameters
param parFortigateName string

// Custom data for FortiGate VM
var fmgCustomData = ((fortiManager == 'yes')
  ? '\nconfig system central-management\nset type fortimanager\n set fmg ${fortiManagerIP}\nset serial-number ${fortiManagerSerial}\nend\n config system interface\n edit port1\n append allowaccess fgfm\n end\n config system interface\n edit port2\n append allowaccess fgfm\n end\n'
  : '')
var customDataHeader = 'Content-Type: multipart/mixed; boundary="12345"\nMIME-Version: 1.0\n\n--12345\nContent-Type: text/plain; charset="us-ascii"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename="config"\n\n'
var customDataBody = 'config system global\nset hostname ${parFortigateName}\nend\nconfig system sdn-connector\nedit AzureSDN\nset type azure\nnext\nend\nconfig router static\nedit 1\nset gateway ${sn1GatewayIP}\nset device port1\nnext\nedit 2\nset dst ${vnetAddressPrefix}\nset gateway ${sn2GatewayIP}\nset device port2\nnext\nend\nconfig system interface\nedit port1\nset mode static\nset ip ${sn1IPfgt}/${sn1CIDRmask}\nset description external\nset allowaccess ping ssh https\nnext\nedit port2\nset mode static\nset ip ${sn2IPfgt}/${sn2CIDRmask}\nset description internal\nset allowaccess ping ssh https\nnext\nend\n${fmgCustomData}${fortiGateAdditionalCustomData}\n'
var customDataLicenseHeader = '--12345\nContent-Type: text/plain; charset="us-ascii"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename="license"\n\n'
var customDataFooter = '\n--12345--\n'
var customDataFortiFlex = ((fortiGateLicenseFortiFlex == '') ? '' : 'LICENSE-TOKEN:${fortiGateLicenseFortiFlex}\n')
var customDataCombined = '${customDataHeader}${customDataBody}${customDataLicenseHeader}${customDataFortiFlex}${fortiGateLicenseBYOL}${customDataFooter}'
var fgtCustomData = base64((((fortiGateLicenseBYOL == '') && (fortiGateLicenseFortiFlex == ''))
  ? customDataBody
  : customDataCombined))


var serialConsoleEnabled = ((serialConsole == 'yes') ? 'true' : 'false')

// Calculate the gateway IP and the first IP of the FortiGate

var externalIPArray = split(externalSubnetPrefix, '.')
var externalIPArray2ndString = string(externalIPArray[3])
var externalIPArray2nd = split(externalIPArray2ndString, '/')
var sn1CIDRmask = string(int(externalIPArray2nd[1]))
var externalIPArray3 = string((int(externalIPArray2nd[0]) + 1))
var externalIPArray2 = string(int(externalIPArray[2]))
var externalIPArray1 = string(int(externalIPArray[1]))
var externalIPArray0 = string(int(externalIPArray[0]))
var sn1GatewayIP = '${externalIPArray0}.${externalIPArray1}.${externalIPArray2}.${externalIPArray3}'
var sn1IPStartAddress = split(externalStartAddress, '.')
var sn1IPfgt = '${externalIPArray0}.${externalIPArray1}.${externalIPArray2}.${sn1IPStartAddress}'
var internalIPArray = split(internalSubnetPrefix, '.')
var internalIPArray2ndString = string(internalIPArray[3])
var internalIPArray2nd = split(internalIPArray2ndString, '/')
var sn2CIDRmask = string(int(internalIPArray2nd[1]))
var internalIPArray3 = string((int(internalIPArray2nd[0]) + 1))
var internalIPArray2 = string(int(internalIPArray[2]))
var internalIPArray1 = string(int(internalIPArray[1]))
var internalIPArray0 = string(int(internalIPArray[0]))
var sn2GatewayIP = '${internalIPArray0}.${internalIPArray1}.${internalIPArray2}.${internalIPArray3}'
var sn2IPStartAddress = split(internalStartAddress, '.')
var sn2IPfgt = '${internalIPArray0}.${internalIPArray1}.${internalIPArray2}.${sn2IPStartAddress}'

var imageReferenceMarketplace = {
  publisher: imagePublisher
  offer: imageOffer
  sku: fortiGateImageSKU
  version: fortiGateImageVersion
}
var imageReferenceCustomImage = {
  id: customImageReference
}
var virtualMachinePlan = {
  name: fortiGateImageSKU
  publisher: imagePublisher
  product: imageOffer
}


resource resFortigateVirtualAppliance 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: parFortigateName
  tags: parTags
  location: parLocation
  identity: {
    type: 'SystemAssigned'
  }

  plan: (((fortiGateImageSKU == 'fortinet_fg-vm') && (customImageReference != '')) ? null : virtualMachinePlan)
  properties: {
    hardwareProfile: {
      vmSize: instanceType
    }
    osProfile: {
      computerName: parFortigateName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: fgtCustomData
    }
    storageProfile: {
      imageReference: (((fortiGateImageSKU == 'fortinet_fg-vm') && (customImageReference != ''))
        ? imageReferenceCustomImage
        : imageReferenceMarketplace)
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 30
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: externalNicId
        }
        {
          properties: {
            primary: false
          }
          id: internalNicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        #disable-next-line BCP036
        enabled: serialConsoleEnabled
      }
    }
  }
  dependsOn: [
    
  ]
}


output outFortigateName string = resFortigateVirtualAppliance.name
output outFortigateId string = resFortigateVirtualAppliance.id
output outFortigateAdminUsername string = adminUsername
