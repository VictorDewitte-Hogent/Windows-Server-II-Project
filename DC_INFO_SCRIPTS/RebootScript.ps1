# Temp Folder
if (!(Get-Item C:\temp -ea ignore)) { mkdir C:\temp }

$dropperscript = 'C:\temp\dropper.ps1'

$dropper = @'
#############################################
###        Configuration Variables        ###
                                            #
# Put any variables you'll use here
                                            # 
###                                       ###
#############################################

# Static Variables
$countfile = 'C:\temp\bootcount.txt'
$bootbatch = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\dropper.bat'
$dropperscript = 'C:\temp\dropper.ps1'

#################
##### Setup #####

# Bootstrap Batch
if (!(Get-Item $bootbatch -ea ignore)) {
    "powershell -c $dropperscript`npause" | Out-File $bootbatch -Encoding 'OEM'
}

# Boot Count
if (Get-Item $countfile -ea ignore) {
    [int]$bootcount = Get-Content $countfile
    if ($bootcount -match "^\d{1,2}$") { ([int]$bootcount) ++ }
    else { $bootcount = 1 }
}
else { $bootcount = 1 }
$bootcount | Out-File $countfile


switch ($bootcount) {
    
    1 {
        # Fill in anything needed on first run
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

        Restart-Computer
        ##################################################
        ###############     --REBOOT--     ###############
    }
    
    2 {
        # Fill in anything needed on second reboot; remove if unneeded
        Write-Host @"
        #######################################
        ##              PART 2/4             ##
        ##             ADDS Setup            ##
        #######################################
        "@
        Start-Sleep 3

        # ADS Setup
        Import-Module ADDSDeployment
        Install-ADDSForest -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName "thematrix.local" -DomainNetbiosName "THEMATRIX" -ForestMode "WinThreshold" -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion -SysvolPath "C:\Windows\SYSVOL" -SafeModeAdministratorPassword (ConvertTo-SecureString "Admin123" -AsPlainText -Force) -Force:$true

        # DNS Setup
        New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters -Name BindSecondaries -Value 1 -PropertyType DWORD -Force    
        Restart-Computer
        ##################################################
        ###############     --REBOOT--     ###############
    }
    
    3 {
        # Fill in anything needed on third reboot; remove if unneeded
        # Create more reboots as needed
        
        Restart-Computer
        ##################################################
        ###############      --END--      ################
    }
    
    default {
        # Dropper is complete; clean up
        rm $countfile
        rm $bootbatch
        rm $dropperscript
    }
}
'@

# Drop and run Dropper

$dropper | Out-File $dropperscript -Encoding 'OEM'

Invoke-Expression $dropperscript