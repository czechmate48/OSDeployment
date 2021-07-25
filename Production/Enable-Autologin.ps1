function Enable-AutoLogin {

<#
.SYNOPSIS
This Cmdlet sets up a profile for autologin after a computer reboot
.DESCRIPTION
This cmdlet sets up a profile for autologin after a computer reboot. You may specify a password if the profile has a password associated
with it, but this is not mandatory. 
.PARAMETER $username
The name of the user profile
.PARAMETER $password
The password of the user profile. Passwords must be submitted as secure strings. 
.PARAMETER $log
The path to the log file
.EXAMPLE
Enable-Autologin -Username jdoe
.NOTES
See Disable-Autologin
#>

    [CmdletBinding()]
    Param (
        [Parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String] $username,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [securestring] $password,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $log
    )

    BEGIN{
        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            $log = (New-ScratchLog).path
        }
    }

    PROCESS {
        $regPath = "HKLM:\SOFTWARE\Microsoft\WINDOWS NT\CurrentVersion\Winlogon"

        # Username
        try{
            $tsmessage = New-TimeStampMessage -Message 'Setting up user auto login profile' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Set-ItemProperty $regPath "DefaultUserName" -Value $username -type String -ErrorAction stop

            $tsmessage = New-TimeStampMessage -Message 'auto login profile setup successfully' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }
        catch{
            $tsmessage = New-TimeStampMessage -Message 'Unable to set up auto login profile in registry' -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $tsmessage = New-TimeStampMessage -Message 'Exiting auto login setup' -type Warning
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Exit 
        } # Username Try-Catch

        # Password
        if ($PSBoundParameters.ContainsKey('password') -eq $true){
            try{
                $tsmessage = New-TimeStampMessage -Message 'Setting password for auto login profile in registry' -type Informational
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append

                $password = ConvertFrom-SecureString $password
                Set-ItemProperty $regPath "DefaultPassword" -Value $password -type String -ErrorAction stop

                $tsmessage = New-TimeStampMessage -Message 'Auto login password set successfully' -type Success
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append
            }
            catch{
                $tsmessage = New-TimeStampMessage -Message 'Unable to set password for auto login profile' -type Error
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append

                $tsmessage = New-TimeStampMessage -Message 'Exiting Auto login setup' -type Error
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append

                Exit
            } # Password Try-Catch
        } # If
    
        # Auto Login
        try{
            $tsmessage = New-TimeStampMessage -Message 'Setting auto login value in registry' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Set-ItemProperty $regPath "AutoAdminLogon" -Value $true -type String -ErrorAction stop

            $tsmessage = New-TimeStampMessage -Message 'Auto login value set successfully' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }
        catch{
            $tsmessage = New-TimeStampMessage -Message 'Unable to set auto login value for registry. Removing autologin profile from registry' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            # Remove auto login from registry
            if ($PSBoundParameters.ContainsKey('password') -eq $true){
                Disable-Autologin -Username $username -Password $password -Log $log
            } else {
                Disable-Autologin -Username $username -Log $log
            }
        } # Auto Login Try-Catch
    }

    END {

        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            Remove-ScratchLog
        }

    } # End

}