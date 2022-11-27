# Script Host 

######################

# IP address obtained from DHCP

#####################

######################

# Vars

#####################

$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = $null
    Password = (ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force)[0]
})
#######################

# Restart vars 

#######################
param($Step="A")
$script = $myInvocation.MyCommand.Definition
$global:started = $FALSE
$global:startingStep = $Step
$global:restartKey = "Restart-And-Resume"
$global:RegRunKey ="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$global:powershell = (Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe")
[string]$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"


######################

# Functies 

######################


function Should-Run-Step([string] $prospectStep) 
{
	if ($global:startingStep -eq $prospectStep -or $global:started) {
		$global:started = $TRUE
	}
	return $global:started
}

function Wait-For-Keypress([string] $message, [bool] $shouldExit=$FALSE) 
{
	Write-Host "$message" -foregroundcolor yellow
	$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	if ($shouldExit) {
		exit
	}
}

function Test-Key([string] $path, [string] $key)
{
    return ((Test-Path $path) -and ((Get-Key $path $key) -ne $null))   
}

function Remove-Key([string] $path, [string] $key)
{
	Remove-ItemProperty -path $path -name $key
}

function Set-Key([string] $path, [string] $key, [string] $value) 
{
	Set-ItemProperty -path $path -name $key -value $value
}

function Get-Key([string] $path, [string] $key) 
{
	return (Get-ItemProperty $path).$key
}

function Restart-And-Run([string] $key, [string] $run) 
{
	Set-Key $global:RegRunKey $key $run
	Restart-Computer -Force
	exit
} 

function Clear-Any-Restart([string] $key=$global:restartKey) 
{
	if (Test-Key $global:RegRunKey $key) {
		Remove-Key $global:RegRunKey $key
	}
}

function Restart-And-Resume([string] $script, [string] $step) 
{
	Restart-And-Run $global:restartKey "$global:powershell $script -Step $step"
}

#####################

# installatie

#####################
Clear-Any-Restart

