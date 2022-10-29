Write-Host @"
#######################################
##              PART 1/4             ##
##      Changing hostname            ##
##      Install AD-Domain-Services   ##
##      Install DNS Server           ##
##      Install DHCP Server          ##
##      Install CA Server            ##
##      Install Router role          ##
#######################################
"@
Start-Sleep 3

# Hostname AD is agentsmith
Rename-Computer -NewName "DC"
# Verander IP-adres
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.22.3 
Set-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.22.3 -PrefixLength 24
# DNS Servers instellen
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses ("192.168.22.1","")
# IPv6 uitschakelen
Disable-NetAdapterBinding -InterfaceAlias “Ethernet” -ComponentID ms_tcpip6
# Execution Policy wijzigen
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
# Installeer AD-Domain-Services
Add-WindowsFeature AD-Domain-Services -IncludeManagementTools
# Installeer DNS Server
Add-WindowsFeature DNS -IncludeManagementTools
# Installeer DHCP Server
Install-WindowsFeature -ConfigurationFilePath "Windows-Server-II-Project\Scripts\DC\DHCP.xml"
# Installeer CA Server
Install-WindowsFeature -ConfigurationFilePath "Windows-Server-II-Project\Scripts\DC\CA.xml"
# Installeer Router role
Install-WindowsFeature -ConfigurationFilePath "Windows-Server-II-Project\Scripts\DC\RouterConfig.xml"


# Tijd aanpassen
tzutil /s "Romance Standard Time"


##############################
#          REBOOT            #
##############################
shutdown /r -t 0