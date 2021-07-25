Function Repair-OperatingSystem {
    <#
    .SYNOPSIS
    This cmdlet repairs the system image
    .DESCRIPTION
    Use this Cmdlet to run two commands 'Repair-WindowsImage -Online -RestoreHealth' and 'Sfc /scannow'. These commands will 
    repair the system image and verify the system files are in working order
    .PARAMETER $log
    The path to the log file
    .EXAMPLE
    Repair-OperatingSystem -Log C:\users\public\documents\log.txt
    .NOTES
    See Repair-WindowsImage, DISM, and SFC
    #>

    [CmdLetBinding()]
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

        Try {
            $tsmessage = New-TimeStampMessage -Message 'Restoring the Operating System image' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Repair-WindowsImage -Online -RestoreHealth -ErrorAction Stop | Out-File Null 

            $tsmessage = New-TimeStampMessage -Message 'Operating System Image successfully restored' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        } Catch {
            $tsmessage = New-TimeStampMessage -Message 'Unable to restore the Operating System Image' -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        }
        
        $tsmessage = New-TimeStampMessage -Message 'Running System File Checker' -type Informational
        Write-Verbose $tsmessage.alert
        $tsmessage.alert | Out-File -FilePath $log -Append

        sfc /scannow | Out-File Null

        $tsmessage = New-TimeStampMessage -Message 'System File Checker Completed' -type Informational
        Write-Verbose $tsmessage.alert
        $tsmessage.alert | Out-File -FilePath $log -Append

    }

    END {

        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            Remove-ScratchLog
        }

    } # End
}