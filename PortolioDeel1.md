# Portfolio Windows Server II: Victor Dewitte



## Inleiding

In de opstelling wordt er gebruik gemaakt van 4 virtuele machine's dit elk met een versie van windows server 2019. De DC server is de enige server met een grafische interface. De andere server's hebben geen grafische interface. De DC server is de enige server die gebruikt wordt voor het beheer van de andere server's.

|          | IP-Adressen  |
|----------|--------------|
| DC       | 192.168.22.1 |
| IIS      | 192.168.22.2 |
| SQL      | 192.168.22.3 |
| Exchange | 192.168.22.4 |
| Client   | DHCP         |

<figure>
<img src="Portfolio\IMG\Screenshot 2022-10-12 153105.png" alt="Screenshot 2022-10-12 153105" style="width:100%" />
<figcaption align = "center"><b>Fig.1 - Grafische weergave van de opstelling van de servers</b></figcaption>
</figure>

 

## DomeinController-Server

Op de domeincontroller server met een gui zullen volgende services draaien:
 - AD DS 
 - DNS
 - DHCP
 - CA
 - Router role met NAT

De server zal beschikken over 2 cores met 4gb ram en de windows server 2019 64 bit operating systeem zal er op geinstalleerd zijn met de desktop expierence (dus met een grafische interface). De server zal ook beschikken over een 35gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De complete domeinnaam van deze server zal `dc.ws2-2223-victor.hogent` zijn.
De server heeft ook 2 network interface's:
- 1 voor het interne netwerk, die een statisch ip adres heeft in de range van het interne netwerk : 192.168.22.1
- 1 voor de NAT verbinding die heel de omgeving zal voorzien van een verbinding met het internet. Deze interface heeft een dynamisch ip adres die hij krijgt van de DHCP server van Virtualbox.

De Active Directory Domain Services (AD DS) zal geinstalleerd zijn op de DomeinController. Deze zal de domeinnaam `"WS2-2223-Victor.hogent"` hebben. Na de installatie zal in de post deployment volgende stappen uitgevoerd worden:
    - We checken de de config van de server met ADprep /forestprep en ADprep /domainprep zodat de server klaar is om een domein te hosten.
    - Na dit wordt het forest en domain functioneel level ingesteld op windows server 2016. Ook worden de capabilities van de AD DS geselecteerd. Deze zijn GC ( Global Catalog) en DNS (Domain Name System). Ook wordt er een DSRM (Directory Services Restore Mode) password ingesteld.
Er kan een DNS Delagation gemaakt worden op de DNS server, dit wordt in dit geval niet gedaan.

De NetBIOS naam wordt ingesteld op `WS2-2223-VICTOR`. NetBIOS-naam is een naam van 16 bytes voor een netwerkservice of -functie op een computer met Microsoft Windows Server. NetBIOS-namen zijn een gebruiksvriendelijkere manier om computers in een netwerk te identificeren dan netwerknummers en worden gebruikt door NetBIOS-compatibele services en toepassingen.

Er is ook een directory pad nodig voor de AD DS database, log files en de SYSVOL. Die wordt op de standaard paden van `C:\Windows\NTDS` en `C:\Windows\SYSVOL` ingesteld. 
    De database folder heeft een paar belangrijke bestanden. De database gebruikt de ESE(Extensible Storage Engine), dit is een database engine die gebruikt wordt door de AD DS database.     
De SYSVOL is een gedeelde map waarin de serverkopie van de openbare bestanden van het domein wordt opgeslagen die moeten worden gedeeld voor algemene toegang en replicatie in een domein.
<figure>
<img src="Portfolio\IMG\SysVol.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.2 - C:\Windows\ folder met de SYSVOL folder in</b></figcaption>
</figure>

Er is binnen de Active Directory 2 admin accounts voorzien met volle rechten voor alles te doen binnen het AD. Ze kunnen alles op elke pc/server binnen het domein aanpassen. Er is het standaard Administrator account en een account voor mezelf.
<figure>
<img src="Portfolio\IMG\Admins.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.3 - Admin Accounts voorzien in de AD</b></figcaption>
</figure>
<figure>
<img src="Portfolio\IMG\Admins.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.4 - De rechten van het "Victor Dewitte" account</b></figcaption>
</figure>


