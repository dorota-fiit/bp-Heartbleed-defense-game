# bp-Heartbleed-defense-game
Repozitár obsahuje všetky potrebné súbory pre spustenie bezpečnostnej hry typu Capture the Flag (Defend-only) k bakalárskej práci Bezpečnosť protokolu SSL/TLS. Hra demonštruje závažnosť chyby Heartbleed. Virtuálne prostredie bude zahŕňať tri stroje - počítač útočníka (IP adresa 10.10.20.2), používateľa (IP adresa 10.10.20.4) a server (IP adresa 10.10.20.3). Stroje sú usporiadané podľa topológie v súbore **defense_topology.png** a vybavené operačnými systémemi Kali Linux a Ubuntu. Cieľový stroj disponuje zraniteľnou verziou knižnice OpenSSL (zraniteľné verzie sú od 1.0.1 do 1.0.1f).
## Zraniteľnosť Heartbleed 
Heartbleed zraniteľnosť (CVE-2014-0160) umožňuje útočníkovi získavať dáta zo vzdialeného servera.
....
## Zadanie
Keďže ide o hru typu CTF (Capture the Flag), hráč má za úlohu ochrániť vlajku pred útočníkom. Vlajka je umiestnená v správe, ktorá bude po 15 minútach odoslaná v rámci automatizovanej interakcie používateľa na sociálnej sieti (https://www.heartbleedlabelgg.com) na zraniteľný server. Hráč - obranca má za úlohu dovtedy zabezpečiť server a nastaviť firewall tak aby bola IP adresa útočníka zablokovaná. Zabezpečenie servera zahŕňa odstránenie zranteľnej verzie OpenSSL 1.0.1 a nainštalovanie zabezpečenej verzie 1.0.1g. Obranca bude mať túto verziu k dispozícii v priečinku **/home/seed/**. IP adresu útočníka bude môcť hráč identifikovať aj na základe automatizovaných opakovaných útokov pomocou nástroja Wireshark. Pokiaľ hráč úspešne zabezpečí server, vlajku nájde po uplynutí času na ploche v súbore **result.txt**. Pred nastavením prostredia a inštaláciou si odporúčam prečítať najprv celý návod. Riešenie obsahuje všetky kroky potrebné na úspešne získanie vlajky.

## Prostredie a inštalácia
Hra je spustiteľná v prostredí nástroja KYPO Cyber Sandbox Creator. Pri inštalácii nástroja prosím postupujte podľa nasledujúceho návodu -  https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator/-/wikis/3.0/Installation. 

## Riešenie

## Zdroje
https://web.ecs.syr.edu/~wedu/seed/Labs_12.04/Networking/Heartbleed/
