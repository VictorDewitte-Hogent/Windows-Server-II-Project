# Script Voor de configuratie van de SQL server

#Vars
param($Step="A")

$dnsServers = @("192.168.22.5","192.168.22.9")

[ipaddress]$ip = "192.168.22.3"
[ipaddress]$defaultGateway = "192.168.22.1"
[int]$prefix = 24
[string]$interfaceName = "Ethernet"

[string]$domain = "WS2-2223-Victor.hogent"

Mount-DiskImage -ImagePath "C:\Exchange\mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
$Drive = Get-Volume -FileSystemLabel "exchange*" 
$DriveLetter = $Drive.DriveLetter
Set-Location  -Path "$($DriveLetter):\"



.\setup.exe /qs /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="NT SERVICE\MSSQLSERVER" /SQLSVCPASSWORD=$SQLSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /SUPPRESSPRIVACYSTATEMENTNOTICE