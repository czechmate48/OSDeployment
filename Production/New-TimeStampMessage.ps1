Function New-TimeStampMessage{

<#
.SYNOPSIS
This cmdlet creates a time stamped message for use when logging a script
.DESCRIPTION
Use this cmdlet to create a timestamped message. Messages can be categorized into 'warnings', 'errors', 'successes', or 'informational'. 
To get use the object in scripting, create the timestamp message using the cmdlet and then call '$timestampmessage.message'.
.PARAMETER $Message
The displayed message
.PARAMETER $Type
The type of message (Warning, Error, Success, Informational)
.EXAMPLE
New-TimeStampMessage -Message 'Unable to open file. Please verify that the file exists and try again' -Type Error
.EXAMPLE
'Initiating enumeration process' | New-TimeStampMessage -Type Informational
.NOTES
This cmdlet is best used for logging automated processes to see where an error may be occurring, or to verify the success of various operations.
It does not provide the error message, so further exploration will be required when encountering errors and warnings. 
#>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]] $Message,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('Warning','Error','Success','Informational')]
        [string] $Type
    )

    BEGIN {}

    PROCESS{
        foreach ($Mess in $Message){
            $timestamp = "[" + [String](Get-Date).Hour + ":" + [String](Get-Date).Minute + ":" + [String](Get-Date).Second + "]"
            $alert = $timestamp + " [$type] " + $message
            $props = @{
                'Timestamp'=$timestamp
                'Message'=$Message
                'Type'=$type
                'Alert'=$alert
            }
            $obj = New-Object -TypeName PSObject -Property $props
            $obj
        }

    }
    
    END {}
}