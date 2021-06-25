﻿configuration CONFIGVPN
{
   param
   (
        [String]$TimeZone,
        [String]$RemoteGatewayIP,
        [String]$LocalAddressPrefix,
        [String]$SharedKey                                 
    )

    Import-DscResource -Module ComputerManagementDsc # Used for TimeZone

    Node localhost
    {
        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone         = $TimeZone
        }

        Script ConfigureRRAS
        {
            SetScript =
            {
                # Configure RRAS
                $RemoteAccess = Get-RemoteAccess
                $InstallStatus = $RemoteAccess.VpnS2SStatus
                $AddressPrefix = "$using:LocalAddressPrefix"+':100'

                IF ($InstallStatus -like "Uninstalled"){
                Install-RemoteAccess -VpnType VpnS2S
                Add-Content -Path C:\VPNInstall.txt -Value 'Installed VpnS2S'
                Add-VpnS2SInterface -Protocol IKEv2 -AuthenticationMethod PSKOnly -NumberOfTries 3 -ResponderAuthenticationMethod PSKOnly -Name Azure -Destination "$using:RemoteGatewayIP" -IPv4Subnet "$AddressPrefix" -SharedSecret "$using:SharedKey"
                Add-Content -Path C:\VPNInstall.txt -Value 'Added VPNS2SInterface'
                Set-VpnServerIPsecConfiguration -EncryptionType MaximumEncryption
                Add-Content -Path C:\VPNInstall.txt -Value 'Set Encryption'
                Set-VpnS2Sinterface -Name Azure -InitiateConfigPayload $false -Force
                Add-Content -Path C:\VPNInstall.txt -Value 'Set VPNS2SInterface'
                Connect-VpnS2SInterface -Name Azure
                Add-Content -Path C:\VPNInstall.txt -Value 'Connected to Azure'
                }
            }
            GetScript =  { @{} }
            TestScript = { $false}
        }
    }
}