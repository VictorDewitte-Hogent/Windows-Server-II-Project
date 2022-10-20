Write-Host @"
#######################################
##              PART 3/4             ##
##              DNS Setup            ##
#######################################
"@
Start-Sleep 3

# DNS Setup
Add-DnsServerResourceRecord -ZoneName thematrix.local -ns -name thematrix.local -NameServer ns2.thematrix.local
Add-DnsServerResourceRecord -ZoneName _msdcs.thematrix.local -ns -name _msdcs.thematrix.local -NameServer ns2.thematrix.local
Set-DnsServerPrimaryZone -Name "thematrix.local" -Notify "Notify" -SecureSecondaries TransferToZoneNameServer
Set-DnsServerPrimaryZone -Name "_msdcs.thematrix.local" -Notify "Notify" -SecureSecondaries TransferToZoneNameServer

# Add reverse lookup zones
Add-DnsServerPrimaryZone -NetworkID 10.0.20.0/24 -ReplicationScope "Domain"
Add-DnsServerPrimaryZone -NetworkID 10.0.30.0/24 -ReplicationScope "Domain"
Add-DnsServerPrimaryZone -NetworkID 10.0.40.0/24 -ReplicationScope "Domain"
Add-DnsServerPrimaryZone -NetworkID 10.0.50.0/24 -ReplicationScope "Domain"

# Set forwarder
Set-DnsServerForwarder -IPAddress 10.0.20.2 -PassThru

# Add A records
$OldObj = Get-DnsServerResourceRecord -Name "." -ZoneName "thematrix.local" -RRType "A" | Select-Object -first 1
$NewObj = $OldObj.Clone()
$NewIP = "10.0.20.3"
$NewObj.RecordData.IPv4Address = [System.Net.IPAddress]::parse($NewIP)
Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName "thematrix.local" -PassThru
Add-DnsServerResourceRecordA -Name dc -ZoneName thematrix.local -IPv4Address 10.0.20.1
Add-DnsServerResourceRecordA -Name ns -ZoneName thematrix.local -IPv4Address 10.0.20.1
Add-DnsServerResourceRecordA -Name ns2 -ZoneName thematrix.local -IPv4Address 10.0.20.2
Add-DnsServerResourceRecordA -Name web -ZoneName thematrix.local -IPv4Address 10.0.20.3
Add-DnsServerResourceRecordA -Name mail -ZoneName thematrix.local -IPv4Address 10.0.20.4
Add-DnsServerResourceRecordA -Name mdt -ZoneName thematrix.local -IPv4Address 10.0.20.5

# Add PTR records
Add-DnsServerResourceRecordPtr -Name "1" -PtrDomainName "ns.thematrix.local" -ZoneName "20.0.10.in-addr.arpa" -computerName agentsmith
Add-DnsServerResourceRecordPtr -Name "2" -PtrDomainName "ns2.thematrix.local" -ZoneName "20.0.10.in-addr.arpa" -computerName agentsmith
Add-DnsServerResourceRecordPtr -Name "3" -PtrDomainName "web.thematrix.local" -ZoneName "20.0.10.in-addr.arpa" -computerName agentsmith
Add-DnsServerResourceRecordPtr -Name "4" -PtrDomainName "mail.thematrix.local" -ZoneName "20.0.10.in-addr.arpa" -computerName agentsmith
Add-DnsServerResourceRecordPtr -Name "5" -PtrDomainName "mdt.thematrix.local" -ZoneName "20.0.10.in-addr.arpa" -computerName agentsmith

# Add CNAME records
Add-DnsServerResourceRecordCName -ZoneName thematrix.local -HostNameAlias "web.thematrix.local" -Name "www"
Add-DnsServerResourceRecordCName -ZoneName thematrix.local -HostNameAlias "web.thematrix.local" -Name "trinity"
Add-DnsServerResourceRecordCName -ZoneName thematrix.local -HostNameAlias "mail.thematrix.local" -Name "smtp"
Add-DnsServerResourceRecordCName -ZoneName thematrix.local -HostNameAlias "mail.thematrix.local" -Name "imap"
Add-DnsServerResourceRecordCName -ZoneName thematrix.local -HostNameAlias "mail.thematrix.local" -Name "neo"
Add-DnsServerResourceRecordCName -ZoneName thematrix.local -HostNameAlias "mdt.thematrix.local" -Name "theoracle"

Write-Host "Reboot niet nodig -> script 4 uitvoeren"