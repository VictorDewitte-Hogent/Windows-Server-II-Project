# Install Guide Windows Server II Omgeving Victor Dewitte

## Voorvereisten

Voor je kan beginnen aan de installatie van de omgeving zijn er een paar dingen die je opvoorhand moet installeren en downloaden. Ook zullen er in de scripts bepaalde paden moeten worden aangepast worden naar de juiste locaties.

<b>De nodige software:</b>
- VirtualBox (met de guestadditions)

<b>Bestanden die moeten gedownload zijn:</b>
- Windows Server 2019 ISO bestand
    - https://downloads.academicsoftware.eu/windowsserver2019/en_windows_server_2019_x64_dvd_4cb967d8.iso
- Windows 10 ISO bestand
    - https://downloads.academicsoftware.eu/Windows10/Windows10_64-Bits/SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO
- Sql Server ISO
    - https://downloads.academicsoftware.eu/Microsoft/SQL%20Server/en_sql_server_2019_standard_x64_dvd_814b57aa.iso
- Exchange ISO
    - Verkregen op chamilo

### Paden in de scripts aanpassen

In de scripts die je zal vinden in de map `Scripts` moet je de paden aanpassen naar de juiste locaties. Dit zijn de volgende paden:
 - VboxManageScript
```ps1
### HIER AANPASSEN  #####
# Zet hier het pad naar u Windows Server 2019 ISO
[String]$PathISO="C:\Users\VictorDewitte\Desktop\WindowsServer2\en_windows_server_2019_x64_dvd_4cb967d8.iso"
# Zet hier het pad naar u Windows 10
[String]$PathISO2="C:\Users\VictorDewitte\Desktop\WindowsServer2\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"

# Zet hier het pad naar waar u de VM wilt opslaan
[string]$path1 = "C:\Users\VictorDewitte\VMs\"

# Zet hier het pad naar waar u de Shared Folder heeft opgeslagen
[String]$sharedFolder = "C:\Users\VictorDewitte\Documents\SharedFolder"             



# Plaats hier het pad naar de scripts folder van het Windows Server II Project
[string]$scripts = "C:\Users\VictorDewitte\Desktop\WindowsServer2\Windows-Server-II-Project\Scripts\"
#############################



```
De ISO's van sql server en exchange moeten in de zelfde folder komen van de powershell scripts. `{zipfile}/scripts/{sql/ exchange}/{Iso's}`


## Installatie

De installatie start bij het `VboxManageScript`. Dit script zal de VM's aanmaken en de nodige instellingen doen. De windows installeren. Ook de nodige software installeren op de VM's. 

Bij het laatste deel, dus het installeren van de software is het doel van de scripts die geschreven zijn is om de installatie van de omgeving zo makkelijk mogelijk te maken. Jammer genoeg is de werking van de scripts niet 100%. Daarom schrijf ik hieronder een stappenplan in het geval dat de scripts niet werken en wat je kan doen om toch nog zo weinig mogelijk manueel te hoeven doen.

Na het runnen van het script `VboxManageScript` zal je volgend interactief menu zien

![VboxManageScript](Portfolio\IMG\VboxScript.png)

Deze zal je vragen om een keuze te maken. Je kan kiezen tussen de volgende opties: 1-12 of Q.

Q zal het script afsluiten.

1-12 zal de volgende acties uitvoeren:
- 1: Zal alle vm's aanmaken in VirtualBox. Deze worden ook geconfigureerd met de juiste instellingen.


![VboxMachinesExist](Portfolio\IMG\VboxMachinesExist.png)
- 2: Zal de Windows Server 2019 installeren op de VM `DC1`. Deze zal ook opstarten met een GUI.
- 3-5: Zal windows Server 2019 Core installeren op de VM's `SQL1`, `EX1` en `IIS1`. Deze installaties zullen in de achtergrond gebeuren.

- 6: Zal de Windows 10 installeren op de VM `Host1`. Deze zal ook opstarten met een GUI.

### Vanaf hier kan het zijn dat de scripts niet meer werken. In dat geval kan je de [volgende](###FIX) stappen volgen.

- 7: copiert de bestanden van de folder naar de VM DC en start het instellen van alle nodige instellingen op de DC.

- 8: copiert de bestanden van de folder naar de VM SQL en start het instellen van alle nodige instellingen op de SQL.

- 9: copiert de bestanden van de folder naar de VM EX en start het instellen van alle nodige instellingen op de EX.

- 10: copiert de bestanden van de folder naar de VM IIS en start het instellen van alle nodige instellingen op de IIS.

In principe als alle scripts werken zou de omgeving nu moeten compleet zijn.

### FIX

Indien de scripts via het vboxmanage script niet correct runnen (als het bij dc niet werkt zal het niet werken bij de rest) zal je volgende stappen moeten ondernemen:

- 1: Verwijder de dc vm

- 2: Herstart het script `VboxManageScript` en kies voor optie 1

- 3: Kies dan optie 2 om de dc opnieuw te installeren

- 4: Dan moet je deze command runnen om de scirpts te copieren naar de dc

```ps1
#De naam moet zelf ingevuld worden 
vboxmanage guestcontrol $name copyto $scripts "C:\" --username $username --password $password
#als je dit in het zelfde venster van het vboxmanage script zijn de vars nog gesaved
#indien niet zo run vboxmanagescript en press q   
```
![VboxMachinesExist](Portfolio\IMG\IncaseOfEmergency.png)

- 5: Dan kan je met ise of notepad de scripts openen.

- 6: Het install stuk van elk script staat in blokken van grote if statements. Elk van deze blokken tot aan `Restart-And-Resume $script "D"` kunnen uitgevoerd worden in een powershell scherm. Tussen elk blok moet de Server gerestart worden.
```ps1
#Example from Exchange script
# The parts that are commented out are the parts that are not neccesary when doing the scripts more manually.
# if (Should-Run-Step "A") 
# {   
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

# 	Restart-And-Resume $script "B"

# }

```


- 7: Deze paar stappen herhalen zich voor elk van de volgende VM's



