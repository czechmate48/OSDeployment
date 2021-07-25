function Disable-AutoLogin {

<#
.SYNOPSIS
This Cmdlet removes an auto login profile.
.DESCRIPTION
This cmdlet removes an auto login profile.
.PARAMETER $log
The path to the log file
.EXAMPLE
Disable-Autologin -log 'C:\users\jdoe\documents\log.txt'
.NOTES
See Enable-Autologin
#>

    [CmdletBinding()]
    Param (
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
            $tsmessage = New-TimeStampMessage -Message 'Removing auto login profile' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Remove-ItemProperty -Path $regPath -Name "DefaultUserName" -ErrorAction Stop

            $tsmessage = New-TimeStampMessage -Message 'auto login profile successfully removed' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }
        catch{
            $tsmessage = New-TimeStampMessage -Message "Unable to remove autologin profile. If you are sure the profile exists, please navigate to $regPath and delete the DefaultUserName value manually" -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $tsmessage = New-TimeStampMessage -Message 'Exiting auto login removal process' -type Warning
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Exit 
        } # Username Try-Catch

        # Password
        try{
            $tsmessage = New-TimeStampMessage -Message 'Removing password for auto login profile in registry' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Remove-ItemProperty -Path $regPath -Name "DefaultPassword" -ErrorAction Stop

            $tsmessage = New-TimeStampMessage -Message 'Auto login password successfully removed' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }
        catch{
            $tsmessage = New-TimeStampMessage -Message "Unable to remove password for auto login profile. If you are sure a password was set, please navigate to $regPath and delete the DefaultUserName value manually" -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $tsmessage = New-TimeStampMessage -Message 'Exiting auto login removal process' -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Exit
        } # Password Try-Catch

        # Auto Login
        try{
            $tsmessage = New-TimeStampMessage -Message 'Removing auto login value in registry' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Remove-ItemProperty -Path $regPath -Name "AutoAdminLogon" -ErrorAction Stop

            $tsmessage = New-TimeStampMessage -Message 'Auto login value successfully removed' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }
        catch{
            $tsmessage = New-TimeStampMessage -Message "Unable to remove auto login value for registry. If you are sure the profile exists, please navigate to $regPath and delete the DefaultUserName value manually" -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

        } # Auto Login Try-Catch

    }

    END {

        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            Remove-ScratchLog
        }

    } # End
}