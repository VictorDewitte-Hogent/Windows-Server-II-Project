Write-Host @"
#######################################
##              PART 2/4             ##
##             ADDS Setup            ##
#######################################
"@
Start-Sleep 3

# ADS Setup
Import-Module ADDSDeployment

Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "WS2-2223-victor.hogent" `
-DomainNetbiosName "WS2-2223-VICTOR" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-SafeModeAdministratorPassword (ConvertTo-SecureString "Admin123" -AsPlainText -Force) `
-Force:$true

# DNS Setup
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters -Name BindSecondaries -Value 1 -PropertyType DWORD -Force

##############################
#          REBOOT            #
##############################
shutdown /r -t 0