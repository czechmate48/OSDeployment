Function Remove-ScratchLog {
    <#
    .SYNOPSIS
    This Cmdlet removes a temporary text file used for logging TimeStampMessages
    .DESCRIPTION
    This Cmdlet is primarily intended to reduce unecessary verbosity within other cmdlets that implement the logging feature. By creating a scratch
    log, other cmdlets prevent repetitive verification that the user has defined a path to a log file. The cmdlet is the companion to New-ScratchLog and is
    used to delete the file created by New-ScratchLog
    .PARAMETER $Path
    The location fo the log file
    .EXAMPLE
    Remove-ScratchLog -Path C:\Users\Temp\TemporaryLog.txt
    #>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $Path = 'C:\Windows\Temp\scratch.txt'
    )

    BEGIN {}

    PROCESS {
        
        Try {
            $tsmessage = New-TimeStampMessage -Message "Removing the scratch log text file located at $Path" -type Informational
            Write-Verbose $tsmessage.alert
            Remove-Item -path $Path -ErrorAction Stop
            $tsmessage = New-TimeStampMessage -Message "Scratch Log located at $Path successfully removed" -type Success
            Write-Verbose $tsmessage.alert
            
        } Catch {
            $tsmessage = New-TimeStampMessage -Message "Unable to remove scratch log at $Path. Please ensure the path is accessible and the resource exists" -type Error
            Write-Verbose $tsmessage.alert
        }

    }

    END {}

}