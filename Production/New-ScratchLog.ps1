Function New-ScratchLog {
    <#
    .SYNOPSIS
    This Cmdlet creates a temporary text file used for logging TimeStampMessages
    .DESCRIPTION
    This Cmdlet is primarily intended to reduce unecessary verbosity within other cmdlets that implement the logging feature. By creating a scratch
    log, other cmdlets prevent repetitive verification that the user has defined a path to a log file. Furthermore, this cmdlet may be used to create
    a custom log file at a location specified by the user. 
    .PARAMETER $Path
    The location fo the log file
    .EXAMPLE
    New-ScratchLog -Path C:\Users\Temp\TemporaryLog.txt
    .NOTES
    See Remove-ScratchLog 
    #>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $Path = 'C:\Windows\Temp\scratch.txt'
    )

    BEGIN {}

    PROCESS {
        
        Try {
            $tsmessage = New-TimeStampMessage -Message "Creating a new scratch log text file located at $Path" -type Informational
            Write-Verbose $tsmessage.alert
            New-Item -Path $Path -ErrorAction Stop | Out-File Null
            $tsmessage = New-TimeStampMessage -Message "Scratch Log successfully created at $Path" -type Success
            Write-Verbose $tsmessage.alert        
            
            [PSCustomObject]@{
                Path=$path
            }
        } Catch {
            $tsmessage = New-TimeStampMessage -Message "Unable to create scratch log at $Path. Please ensure the path is accessible" -type Error
            Write-Verbose $tsmessage.alert
        } # Try-Catch

    } # Process

    END {}

}