if (Should-Run-Step "A") 
{
    
    
    Start-Sleep 3
    
    # Hostname AD is DC
    Rename-Computer -NewName "DC"
    Rename-NetAdapter -Name "Ethernet" -NewName "WAN"
    Rename-NetAdapter -Name "Ethernet2" -NewName "LAN"

    # Verander IP-adres
    New-NetIPAddress -InterfaceAlias LAN -IPAddress 192.168.22.3 
    Set-NetIPAddress -InterfaceAlias LAN -IPAddress 192.168.22.3 -PrefixLength 24
    # DNS Servers instellen
    Set-DnsClientServerAddress -InterfaceAlias LAN -ServerAddresses ("192.168.22.1","")
    # IPv6 uitschakelen
    Disable-NetAdapterBinding -InterfaceAlias “LAN” -ComponentID ms_tcpip6
    # Execution Policy wijzigen
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
    # Installeer AD-Domain-Services
    Add-WindowsFeature AD-Domain-Services -IncludeManagementTools
    # Installeer DNS Server
    Add-WindowsFeature DNS -IncludeManagementTools

    Restart-And-Resume $script "B"
}
if (Should-Run-Step "B") 
{
	Start-Sleep 3

    # ADS Setup
    Import-Module ADDSDeployment
    Install-ADDSForest -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName "ws2-2223-victor.hogent" -DomainNetbiosName "WS2-2223-VICTOR" -ForestMode "WinThreshold" -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion -SysvolPath "C:\Windows\SYSVOL" -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -Force:$true

    # DNS Setup
    New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters -Name BindSecondaries -Value 1 -PropertyType DWORD -Force
    Restart-And-Resume $script "C"
}
if (Should-Run-Step "C") 
{
    Add-DnsServerResourceRecord -ZoneName ws2-2223-victor.hogent -ns -name ws2-2223-victor.hogent -NameServer ns.ws2-2223-victor.hogent
    Add-DnsServerResourceRecord -ZoneName _msdcs.ws2-2223-victor.hogent -ns -name _msdcs.ws2-2223-victor.hogent -NameServer ns.ws2-2223-victor.hogent
    Set-DnsServerPrimaryZone -Name "ws2-2223-victor.hogent" -Notify "Notify" -SecureSecondaries TransferToZoneNameServer
    Set-DnsServerPrimaryZone -Name "_msdcs.ws2-2223-victor.hogent" -Notify "Notify" -SecureSecondaries TransferToZoneNameServer

    # Add reverse lookup zones
    Add-DnsServerPrimaryZone -NetworkID 192.168.22.0/24 -ReplicationScope "Domain"


    # Set forwarder
    Set-DnsServerForwarder -IPAddress 8.8.8.8, 1.1.1.1, 208.67.222.222  -PassThru


    # Add A records
    $OldObj = Get-DnsServerResourceRecord -Name "." -ZoneName "ws2-2223-victor.hogent" -RRType "A" | Select-Object -first 1
    $NewObj = $OldObj.Clone()
    $NewIP = "192.168.22.2"
    $NewObj.RecordData.IPv4Address = [System.Net.IPAddress]::parse($NewIP)
    Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName "ws2-2223-victor.hogent" -PassThru
    Add-DnsServerResourceRecordA -Name dc -ZoneName ws2-2223-victor.hogent -IPv4Address 192.168.22.1
    Add-DnsServerResourceRecordA -Name ns -ZoneName ws2-2223-victor.hogent -IPv4Address 192.168.22.1
    Add-DnsServerResourceRecordA -Name iis -ZoneName ws2-2223-victor.hogent -IPv4Address 192.168.22.2
    Add-DnsServerResourceRecordA -Name sql -ZoneName ws2-2223-victor.hogent -IPv4Address 192.168.22.3
    Add-DnsServerResourceRecordA -Name mail -ZoneName ws2-2223-victor.hogent -IPv4Address 192.168.22.4


    # Add PTR records
    Add-DnsServerResourceRecordPtr -Name "1" -PtrDomainName "dc.ws2-2223-victor.hogent" -ZoneName "22.168.192.in-addr.arpa" -computerName agentsmith
    Add-DnsServerResourceRecordPtr -Name "2" -PtrDomainName "iis.ws2-2223-victor.hogent" -ZoneName "22.168.192.in-addr.arpa" -computerName agentsmith
    Add-DnsServerResourceRecordPtr -Name "3" -PtrDomainName "sql.ws2-2223-victor.hogent" -ZoneName "22.168.192.in-addr.arpa" -computerName agentsmith
    Add-DnsServerResourceRecordPtr -Name "4" -PtrDomainName "mail.ws2-2223-victor.hogent" -ZoneName "22.168.192.in-addr.arpa" -computerName agentsmith


    # Add CNAME records
    Add-DnsServerResourceRecordCName -ZoneName ws2-2223-victor.hogent -HostNameAlias "iis.ws2-2223-victor.hogent" -Name "www"
    Add-DnsServerResourceRecordCName -ZoneName ws2-2223-victor.hogent -HostNameAlias "iis.ws2-2223-victor.hogent" -Name "web"
    Add-DnsServerResourceRecordCName -ZoneName ws2-2223-victor.hogent -HostNameAlias "mail.ws2-2223-victor.hogent" -Name "smtp"
    Add-DnsServerResourceRecordCName -ZoneName ws2-2223-victor.hogent -HostNameAlias "mail.ws2-2223-victor.hogent" -Name "imap"
    Add-DnsServerResourceRecordCName -ZoneName ws2-2223-victor.hogent -HostNameAlias "mail.ws2-2223-victor.hogent" -Name "Exchange"
    

    Install-WindowsFeature DHCP -IncludeManagementTools

    netsh dhcp add sercuritygroups

    Restart-Service dhcpserver

    Add-DhcpServerInDC -DnsName dc.ws2-2223-Victor.hogent -IPAddress 127.0.0.1

    Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2

    Add-DhcpServerv4Scope -name "Corpnet" -StartRange 192.168.22.101 -EndRange 192.168.22.150 -SubnetMask 255.255.255.0 -State Active
    Set-DhcpServerv4OptionValue -OptionID 3 -Value 192.168.22.1 -ScopeID 192.168.22.0 -ComputerName dc.ws2-2223-victor.hogent
    Set-DhcpServerv4OptionValue -DnsDomain dc.ws2-2223-Victor.hogent -DnsServer 192.168.22.1
    Set-DhcpServerv4OptionValue -ComputerName "dc.ws2-2223-victor.hogent" -ScopeId 192.168.22.0 -Router 192.168.22.1 


    $features=@(
    'RemoteAccess',
    'DirectAccess-VPN',
    'Routing',
    'Web-Server',
    'Web-WebServer',
    'Web-Common-Http',
    'Web-Default-Doc',
    'Web-Dir-Browsing',
    'Web-Http-Errors',
    'Web-Static-Content',
    'Web-Health',
    'Web-Http-Logging',
    'Web-Performance',
    'Web-Stat-Compression',
    'Web-Security',
    'Web-Filtering',
    'Web-IP-Security',
    'Web-Mgmt-Tools',
    'Web-Scripting-Tools',
    'Windows-Internal-Database',
    'GPMC',
    'RSAT',
    'RSAT-Role-Tools',
    'RSAT-RemoteAccess',
    'RSAT-RemoteAccess-Powershell'
    )
    Install-WindowsFeature -Name $features
    Install-WindowsFeature Routing -IncludeManagementTools



    Install-RemoteAccess -VpnType Vpn
    $IntInternet="WAN"
    $IntLOKAAL="LAN"
    cmd.exe /c "netsh routing ip nat install"
    cmd.exe /c "netsh routing ip nat add interface $IntInternet"
    cmd.exe /c "netsh routing ip nat set interface $IntInternet mode=full"
    cmd.exe /c "netsh routing ip nat add interface $IntLOKAAL"

    #CA NOG DOEN


    Restart-And-Resume $script "D"
}
if (Should-Run-Step "D") 
{   
    # create profiles smb share
    New-Item -Path "C:\" -Name "UserProfiles" -ItemType "directory"
    New-SmbShare -Name "UserProfiles" -Path "C:\UserProfiles" -ChangeAccess "Users" -FullAccess "Administrators"

    #create homedir smb share
    New-Item -Path "C:\" -Name "HomeFolder" -ItemType "directory"
    New-SmbShare -Name "HomeFolder" -Path "C:\HomeFolder" -ChangeAccess "Users" -FullAccess "Administrators"
    $OUnames = @('Administratie', 'ServiceAccounts')
    foreach ($OUname in $OUnames){
        New-ADOrganizationalUnit -Name "$($OUname)" -Path "DC=thematrix,DC=local"
        Write-Host "✅ OU $OUname werd aangemaakt!"
    }
    $OUINNERnames = @('HostAdmins', 'SQLAdmins', 'IISAdmins', 'ExchangeAdmins')
    foreach ($OUname in $OUnames){
        New-ADOrganizationalUnit -Name "$($OUname)" -Path "DC=thematrix,DC=local,OU=ServiceAccounts"
        Write-Host "✅ OU $OUname werd aangemaakt!"
    }
    $groups = Import-Csv -Path "C:\DC\Groups.csv" -Delimiter ";"
    foreach ($group in $groups){
        New-ADGroup -Name "$($group.GroupName)" -SamAccountName "$($group.SamGroupName)" -GroupCategory "$($group.GroupCategory)" -GroupScope "$($group.GroupScope)" -DisplayName "$($group.DisplayName)" -Path "$($group.Path)" -Description "$($group.Description)"
        Write-Host "✅ Group $($group.GroupName) werd aangemaakt!"
    }



    $users = Import-Csv -Path "C:\DC\Users.csv" -Delimiter ";"
    foreach($user in $users){
        $username = $user.username
        $first = $user.First
        $last = $user.Last
        $path = $user.Path
        $userPrincipalName = $username + "@ws2-2223-victor.hogent"
        $profilepath = "\\dc\UserProfiles\%username%"
        $homepath = "\\dc\HomeFolder\$username"
        New-Item -Path "C:\HomeFolder" -Name $username -ItemType "directory"
        New-ADUser -Name "$first $last" -GivenName $first -Surname $last -SamAccountName $username -DisplayName $username -UserPrincipalName $userPrincipalName -ProfilePath $profilepath -HomeDirectory $homepath -HomeDrive H: -Path $path -Accountpassword (ConvertTo-SecureString "Letmein123" -AsPlainText -Force) -Enabled $true
        Write-Host "✅ User $first $last werd aangemaakt!"
    }

    
}


#New-ADComputer -Name "Host" -AccountPassword (ConvertTo-SecureString -String 'Temp' -AsPlainText -Force)