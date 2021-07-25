Function Approve-SecureBoot {

<#
.SYNOPSIS
Used to verify whether or not Secure Boot is enabled on the host system. 
.DESCRIPTION
This cmdlet wraps the Confirm-SecureBootUEFI cmdlet into a new cmdlet in order to add logging capabilities. This cmdlet is intended for
use in deployment scripts to verify that Secure Boot has been enabled on the system. 
.PARAMETER $log
The path to the log file
.EXAMPLE
Approve-Secureboot -log C:\users\administrator\documents\log.txt
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

        $tsmessage = New-TimeStampMessage -Message "Verifying secure boot is enabled" -type Informational
        Write-Verbose $tsmessage.alert
        $tsmessage.alert | Out-File -FilePath $log -Append

        if (Confirm-SecureBootUEFI){
            $tsmessage = New-TimeStampMessage -Message "Verification Passed: Secure boot is enabled" -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        } else {
            $tsmessage = New-TimeStampMessage -Message "Verification Failed: Secure boot is disabled" -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }
    }

    END {

        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            Remove-ScratchLog
        }

    } # End

}