Daarnaast zijn er de gewone gebruikers. Die toegang hebben tot het gebruiken van de gewone host computers. Ze kunnen daar de basis taken op uitvoeren. Ze hebben geen toegang tot het inloggen in de servers. 

<figure>
<img src="Portfolio\IMG\Users.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.5 - Users in de AD</b></figcaption>
</figure>

Sommige user's zullen extra rechten hebben om toegang te hebben tot de SQL Server. Deze zullen lid zijn van de SQL_Users groep. Deze groep zal ook de rechten hebben om de SQL Server te gebruiken maar niet beheren.


De Active Directory zal een apart service account voorzien voor elke applicatie die op de server's draait. Dit zal gedaan worden aan de hand van groepen die in de AD die toegevoegd worden tot de Admin users van de machine van wie ze admin rechten nodig hebben. De groepen zullen de naam van de applicatie hebben. Binnen de groepen kunnen er dan gemakkelijk gebruikers toegevoegd worden en verwijderd worden naar gelang er mensen komen en gaan die de rechten nodig hebben op die machines.

<figure>
<img src="Portfolio\IMG\ServiceAccounts.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.6 - Service Accounts OU</b></figcaption>
</figure>
<figure>
<img src="Portfolio\IMG\HostAdmin.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.7 - Groep van de Host Admins</b></figcaption>
</figure>



De DNS Server zal automatisch geconfigureerd worden door de AD DS, de nodige ldap records zullen dus automatisch gegenereerd worden. De DNS server zal ook de nodige forward lookup zones voorzien. Samen met de nodige AD DS records zullen er ook wat A records in de forward lookup zone zitten naar de servers, samen met een paar CNAME records en een MX record voor de Mail Server.

<figure>
<img src="Portfolio\IMG\ForwardZone.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.8 - DNS Server forward lookup zone</b></figcaption>
</figure>


De DNS server zal ook de nodige reverse lookup records voorzien die automatisch kunnen gegenereerd worden door het aanmaken van de A records.
<figure>
<img src="Portfolio\IMG\ReverseZone.png" alt="Trulli" style="width:100%">
<figcaption align = "center"><b>Fig.9 - DNS Server PTR records</b></figcaption>
</figure>

De forwarders van de DNS server zullen ingesteld worden op die van op een hele hoop forwarders. Dit indien er een van de DNS servers niet bereikbaar is, zal de DNS server automatisch een andere forwarder gebruiken. Onder andere gebruik ik de forwarders van Google en Cloudflare. Ook worden er aan de hand van testen om het uur de configuratie van de DNS server getest.

Forwarders          |  Monitoring
:-------------------------:|:-------------------------:
<img src="Portfolio\IMG\Forwarders.png" alt="Trulli" style="width:100%" /><figcaption align = "center"><b>Fig.10 - DNS Server Forwarders</b></figcaption>|  <img src="Portfolio\IMG\DNS Monitoring.png" alt="Trulli" style="width:100%" /><figcaption align = "center"><b>Fig.11 - DNS Server Monitoring</b></figcaption>


<!--  DHCP BIJREGELEN ENZO EN FGOTO -->



De DHCP role zal ook op deze server staan. Deze zal ip addressen uitdelen aan alle clients in de opstelling. De servers krijgen allemaal een statisch addres. De clients binnen het netwerk krijgen een dynamisch address in de range van 192.168.22.101-150/24. De DHCP server zal ook de nodige dns servers en default gateways meegeven aan de clients.

De Certification Authority (CA) zal digitale certificaten geven aan alle devices. Deze gaan helpen bij het veilig communiceren tussen de verschillende devices. De CA zal ook een certificaat geven aan de DC server zodat deze kan communiceren met de andere server's, ook zal de CA een certificaat geven aan de IIS server om de website te kunnen hosten met HTTPS. 

De Routing and remote access role zal ook geinstalleerd zijn op deze server. Deze zal de internet voorzien voor de hele omgeving. Het zal van de NAT adapter die aan de DC hangt network address translation doen met het internal network. Zo zullen alle server's die enkel een internal network adapter hebben ook voorzien zijn van een veilige verbinding met het internet. 

