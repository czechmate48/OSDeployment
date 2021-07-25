Function Set-WifiProfile {

<#
.SYNOPSIS
This cmdlet creates a new wifi profile by setting the ssid and password
.DESCRIPTION
Use this cmdlet to create a new wifi profile on the device. This cmdlet only works if the profile DOES NOT already exist. 
Output may be logged to a specified file using the $log parameter. 
.PARAMETER $ssid
The name of the wifi network
.PARAMETER $password
The password for the wifi network, as a secure string
.PARAMETER $log
The path to the log file
.EXAMPLE
Set-HOPWifi -ssid PublicNetwork -password (Convertto-SecureString 'P@sswo3d') -log C:\users\admin\wifi.txt
.NOTES
Please note that the command will fail if there is already a wifi profile for the specified SSID
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String] $ssid,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [SecureString] $password,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $log
    )

    BEGIN{
        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            $log = (New-ScratchLog).path
        }
    }

    PROCESS {

        $tsmessage = New-TimeStampMessage -Message 'Ensuring Wifiprofilemanagement module is installed' -type Informational
        Write-Verbose $tsmessage.alert
        $tsmessage.alert | Out-File -FilePath $log -Append

        if (((Get-Module -ListAvailable).Name -contains 'wifiprofilemanagement') -eq $false){

            # LOG MESSAGE - WARNING
            $tsmessage = New-TimeStampMessage -Message 'Wifiprofilemanagement is not installed. Attempting to download and import the module.' -type Warning
            Write-Warning $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Try {
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop # Ensures the NuGet provider won't prompt for user input
                Install-Module wifiprofilemanagement -Force -ErrorAction Stop
                Import-Module wifiprofilemanagement -ErrorAction Stop

                # LOG MESSAGE - SUCCESS
                $tsmessage = New-TimeStampMessage -Message 'Wifiprofilemanagement successfully downloaded and imported' -type Success
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append

            } Catch {
                # LOG MESSAGE - ERROR
                $tsmessage = New-TimeStampMessage -Message "Unable to download and import Wifiprofilemanagement. Unable to set default Wifi profile to $ssid" -type Error
                Write-Warning $tsmessage.alert 
                $tsmessage.alert | Out-File -FilePath $log -Append
            } # Try-Catch

        } else {
            $tsmessage = New-TimeStampMessage -Message 'Wifiprofilemanagement module is already installed.' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }

        Try {
            # LOG MESSAGE - INFORMATIONAL
            $tsmessage = New-TimeStampMessage -Message "Attempting to set default wifi profile to $ssid" -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            New-WiFiProfile -ProfileName $ssid -ConnectionMode auto -Authentication WPA2PSK -Password $password -Encryption AES -Erroraction Stop

            # LOG MESSAGE - SUCCESS
            $tsmessage = New-TimeStampMessage -Message "Default Wifi successfully set to $ssid" -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

        } Catch {
            # LOG MESSAGE - ERROR
            $tsmessage = New-TimeStampMessage -Message "Unable to set default Wifi profile to $ssid. You may have entered the ssid or password incorrectly or there may already be a profile set up for this ssid" -type Error
            Write-Warning $tsmessage.alert 
            $tsmessage.alert | Out-File -FilePath $log -Append
        } #Try-Catch

    } # Process

    END {

        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            Remove-ScratchLog
        }

    } # End

}

