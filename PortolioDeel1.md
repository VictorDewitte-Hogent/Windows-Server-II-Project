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

De server zal beschikken over 2 cores met 4gb ram en de windows server 2019 64 bit operating systeem zal er op geinstalleerd zijn met de desktop expierence (dus met een grafische interface). De server zal ook beschikken over een 35gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De complete domeinnaam van deze server zal `dc.ws2-2223-victor.hogent` zijn.
De server heeft ook 2 network interface's:
- 1 voor het interne netwerk, die een statisch ip adres heeft in de range van het interne netwerk : 192.168.22.1
- 1 voor de NAT verbinding die heel de omgeving zal voorzien van een verbinding met het internet. Deze interface heeft een dynamisch ip adres die hij krijgt van de DHCP server van Virtualbox.

De Active Directory Domain Services (AD DS) zal geinstalleerd zijn op de DomeinController. Deze zal de domeinnaam `"WS2-2223-Victor.hogent"` hebben. De Active Directory zal een apart service account voorzien voor elke applicatie die op de server's draait. De service accounts zullen een random password hebben. Ook zal het de nodige accounts hebben voor gewone gebruikers en mensen die mogelijkse toegang hebben tot de sql server maar geen data kunnen aanpassen. Met andere woorden de correcte Orginaizational Units en Group Policies zullen aanwezig zijn binnen het domein.

De DNS Server zal automatisch geconfigureerd worden door de AD DS, de nodige ldap records zullen dus automatisch gegenereerd worden. De DNS server zal ook de nodige reverse lookup zones voorzien. De DNS server zal ook de nodige forward lookup zones voorzien. De forwarders van de dns server zullen ingesteld worden op die van google.

De DHCP role zal ook op deze server staan. Deze zal ip addressen uitdelen aan alle clients in de opstelling. De servers krijgen allemaal een statisch addres. De clients binnen het netwerk krijgen een dynamisch address in de range van 192.168.22.101-150/24. De DHCP server zal ook de nodige dns servers en default gateways meegeven aan de clients.

De Certification Authority (CA) zal digitale certificaten geven aan alle devices. Deze gaan helpen bij het veilig communiceren tussen de verschillende devices. De CA zal ook een certificaat geven aan de DC server zodat deze kan communiceren met de andere server's, ook zal de CA een certificaat geven aan de IIS server om de website te kunnen hosten met HTTPS. 

De Routing and remote access role zal ook geinstalleerd zijn op deze server. Deze zal de internet voorzien voor de hele omgeving. Het zal van de NAT adapter die aan de DC hangt network address translation doen met het internal network. Zo zullen alle server's die enkel een internal network adapter hebben ook voorzien zijn van een veilige verbinding met het internet. 

## SQL-Server

De SQL-Server zal enkel een command line interface hebben. Deze zal beschikken over 1 cores met 4gb ram en de windows server 2019 64 bit operating systeem zal er op geinstalleerd zijn. De server zal ook beschikken over een 15gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De complete domeinnaam van deze server zal `sql.ws2-2223-victor.hogent` zijn.

Op deze server zal enkel de SQL server draaien. De installatie is te vinden op de Website van Microsoft. Deze wordt gescheiden van andere roles zodat mensen met toegang tot deze server enkel deze server kunnen beheren zonder impact te hebben op andere services. 

Er zal een database aangemaakt worden met de naam `WS2-2223-Victor`. Deze zal een aparte service account hebben. Deze service account zal enkel de nodige rechten hebben om de database te kunnen beheren. De database zal ook een aparte gebruiker hebben die enkel de nodige rechten heeft om de database te kunnen gebruiken. 


## Exchange-Server

De Exchange-Server zal enkel een command line interface hebben. Deze zal beschikken over 4 cores met 10gb ram en de windows server 2019 64 bit operating systeem zal er op geinstalleerd zijn. De server zal ook beschikken over een 45gb virtuele harde schijf bevatten. Deze is dynamisch gealloceerd zodat hij enkel de nodige ruimte inneemt op je host machine. De complete domeinnaam van deze server zal `exchange.ws2-2223-victor.hogent` zijn.

Aan de hand van de verkregen ISO van exchange zal de mailserver geinstalleerd worden. Deze zal een aparte service account hebben. Deze service account zal enkel de nodige rechten hebben om de mailserver te kunnen beheren. De mailserver zal ook een aparte gebruiker hebben die enkel de nodige rechten heeft om de mailserver te kunnen gebruiken.



