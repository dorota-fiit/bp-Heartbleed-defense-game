# bp-Heartbleed-defense-game
Repozitár obsahuje všetky potrebné súbory pre spustenie bezpečnostnej hry typu Capture the Flag (Defend-only) k bakalárskej práci Bezpečnosť protokolu SSL/TLS. Hra demonštruje závažnosť chyby Heartbleed. Virtuálne prostredie bude zahŕňať tri stroje - počítač útočníka, používateľa (IP adresa 10.10.20.4) a server (IP adresa 10.10.20.3). Stroje sú usporiadané podľa topológie v súbore **defense_topology.png** a vybavené operačnými systémemi Kali Linux a Ubuntu. Cieľový stroj disponuje zraniteľnou verziou knižnice OpenSSL (zraniteľné verzie sú od 1.0.1 do 1.0.1f).

<p align="center">
  <img src="https://github.com/dorota-fiit/bp-Heartbleed-defense-game/blob/main/defense_topology.png" width="420px">
</p>

## Zraniteľnosť Heartbleed 
Heartbleed je implementačná chyba SSL/TLS heartbeat rozšírenia v rámci OpenSSL a umožňuje útočníkovi získavať dáta zo vzdialeného servera, pričom ukradnuté dáta môžu zahŕňať napríklad používateľské mená, heslá alebo platobné údaje. SSL/TLS protokol slúži na vytvorenie bezpečného komunikačného kanálu medzi aplikáciami. Kvôli výpočtovým postupom ako šifrovanie a dešifrovanie verejného kľúča alebo výmena kľúčov je vytvorenie nového kanálu pomerne nákladné. Aj napriek tomu, ak server a klient nekomunikujú, kanál medzi nimi sa po určitom čase preruší a spojenie musí byť pri ďalšej komunikácii opätovne nadviazané. S cieľom minimalizovať náklady bolo implementované riešenie prostredníctvom rozšírenia heartbeat.  Heartbeat poskytuje nový protokol implementujúci keep-alive funkcionalitu protokolu SSL/TLS.

Prvým krokom v rámci tejto funkcionality je odoslanie Heartbeat paketu, nazývaného žiadosť, príjemcovi. Po prijatí prijímateľ skonštruuje paket predstavujúci odpoveď a odošle ho odosielateľovi. Správa HeartbeatResponse by mala niesť obsah zhodný so žiadosťou a svoju vlastnú náhodnú výplň. Zraniteľnosť je spôsobená kódom, ktorý nesprávne validuje vstupy pri kopírovaní dát z privátnej pamäte do odchádzajúceho paketu. Obsah žiadosti sa kopíruje do paketu odpovede, no veľkosť kopírovaného obsahu nie je určená jeho reálnou veľkosťou, ale veľkosťou zadanou odosielateľom. memcpy() teda skopíruje viac dát do paketu odpovedi ako je v pakete žiadosti. Začne kopírovaním obsahu paketu žiadosti, no postupne prekročí hranicu obsahu a začne kopírovať aj dáta uchovávané v pamäti nad ním. Práve táto pamäť môže obsahovať senzitívne používateľské informácie. Získané informácie sa spolu s obsahom prekopírujú do paketu odpovede a sú odoslané v HeartbeatResponse útočníkovi. Útočníkovi to umožňuje čítať dáta uložené v privátnej pamäti, ktoré mohli potenciálne zahŕňať aj dáta prenášané bezpečným kanálom a kryptografické tajomstvá.

<p align="center">
  <img src="https://github.com/dorota-fiit/bp-Heartbleed-defense-game/blob/main/heartbleed_attack.PNG" width="800px">
</p>

