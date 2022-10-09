# Portfolio Windows Server II: Victor Dewitte



## Inleiding

In de opstelling wordt er gebruik gemaakt van 4 virtuele machine's dit elk met een versie van windows server 2019. De DC server is de enige server met een grafische interface. De andere server's hebben geen grafische interface. De DC server is de enige server die gebruikt wordt voor het beheer van de andere server's. 


## DomeinController-Server

Op de domeincontroller server met een gui zullen volgende services draaien:
 - AD DS 
 - DNS
 - DHCP
 - CA
 - Router role met NAT

De server zal beschikken over 2 cores met 4gb ram en de windows server 2019 64bit operating system zal er op geinstalleerd zijn met de desktop expierence (dus met een grafische interface). De server zal ook beschikken over een 35gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine.
De server heeft ook 2 network interface's:
- 1 voor het interne netwerk, die een statisch ip adres heeft in de range van het interne netwerk : 192.168.22.1
- 1 voor de NAT verbinding die heel de omgeving zal voorzien van een verbinding met het internet. Deze interface heeft een dynamisch ip adres die hij krijgt van de DHCP server van Virtualbox.

De Active Directory Domain Services (AD DS) zal geinstalleerd zijn op de DomeinController. Deze zal de domeinnaam "WS2-2223-Victor.hogent" hebben. De Active Directory zal een apart service account voorzien voor elke applicatie die op de server's draait. De service accounts zullen een random password hebben. Ook zal het de nodige accounts hebben voor gewone gebruikers en mensen die mogelijkse toegang hebben tot de sql server maar geen data kunnen aanpassen. Met andere woorden de correcte Orginaizational Units en Group Policies zullen aanwezig zijn binnen het domein.

De DNS Server zal automatisch...
 

