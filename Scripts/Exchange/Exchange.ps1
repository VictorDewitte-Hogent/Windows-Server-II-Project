# Script Voor de configuratie van de Exchange server



######################

# Vars

#####################
$dnsServers = @("192.168.22.1","192.168.22.3")

[ipaddress]$ip = "192.168.22.4"
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
[string]$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"


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

    #Domain JOINEN
    Add-Computer -Domain $domain -Credential $joinCred  -WarningAction SilentlyContinue
     
    Install-Windows Feature -Name NET-Framework-45-Features, RSAT-ADDS, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-PowerShell

    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    #choco install urlrewrite --version 2.1.20190828 -y
    choco install vcredist2013 --version 12.0.40660.20180427 -y
    choco install vcredist2012 --version 11.0.61031.20220311 -y
    choco install dotnetfx --version 4.8.0.20220524 -y
    
    Install-WindowsFeature Server-Media-Foundation

    Invoke-WebRequest -Uri "http://www.microsoft.com/web/handlers/webpi.ashx?command=getinstallerredirect&appid=urlrewrite2" -OutFile "C:\Users\Administrator\Desktop\urlrewrite.exe"
    Set-Location C:\Users\Administrator\Desktop\
    .\urlrewrite.exe

    Set-ItemProperty $registryPath "AutoAdminLogon" -Value "1" -type String 
    Set-ItemProperty $registryPath "DefaultUsername" -Value "Administrator@WS2-2223-victor.hogent" -type String 
    Set-ItemProperty $registryPath "DefaultPassword" -Value "P@ssw0rd" -type String

	Restart-And-Resume $script "B"

}
if (Should-Run-Step "B") 
{

	Mount-DiskImage -ImagePath "C:\Exchange\mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
    $Drive = Get-Volume -FileSystemLabel "exchange*" 
    $DriveLetter = $Drive.DriveLetter
    Set-Location  -Path "$($DriveLetter):\UCMARedist\"

    
    .\setup.exe


    Restart-And-Resume $script "C"

    
}

if (Should-Run-Step "C") 
{
    Mount-DiskImage -ImagePath "C:\Exchange\mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
    $Drive = Get-Volume -FileSystemLabel "exchange*" 
    $DriveLetter = $Drive.DriveLetter
    Set-Location  -Path "$($DriveLetter):\"
    Add-WindowsCapability –online –Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
    .\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareSchema

    .\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareAD /OrganizationName:"ws2-2223-victor" 

    .\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareAllDomains 

    .\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /mode:Install /Role:Mailbox /InstallWindowsComponents

}