## Zadanie
Keďže ide o hru Defend-only, hráč má za úlohu ochrániť používateľove údaje (vlajku) pred útočníkom. Údaje sú vo forme správy, ktorá bude po 30 minútach odoslaná v rámci automatizovanej interakcie používateľa na zraniteľný server. Hráč - obranca musí zabezpečiť server a nastaviť firewall (napríklad pomocou UFW) tak aby bola IP adresa útočníka zablokovaná. Zabezpečenie servera zahŕňa odstránenie zraniteľnej verzie OpenSSL 1.0.1 a jej závislostí, rozbalenie novej verzie 1.0.1g, jej manuálne nainštalovanie (**home/seed/openssl-1.0.1g/INSTALL**) a vytvorenie symbolickej linky. Obranca bude mať túto verziu k dispozícii v priečinku **/home/seed/**. Hráč bude musieť v sieti identifikovať IP adresu útočníka. Po uplynutí času vyhradeného na vykonanie úloh sa spustí kontrola stavu zabezpečenia. Pri splnení úloh sa hra končí úspešne. Pred nastavením prostredia a inštaláciou si odporúčam prečítať vopred celý návod. Riešenie obsahuje všetky kroky potrebné na vykonanie obranných úloh.

## Prostredie a inštalácia
Hra je spustiteľná v prostredí nástroja KYPO Cyber Sandbox Creator. Pri inštalácii nástroja prosím postupujte podľa nasledujúceho návodu -  https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator/-/wikis/3.0/Installation. 

Po nainštalovaní prostredia si stiahnite repozitár do Vášho počítača. Obsah vlajky je prednastavený na hodnotu "Insert body of the message here." a pred vytváraním strojov je možné ho zmeniť podľa Vašich požiadaviek v súbore **muni-kypo_vms/user/interaction.py**. Následne  vytvoríme virtuálne stroje - počítač útočníka (Vy) a používateľa. V termináli prejdite do priečinku **muni-kypo_vms** a zadajte príkaz `create-sandbox --provisioning-dir .\provisioning defense_topology.yml`, ktorý vytvorí prechodnú definíciu sandboxu (priečinok **sandbox**). Následne prejdite do priečinku **sandbox** a zadajte príkaz na vytvorenie virtuálnych strojov - `manage-sandbox build`. Vo VirtualBoxe sa postupne vytvoria stroje: router, attacker a user. Dôležité je vytvoriť aj server. Nakoniec v termináli prejdite do priečinku **vagrant_server** a zadajte príkaz `vagrant up`. Týmto príkazom sa Vám vo VirtualBoxe vytvorí virtuálny stroj servera. Pozor! Stroj sa po vytvorení nepripojí do požadovanej siete a pre to je ho nutné reštartovať. Vo VirtualBox okne virtuálneho stroja kliknite v menu na "Machine" a vyberte možnosť "Reset". Stroj musí byť reštartovaný IHNEĎ po vytvorení, keďže sú zapnuté časovače na hru a zabezpečenie. Automatizovaný útok bude spustený po 10 minútach a bude prebiehať pravidelne počas celej hry. Interakcia používateľa na sociálnej sieti prebehne po 30 minútach.

### Možné komplikácie 
Pri vytváraní KYPO virtuálnych strojov sa môže objaviť problém s konfiguráciou. Ide o problém kedy stiahnuté skripty obsahujú Windows EOL znaky namiesto Unix EOL znakov a tak ich virtuálne stroje vybavené operačnými systémami Linux nedokážu prečítať. Jednoduchým riešením je otvorenie skriptov v programe Notepad++ a v menu v sekcii " Edit" zmeniť atribút " EOL Conversion" na " Unix(LF)" . Po upravení skriptov je nutné zničiť aktuálny sandbox a zopakovať postup vytvárania.

## Riešenie 
1. Prihláste sa do zraniteľného servera pod menom "seed" s heslom "dees". 
2. Otvorte terminál a zadajte príkaz, ktorý odstráni predošlú verziu.  Dodatočne odstráňte aj binárny súbor **openssl** v priečinku **/usr/bin/**.
  
    <details><summary>Nápoveda</summary>
    
    ```
      sudo apt-get purge openssl
    ```
    ```
      sudo rm /usr/bin/openssl
    ````
    </details>

3. Odstráňte balíky stiahnuté ako závislosti.\
  `sudo apt-get autoremove`\
  `sudo apt-get autoclean`
4. Rozbaľte novú verziu OpenSSL.\
  `tar -zxf /home/seed/openssl-1.0.1g.tar.gz --directory /home/seed/`
5. Prejdite do priečinka **/home/seed/openssl-1.0.1g/**.\
  `cd /home/seed/openssl-1.0.1g/`
5. Nainštalujte novú verziu OpenSSL. Pri inštalácii postupujte na základe postupu umiestneného v súbore **/home/seed/openssl-1.0.1g/INSTALL**. Potrebné nástroje sú už nainštalované, pokračujte časťou "Quick Start" obsahujúcou 3 príkazy.
  
    <details><summary>Nápoveda</summary>
  
    ```
      ./config 
    ```
    ```
      make 
    ```
    ```
      sudo make install
    ```
  
    </details>

