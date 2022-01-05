function Enable-AuxiliarySignIn{

    [CmdletBinding()]
    param ()

    Set-Location -path 
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\" -Name 'AllowDomainPINLogon' -PropertyType 
    New-Item
}