#=================================================================================#
#========== Script voor de configuratie en installatie van de SQL server =========#
#=================================================================================#

#========== Variabelen ==========#
param($Step="A")
$script = $myInvocation.MyCommand.Definition
#========== Firewall ==========#
$firear = @("Remote Event Log Management","Remote Volume Management","Remote Service Management","Remote Scheduled Tasks Management")
#========== Netwerk ==========#
$dnsArray = @("192.168.22.5","192.168.22.9")
[ipaddress]$sqlIp = "192.168.22.8"
[ipaddress]$defaultGatIp = "192.168.22.5"
[int]$prefix = 24
[string]$intName = "LAN"
#========== Domein ==========#
[string]$fullDomain = "WS2-2223-victor.hogent"
#========== SQL ==========#
[string]$SQLSVCPASSWORD = "21Admin22"
[string]$SQLSYSADMINACCOUNTS = "WS2-2223-victor\Administrator"
#========== Extra ==========#
[string]$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
[string]$logFile = "C:\ScriptsSQL\log.txt"
$cred = New-Object pscredential -ArgumentList ([pscustomobject]@{
	UserName = $null
	Password = (ConvertTo-SecureString -String "21Admin22" -AsPlainText -Force)[0]})


#========== Speciale variabelen ==========#
$global:started = $FALSE
$global:startingStep = $Step
$global:restartKey = "Restart-And-Resume"
$global:RegRunKey ="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$global:powershell = (Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe")

#========== Functies ==========#
function logMsg($msg)
{
    $msg | Out-File $logFile -Append 
    Write-Host $msg -ForegroundColor Green
}

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

#========== Start van de installatie ==========#
logMsg("========== Start van de installatie ==========") 
Clear-Any-Restart

if (Should-Run-Step "A") 
{
	
	#========== Netwerk configuratie ==========#
	logMsg("========== Netwerk configuratie ==========")  
	Rename-NetAdapter -Name "Ethernet" -NewName $intName 
	New-NetIPAddress -InterfaceAlias $intName -IPAddress $sqlIp -AddressFamily IPv4 -PrefixLength $prefix -DefaultGateway $defaultGatIp | Out-File $logFile -Append
	Set-DnsClientServerAddress -InterfaceAlias $intName -ServerAddresses $dnsArray | Out-File $logFile -Append

	#========== Joinen bij het domein ==========#
	logMsg("========== Joinen bij het domein ==========")
	Start-Sleep -Seconds 10
	Add-Computer -DomainName $fullDomain -Credential $cred | Out-File $logFile -Append 

	#========== Remote management configuratie ==========#
	logMsg("========== Remote management configuratie ==========")  
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name "fDenyTSConnections" -value 0
	Enable-NetFirewallRule -DisplayGroup "Remote Desktop" | Out-File $logFile -Append

	foreach ($rule in $firear){

		Set-NetFirewallRule -DisplayGroup $rule -Enabled True | Out-File $logFile -Append
	
	}
	Set-NetFirewallRule -DisplayName 'Windows Management Instrumentation (DCOM-In)' -Enabled True | Out-File $logFile -Append

	#========== Instellen van het automatisch inloggen als domein administrator ==========#
	logMsg("========== automatisch inloggen als domein administrator ==========") 
	Set-ItemProperty $regPath "AutoAdminLogon" -Value "1" -type String 
    Set-ItemProperty $regPath "DefaultUsername" -Value "Administrator@WS2-2223-victor.hogent" -type String 
    Set-ItemProperty $regPath "DefaultPassword" -Value "21Admin22" -type String
    Restart-And-Resume $script "B"

}
if (Should-Run-Step "B") 
{

	#========== Installatie van de SQL server ==========#
	logMsg("========== Installatie van de SQL server ==========") 
	Mount-DiskImage -ImagePath "C:\ScriptsSQL\en_sql_server_2019_standard_x64_dvd_814b57aa.iso"| Out-File $logFile -Append
	$Drive = Get-Volume -FileSystemLabel "Sql*" 
	$DriveLetter = $Drive.DriveLetter
	Set-Location  -Path "$($DriveLetter):\"
	.\setup.exe /qs /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="NT SERVICE\MSSQLSERVER" /SQLSVCPASSWORD=$SQLSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /SUPPRESSPRIVACYSTATEMENTNOTICE
	Restart-And-Resume $script "C"
		
}

if (Should-Run-Step "C") 
{
	#========== Verder configuratie van SQL ==========#
	logMsg("========== Verder configuratie van SQL ==========") 
	sqlcmd -i "SQLConfiguratiePart3.sql"
	Set-service sqlbrowser -StartupType Auto | Out-File $logFile -Append
	Start-service sqlbrowser | Out-File $logFile -Append

	#========== Firewall configuratie voor SQL ==========#
	logMsg("========== Firewall configuratie voor SQL ==========") 
	New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow | Out-File $logFile -Append
	New-NetFirewallRule -DisplayName "SQLServer Browser service" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow | Out-File $logFile -Append

	#========== Configuratie van de SQL instantie ==========#
	logMsg("========== Configuratie van de SQL instantie ==========") 
	Import-Module SQLPS
	$smo = 'Microsoft.SqlServer.Management.Smo.'
	$wmi = new-object ($smo + 'Wmi.ManagedComputer')
	$uri = "ManagedComputer[@Name='" + (get-item env:\computername).Value + "']/ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"
	$Tcp = $wmi.GetSmoObject($uri)
	$Tcp.IsEnabled = $true
	$Tcp.Alter()
	$Tcp
		
}