6. Po inštalácii vytvorte symbolickú linku z novo nainštalovanej verzie a aktualizujte linky.\
  `sudo ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl`\
  `sudo ldconfig`
7. Úspešnú inštaláciu môžte otestovať.\
  `openssl version`
8. Pozrite si stroje v sieti a zistite IP adresu útočníka vylúčením známych adries.\
  `sudo nmap -sn 10.10.20.3/24` 
   
    <details><summary>Nápoveda</summary>
    
    IP adresa útočníka: 
    ```
      10.10.20.2
    ```
    
    </details>
    
9. Nastavte firewall tak aby bola IP adresa útočníka zablokovaná. Firewall je možné nastaviť viacerými spôsobmi ako napríklad iptables, odporúčam však využitie `ufw`. Pri využití `ufw` nezabudnite povoliť služby ako ssh, https a http.
  
    <details><summary>Nápoveda</summary>
  
    ```
      sudo ufw deny from 10.10.20.2 to any
    ```
    ```
      sudo ufw allow ssh
    ```
    ```
      sudo ufw allow https
    ```
    ```
      sudo ufw allow http
    ```
    ```
      sudo ufw default allow outgoing
    ```
    ```
      sudo ufw default deny incoming
    ```
    ```
      sudo ufw enable 
    ```
    </details>

## Zdroje
Masaryk University Institute of Computer Science. Cyber Sandbox Creator. 2022. url: https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator/-/wikis/home .

Zakir Durumeric et al. The Matter of Heartbleed. Association for Computing Machinery, 2014. isbn: 9781450332132. doi: 10.1145/2663716.2663755. url: https://urldefense.proofpoint.com/v2/url?u=https-3A__doi.org_10.1145_2663716.2663755&d=DwIFAg&c=jf_iaSHvJObTbx-siA1ZOg&r=19WVqXa7I3kFxIpCAuKguzcCSulPwXh0dReURgQWpyg&m=SMpSbN1j05IjdcUQw4dlOHPsVYDbN8T1WlbMrZ1UVzLHxd9wfcLGAgJB5W1JXh9N&s=lc0KtGngLoLnXqgGJl50Cc4eMCflTatKsdPKWRyXG0M&e= .

Inc. Synopsys. The Heartbleed Bug. 2020. url: https://urldefense.proofpoint.com/v2/url?u=https-3A__heartbleed.com_&d=DwIFAg&c=jf_iaSHvJObTbx-siA1ZOg&r=19WVqXa7I3kFxIpCAuKguzcCSulPwXh0dReURgQWpyg&m=SMpSbN1j05IjdcUQw4dlOHPsVYDbN8T1WlbMrZ1UVzLHxd9wfcLGAgJB5W1JXh9N&s=cwZ3INyuWzzNhtEsE7aNniFwvMriq7MQMXgp2PE7wtM&e= .

Du Wenliang. Computer Internet Security: A Hands-on Approach. Lightning Source Inc., 2019. isbn: 978-1-7330-0393-3. url: https://urldefense.proofpoint.com/v2/url?u=https-3A__www.enbook.sk_&d=DwIFAg&c=jf_iaSHvJObTbx-siA1ZOg&r=19WVqXa7I3kFxIpCAuKguzcCSulPwXh0dReURgQWpyg&m=SMpSbN1j05IjdcUQw4dlOHPsVYDbN8T1WlbMrZ1UVzLHxd9wfcLGAgJB5W1JXh9N&s=hQY6WygJVoOURVIUEmWS2G4QDXvF0OMFeXFrxv1EHgc&e=catalog/product/view/id/4801062?gclid=CjwKCAiAv_KMBhAzEiwAs-rX1GuONVgRMUF5r7JbXU89MGGcvPBl8cl9LP4CrdF92AtAZNcy2EEhvhoCN9wQAvDBwE .
