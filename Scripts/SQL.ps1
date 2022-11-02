# Script Voor de configuratie van de SQL server

#Vars
param($Step="A")

$dnsServers = @("192.168.22.5","192.168.22.9")

[ipaddress]$ip = "192.168.22.3"
[ipaddress]$defaultGateway = "192.168.22.1"
[int]$prefix = 24
[string]$interfaceName = "Ethernet"

[string]$domain = "WS2-2223-Victor.hogent"


