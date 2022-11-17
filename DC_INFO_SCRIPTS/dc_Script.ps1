Write-Host @"
#######################################
##              PART 1/4             ##
##         Changing hostname         ##
##    Install AD-Domain-Services     ##
##        Install DNS Server         ##
#######################################
"@
Start-Sleep 3

# Hostname AD is agentsmith
Rename-Computer -NewName "Controller"
# Verander IP-adres naar 10.0.20.1/24
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.22.1 
Set-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.22.1 -PrefixLength 24
# DNS Servers instellen
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses ("127.0.0.1","")
# IPv6 uitschakelen
Disable-NetAdapterBinding -InterfaceAlias “Ethernet” -ComponentID ms_tcpip6
# Execution Policy wijzigen
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
# Installeer AD-Domain-Services
Add-WindowsFeature AD-Domain-Services -IncludeManagementTools
# Installeer DNS Server
Add-WindowsFeature DNS -IncludeManagementTools
# Tijd aanpassen
tzutil /s "Romance Standard Time"


##############################
#          REBOOT            #
##############################
shutdown /r -t 0





#
# Windows PowerShell script for AD DS Deployment
#

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
-Force:$true

