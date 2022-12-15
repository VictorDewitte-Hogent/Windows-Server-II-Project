

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

	#Cert generaten voor https
	if (-NOT([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		Write-Host "Administrator priviliges are required. Please restart this script with elevated rights." -ForegroundColor Red
		Pause
		Throw "Administrator priviliges are required. Please restart this script with elevated rights."
	}


	
	$UID = [guid]::NewGuid()
	$files = @{}
	$files['settings'] = "$($env:TEMP)\$($UID)-settings.inf";
	$files['csr'] = "$($env:TEMP)\$($UID)-csr.req"


	$request = @{}
	$request['SAN'] = @{}

	Write-Host "Provide the Subject details required for the Certificate Signing Request" -ForegroundColor Yellow
	$request['CN'] = "www.WS2-2223-Victor.hogent"
	$request['O'] = "Hogent"
	$request['OU'] = "IT"
	$request['L'] = "Gent"
	$request['S'] = "Oost-Vlaanderen"
	$request['C'] = "BE"


	
	$settingsInf = "
	[Version] 
	Signature=`"`$Windows NT`$ 
	[NewRequest] 
	KeyLength =  2048
	Exportable = TRUE 
	MachineKeySet = TRUE 
	SMIME = FALSE
	RequestType =  PKCS10 
	ProviderName = `"Microsoft RSA SChannel Cryptographic Provider`" 
	ProviderType =  12
	HashAlgorithm = sha256
	;Variables
	Subject = `"CN={{CN}},OU={{OU}},O={{O}},L={{L}},S={{S}},C={{C}}`"
	[Extensions]
	{{SAN}}
	;Certreq info
	;http://technet.microsoft.com/en-us/library/dn296456.aspx
	;CSR Decoder
	;https://certlogik.com/decoder/
	;https://ssltools.websecurity.symantec.com/checker/views/csrCheck.jsp
	"

	$request['SAN_string'] = & {
		if ($request['SAN'].Count -gt 0) {
			$san = "2.5.29.17 = `"{text}`"
	"
			Foreach ($sanItem In $request['SAN'].Values) {
				$san += "_continue_ = `"dns="+$sanItem+"&`"
	"
			}
			return $san
		}
	}

	$settingsInf = $settingsInf.Replace("{{CN}}",$request['CN']).Replace("{{O}}",$request['O']).Replace("{{OU}}",$request['OU']).Replace("{{L}}",$request['L']).Replace("{{S}}",$request['S']).Replace("{{C}}",$request['C']).Replace("{{SAN}}",$request['SAN_string'])

	
	$settingsInf > $files['settings']

	# Done, we can start with the CSR
	Clear-Host

	

	# Display summary
	Write-Host "Certificate information
	Common name: $($request['CN'])
	Organisation: $($request['O'])
	Organisational unit: $($request['OU'])
	City: $($request['L'])
	State: $($request['S'])
	Country: $($request['C'])
	Subject alternative name(s): $($request['SAN'].Values -join ", ")
	Signature algorithm: SHA256
	Key algorithm: RSA
	Key size: 2048
	" -ForegroundColor Yellow

	certreq -new $files['settings'] $files['csr'] > $null

	# Output the CSR
	$CSR = Get-Content $files['csr'] > "C:\cert.csr"
	Write-Output $CSR
	Write-Host "
	"


	########################
	# Remove temporary files
	########################
	$files.Values | ForEach-Object {
		Remove-Item $_ -ErrorAction SilentlyContinue
	}

	certreq -submit -attrib "CertificateTemplate:WebServer" C:\Users\Administrator\Documents\WinServer2.csr
	Import-Certificate -FilePath C:\Users\Administrator\Documents\WinServer2022.cer `
	-CertStoreLocation Cert:\LocalMachine\My\
	$cert = (Get-ChildItem -Path cert:\LocalMachine\My\ | Where-Object {$_.Subject -like "*www.ws2-2223-Victor.hogent*"})
	New-WebBinding -Name "Default Web Site" -IPAddress "*" -Port 443 -HostHeader "www.WS2-2223-Victor.hogent" -Protocol "https"
	(Get-WebBinding -Name "Default Web Site" -Port 443 -Protocol "https").AddSslCertificate($cert.Thumbprint, "my")
}




