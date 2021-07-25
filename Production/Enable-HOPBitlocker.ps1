Function Enable-HOPBitLocker {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String] $KeyProtectorPath,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $BackupKeyProtectorPath='C:\users\Public\Desktop',
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $log,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $Restart
    )

    BEGIN{
        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            $log = (New-ScratchLog).path
        }
    }

    PROCESS {
        $tsmessage = New-TimeStampMessage -Message 'Configuring bitlocker protection' -type Informational
        Write-Verbose $tsmessage.alert
        $tsmessage.alert | Out-File -FilePath $log -Append

        # Get Operating System volume
        Try {
            $tsmessage = New-TimeStampMessage -Message 'Getting operating system volume' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $bitlockerdrive = Get-BitLockerVolume | Where-Object 'VolumeType' -like *OperatingSystem* -ErrorAction Stop

            $tsmessage = New-TimeStampMessage -Message 'Successfully found operating system volume' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

        } Catch {
            $tsmessage = New-TimeStampMessage -Message 'Unable to find operating system volume' -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $tsmessage = New-TimeStampMessage -Message 'Exiting Bitlocker Setup' -type Warning
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Exit
        }

        # Enable bitlocker on Operating System volume
        Try {
            $tsmessage = New-TimeStampMessage -Message 'Enabling bitlocker protection on operating system volume' -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $volume = Enable-Bitlocker -EncryptionMethod AES256 -MountPoint $bitlockerdrive -RecoveryPasswordProtector -ErrorAction Stop

            $tsmessage = New-TimeStampMessage -Message 'Successfully enabled bitlocker protection on operating system volume' -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        } Catch {
            $tsmessage = New-TimeStampMessage -Message 'Unable to enable bitlocker protection on operating system volume' -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $tsmessage = New-TimeStampMessage -Message 'Exiting Bitlocker Setup' -type Warning
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            Exit
        }

        # Save bitlocker recovery key
        Try {
            $tsmessage = New-TimeStampMessage -Message "Saving bitlocker recovery key to $keyprotectorpath" -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            $volume.KeyProtector[1] | Out-File "$keyprotectorpath\$($volume.KeyProtector[1].KeyProtectorId).txt" -ErrorAction Stop

            $tsmessage = New-TimeStampMessage -Message "Successfully saved recovery key to $keyprotectorpath" -type Success
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
        } Catch {
            $tsmessage = New-TimeStampMessage -Message "Unable to save recovery key to $keyprotectorpath" -type Error
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append

            # Save bitlocker recovery key using backup location
            Try {
                $tsmessage = New-TimeStampMessage -Message "Attemping to save recovery key to backup recovery key path located at $backupkeyprotectorpath" -type Error
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append

                $volume.KeyProtector[1] | Out-File "$backupkeyprotectorpath\$($volume.KeyProtector[1].KeyProtectorId).txt" -ErrorAction Stop

                $tsmessage = New-TimeStampMessage -Message "Successfully saved recovery key to $backupkeyprotectorpath" -type Success
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append
            } Catch {
                $tsmessage = New-TimeStampMessage -Message "Unable to save recovery key to $backupkeyprotectorpath" -type Error
                Write-Verbose $tsmessage.alert
                $tsmessage.alert | Out-File -FilePath $log -Append

                # Disable bitlocker protection due to inability to save recovery key
                Try {
                    $tsmessage = New-TimeStampMessage -Message "Disabling bitlocker protection" -type Informational
                    Write-Verbose $tsmessage.alert
                    $tsmessage.alert | Out-File -FilePath $log -Append

                    Disable-Bitlocker -EncryptionMethod AES256 -MountPoint $bitlockerdrive -RecoveryPasswordProtector -ErrorAction Stop

                    $tsmessage = New-TimeStampMessage -Message "Successfully disabled bitlocker protected. Please enable protection manually" -type Warning
                    Write-Verbose $tsmessage.alert
                    $tsmessage.alert | Out-File -FilePath $log -Append

                    $tsmessage = New-TimeStampMessage -Message 'Exiting Bitlocker Setup' -type Warning
                    Write-Verbose $tsmessage.alert
                    $tsmessage.alert | Out-File -FilePath $log -Append

                    Exit
                } Catch {
                    $tsmessage = New-TimeStampMessage -Message "Unable to disable bitlocker protection. Please obtain the recovery key manually and save it to a safe location" -type Warning
                    Write-Verbose $tsmessage.alert
                    $tsmessage.alert | Out-File -FilePath $log -Append

                    $tsmessage = New-TimeStampMessage -Message 'Exiting Bitlocker Setup' -type Warning
                    Write-Verbose $tsmessage.alert
                    $tsmessage.alert | Out-File -FilePath $log -Append

                    Exit
                } #disable bitlocker protection
            } #save backup bitlocker recovery key
        } #save bitlocker recovery key

        $tsmessage = New-TimeStampMessage -Message "Bitlocker successfully enabled on device" -type Success
        Write-Verbose $tsmessage.alert
        $tsmessage.alert | Out-File -FilePath $log -Append

        if ($restart -eq $true){
            $tsmessage = New-TimeStampMessage -Message "Restarting device" -type Informational
            Write-Verbose $tsmessage.alert
            $tsmessage.alert | Out-File -FilePath $log -Append
            Restart-Computer -Force
        } # if

    } # PROCESS

    END {

        if ($PSBoundParameters.ContainsKey('log') -eq $false){
            Remove-ScratchLog
        }

    } # End
}