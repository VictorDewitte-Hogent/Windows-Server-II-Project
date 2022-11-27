

# Script Host 

######################

# IP address obtained from DHCP

#####################

######################

# Vars

#####################
$dnsServers = @("192.168.22.5","192.168.22.9")

[ipaddress]$ip = "192.168.22.2"
[ipaddress]$defaultGateway = "192.168.22.1"
[int]$prefix = 24
[string]$interfaceName = "Ethernet"

[string]$domain = "WS2-2223-Victor.hogent"
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
    
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ip -AddressFamily IPv4 -PrefixLength $prefix -DefaultGateway $defaultGateway 
	Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $dnsServers
    Add-Computer -Domain $domain -Credential $joinCred  -WarningAction SilentlyContinue 


    #Firewall and remote management

    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name "fDenyTSConnections" -value 0
	Enable-NetFirewallRule -DisplayGroup "Remote Desktop" | Out-File $logFile -Append

    Set-NetFirewallRule -DisplayGroup "Remote Event Log Management" -Enabled True 
    Set-NetFirewallRule -DisplayGroup "Remote Volume Management" -Enabled True 
    Set-NetFirewallRule -DisplayGroup "Remote Service Management" -Enabled True 
    Set-NetFirewallRule -DisplayGroup "Remote Scheduled Tasks Management" -Enabled True 
    Set-NetFirewallRule -DisplayName 'Windows Management Instrumentation (DCOM-In)' -Enabled True
    
    Set-ItemProperty $registryPath "AutoAdminLogon" -Value "1" -type String 
    Set-ItemProperty $registryPath "DefaultUsername" -Value "Administrator@WS2-2223-victor.hogent" -type String 
    Set-ItemProperty $registryPath "DefaultPassword" -Value "P@ssw0rd" -type String


    Add-Computer -Domain "ws2-2223-Victor.hogent" -Credential $joinCred  -WarningAction SilentlyContinue 


	Restart-And-Resume $script "B"

}
if (Should-Run-Step "B") 
{
	New-SmbShare -Name "IIS-Folder" -Path "C:\IIS-Folder\" -FullAccess "WS2-2223-Victor\Administrators"

	Install-WindowsFeature -name Web-Server 
    #install service
}