## SQL-Server

De SQL-Server zal enkel een command line interface hebben. Deze zal beschikken over 1 cores met 4gb ram en de windows server 2019 64 bit operating systeem zal er op geinstalleerd zijn. De server zal ook beschikken over een 15gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De complete domeinnaam van deze server zal `sql.ws2-2223-victor.hogent` zijn.

Op deze server zal enkel de SQL server draaien. De installatie is te vinden op de Website van Microsoft. Deze wordt gescheiden van andere roles zodat mensen met toegang tot deze server enkel deze server kunnen beheren zonder impact te hebben op andere services. 

Er zal een database aangemaakt worden met de naam `WS2-2223-Victor`. Deze zal een aparte service account hebben. Deze service account zal enkel de nodige rechten hebben om de database te kunnen beheren. De database zal ook een aparte gebruiker hebben die enkel de nodige rechten heeft om de database te kunnen gebruiken. 

De secundaire DNS zal op deze server komen om te functioneren als redundante DNS. Deze zal dus ook de nodige forward en reverse lookup zones voorzien. Secundaire servers kunnen ook worden gebruikt om DNS-queryverkeer te ontlasten in delen van het netwerk waar een zone zwaar wordt bevraagd. Als een primaire server niet beschikbaar is, kan een secundaire server bovendien dezelfde naamomzettingsservice bieden voor de gehoste zone terwijl de primaire server beschikbaar is.

Als u een secundaire server toevoegt, is een ontwerpoptie om de server zo dicht mogelijk bij clients te plaatsen die veel behoefte hebben aan hostnaamomzetting. U kunt ook overwegen om secundaire servers op externe subnetten te plaatsen die zijn verbonden via langzamere of onbetrouwbare WAN-koppelingen.

## Exchange-Server

De Exchange-Server zal enkel een command line interface hebben. Deze zal beschikken over 4 cores met 10gb ram en de windows server 2019 64 bit operating systeem zal er op geinstalleerd zijn. De server zal ook beschikken over een 45gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De complete domeinnaam van deze server zal `exchange.ws2-2223-victor.hogent` zijn.

Aan de hand van de verkregen ISO van exchange zal de mailserver geinstalleerd worden. Deze zal een aparte service account hebben. Deze service account zal enkel de nodige rechten hebben om de mailserver te kunnen beheren. De mailserver zal ook een aparte gebruiker hebben die enkel de nodige rechten heeft om de mailserver te kunnen gebruiken.

Het zou moeten mogelijk zijn om de management webpagina van de mailserver te kunnen bezoeken via de browser op de domeincontroller die wel beschikt over een gui. De webpagina zal enkel toegankelijk zijn voor de gebruikers die toegang hebben tot de mailserver.

## IIS-Server

De IIS Server met andere woorden de webserver van de organisatie zal enkel een command line interface hebben. Deze zal beschikken over 1 cores met 2gb ram. De server zal ook beschikken over een 15gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De complete domeinnaam van deze server zal `web.ws2-2223-victor.hogent` of `www.ws2-2223-victor.hogent` zijn. 

De website van het domein zal bereikbaar zijn over heel het internal network maar enkel met https. De IIS role staat op een aparte server omdat alle users kunnen verbinden met deze server. Om het risico's op problemen door aanvallen of inbraak op de website te verminderen zal de IIS service op een aparte server geinstalleerd staan.

## Client

De client zal een gewone installatie van windows 10 zijn die een user heeft in het domein waarmee hij kan inloggen, mogelijks zijn er ook shared folder die toegankelijk zijn voor de user. De client zal ook een virtuele harde schijf hebben van 45gb. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De Client krijgt een ip address van de DHCP server.

alles van stappen dak doe  noteren hier


(virtual iso/usb met scripts op om zo te laten runnen.) test

New-SmbShare -Path C:\Users\Administrator.WS2-2223-VICTOR\Documents\ -Name "Shared Folder2" -FullAccess  "WS2-2223-VICTOR\Victor","WS2-2223-VICTOR\Administrator"
