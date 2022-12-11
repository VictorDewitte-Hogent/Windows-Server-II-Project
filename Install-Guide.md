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










### FIX



