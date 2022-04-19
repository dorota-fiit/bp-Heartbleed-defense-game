# bp-Heartbleed-defense-game
Repozitár obsahuje všetky potrebné súbory pre spustenie bezpečnostnej hry typu Capture the Flag (Defend-only) k bakalárskej práci Bezpečnosť protokolu SSL/TLS. Hra demonštruje závažnosť chyby Heartbleed. Virtuálne prostredie bude zahŕňať tri stroje - počítač útočníka (IP adresa 10.10.20.2), používateľa (IP adresa 10.10.20.4) a server (IP adresa 10.10.20.3). Stroje sú usporiadané podľa topológie v súbore **defense_topology.png** a vybavené operačnými systémemi Kali Linux a Ubuntu. Cieľový stroj disponuje zraniteľnou verziou knižnice OpenSSL (zraniteľné verzie sú od 1.0.1 do 1.0.1f).
## Zraniteľnosť Heartbleed 
Heartbleed zraniteľnosť (CVE-2014-0160) umožňuje útočníkovi získavať dáta zo vzdialeného servera.
....
## Zadanie
Keďže ide o hru Defend-only, hráč má za úlohu ochrániť údaje (vlajku) pred útočníkom. Údaje sú vo forme správy, ktorá bude po 15 minútach odoslaná v rámci automatizovanej interakcie používateľa na zraniteľný server. Hráč - obranca musí zabezpečiť server a nastaviť firewall (napríklad pomocou UFW) tak aby bola IP adresa útočníka zablokovaná. Zabezpečenie servera zahŕňa odstránenie zranteľnej verzie OpenSSL 1.0.1 a nainštalovanie zabezpečenej verzie 1.0.1g. Obranca bude mať túto verziu k dispozícii v priečinku **/home/seed/**. IP adresu útočníka a priebeh útoku bude môcť hráč identifikovať pomocou nástroja Wireshark. Po uplynutí času vyhradeného na vykonanie úloh sa spustí kontrola stavu zabezpečenia. Pri splnení úloh sa hra končí úspešne. Pred nastavením prostredia a inštaláciou si odporúčam prečítať vopred celý návod. Riešenie obsahuje všetky kroky potrebné na vykonanie obranných úloh.

## Prostredie a inštalácia
Hra je spustiteľná v prostredí nástroja KYPO Cyber Sandbox Creator. Pri inštalácii nástroja prosím postupujte podľa nasledujúceho návodu -  https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator/-/wikis/3.0/Installation. 

Po nainštalovaní prostredia si stiahnite repozitár do Vášho počítača. Obsah správy používateľa je prednastavený na hodnotu "Insert body of the message here." a pred vytváraním strojov je možné ho zmeniť podľa Vašich požiadaviek v súbore **muni-kypo_vms/user/interaction.py**. Následne v termináli prejdite do priečinku **vagrant_server** a zadajte príkaz `vagrant up`. Týmto príkazom sa Vám vo VirtualBoxe vytvorí virtuálny stroj servera, ktorý budete mať za úlohu zabezpečiť. Dôležité je vytvoriť aj zvyšné virtuálne stroje - počítač útočníka a používateľa. Prejdite do priečinka **muni-kypo_vms** a zadajte príkaz `create-sandbox --provisioning-dir .\provisioning defense_topology.yml`, ktorý vytvorí prechodnú definíciu sandboxu (priečinok **sandbox**). Následne prejdite do priečinku **sandbox** a zadajte príkaz na vytvorenie virtuálnych strojov - `manage-sandbox build`. Vo VirtualBoxe sa postupne vytvoria stroje: router, attacker a user. Po ich vytvorení sa spustia časovače na opakovane spúšťaný automatizovaný útok a interakciu používateľa. Automatizovaný útok bude spustený po 2 minútach a bude prebiehať pravidelne počas celej hry. Interakcia používateľa na sociálnej sieti prebehne po 15 minútach. Do zraniteľného servera sa príhlaste pod menom "seed" s heslom "dees". 

## Riešenie 
1. Otvorte terminál a zadajte príkaz `sudo apt-get purge openssl`, ktorý odstráni predošlú verziu. Binárny súbor **openssl** môže byť nutné odstrániť aj dodatočne príkazom `sudo rm /usr/bin/openssl`.
2. Následne odstráňte balíky stiahnuté ako závislosti príkazmi `sudo apt-get autoremove` a `sudo apt-get autoclean`.
3. Rozbaľte novú verziu OpenSSL príkazom `tar -zxf /home/seed/openssl-1.0.1g.tar.gz --directory /home/seed/` a prejdite do priečinka príkazom `cd /home/seed/openssl-1.0.1g/`.
4. Pri inštalácii postupujte na základe postupu umiestneného v súbore **/home/seed/openssl-1.0.1g/INSTALL**:\
  4.1 `./config`\
  4.2 `make`\
  4.4 `sudo make install`
5. Po inštalácii vytvorte symbolickú linku z novo nainštalovanej verzie zadaním príkazu `sudo ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl` a nakoniec aktualizujte linky príkazom `sudo ldconfig`.
6. Úspešnú inštaláciu môžte otestovať príkazom `openssl version`. 
7. Otvorte nástroj Wireshark a zapnite zachytávanie premávky pre IP adresu 10.10.20.3. Zachytávanie premávky bude pre Vás užitočné pri identifikácii prebiehajúcich útokov.
8. Vo Wireshark identifikujte útoky a zistite IP adresu útočníka - 10.10.20.2. 
9. Firewall je možné nastaviť viacerými spôsobmi, odporúčam využitie `ufw`:\
  9.1 `sudo ufw deny from 10.10.20.2 to any`\
  9.2 `sudo ufw allow ssh`\
  9.3 `sudo ufw default allow outgoing`\
  9.4 `sudo ufw default deny incoming `\
  9.5 `sudo ufw enable `\
  9.6 `sudo ufw allow https `\
  9.7 `sudo ufw allow http`
10. Funkčnosť firewallu môžte odsledovať vo Wiresharku. 

## Zdroje
https://web.ecs.syr.edu/~wedu/seed/Labs_12.04/Networking/Heartbleed/
