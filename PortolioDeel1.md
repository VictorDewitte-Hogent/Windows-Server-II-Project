# Portfolio Windows Server II: Victor Dewitte

switch when u can route when u must

- Management server met gui, 2 cores, 4gb ram. 2Max users at one perticular time. 
- DC server zonder gui, Aparte service accounts voor elke applicatie, Randomize passwords functie, Service accounts backup applicatie, DNS, DHCP, CA. 2 cores, 4gb ram, Router role op de dc met NAT.
- Sql server zonder gui, Windows security only, 1 core 4gb ram , min 6gb hard disk
- Exchange zonder gui, Imap voor ms mail , 4 cores, 10gb ram, min 30+gb hard disk
- IIS server zonder gui, 1 core, 2gb ram. security appart.

## DomeinController-Server

Op de domeincontroller server met een gui zullen volgende services draaien:
 - AD DS 
 - DNS
 - DHCP
 - CA
 - Router role met NAT

De server zal beschikken over 2 cores met 4gb ram.

De server zal een aparte service account hebben voor elke applicatie die op de server draait. De service accounts zullen een random password hebben. 
 

