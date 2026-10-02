# Academic Defence v0.003 – verifikasjon

Dato: 2. oktober 2026. Godot 4.4.1 stable. Bygger på det bevarte v0.002-arkivet.

## Tester

| Test | Kontroller | Feil |
|---|---:|---:|
| Grunnregler | 14 | 0 |
| Blackboard og PE-regresjon v0.002 | 79 | 0 |
| Bane 1 komplett spillrunde | 30 | 0 |
| Slow, salg, selection og Map2-profil | 106 | 0 |
| Bane 2 komplett spillrunde | 30 | 0 |
| Grafiske brukerklikk på bane1 | 28 | 0 |
| Grafiske brukerklikk på bane2 | 28 | 0 |
| **Totalt** | **315** | **0** |

De nye funksjonstestene feilet først på manglende slow, salg, selection og bane2 og bestod etter implementeringen. Grafisk kontroll avdekket at kartets malte sirkel ble synlig under bygget tårn. En pikseltest reproduserte feilen, og et fast underlag dekker nå markøren også når plassen er opptatt.

## Bane 2

Egen map2.tscn / main_map2.tscn, med brukerens kart uendret. Åtte byggeplasser står på sirklene. Tomme plasser har radius44 mot tidligere30, samme størrelse og faste posisjoner gjennom hover, bygging, valg og salg. En separat tegning av den bakte Path2D-kurven er visuelt kontrollert mot midten av veien gjennom alle svingene.

De tolv bølgene følger masterpromptens studentfordeling, totalt218 studenter. Spawnintervallet faller fra1,8 til0,75 sekunder. En blandet strategi på vanlig200KP startbudsjett vant alle12 med8omdømme,216opplærte og2sluppet gjennom. Bane1 vant med9omdømme og79opplærte; dens sju bølger er beholdt. Begge baner taper korrekt uten tårn.

## Blackboard, salg og selection

AoE gir15kunnskap til alle i radius105 rundt målet, med0,70 av opprinnelig fart i2sekunder. Normal/PE-gutt/PE-jente er kontrollert for faktisk bevegelseslengde, fornyelse uten stacking og riktig fart ved utløp, også når et langt tidssteg krysser utløpet. Pause fryser både fartens varighet og framdrift. Berørte studenter får en blå ring; undervisningspulsen bruker eksisterende Godot-tegning.

Book gir35KP tilbake og Blackboard50KP. Salg frigjør plassen før ressursoppdateringen og fjerner tårnet fra scenen, slik at gjentatte klikk ikke betaler igjen. Gjenbygging, ugyldig plass og avsluttet runde er testet. Eksisterende kunnskapsprosjektiler beholder sin egen levetid.

Main eier ett tower selection. Klikk på tårnkunst eller sokkel viser range og SELL. Bakken, annen plass, annet tårn og pause fjerner det gamle valget. Hover kan ikke vise ekstra range-sirkler. Bygging, salg og valg er også kontrollert etter endret vindusstørrelse.

## Web og gjennomgang

Ferdig Godot Web-eksport er åpnet i den innebygde Chromium-nettleseren via127.0.0.1:8765. Brukerklikk bekreftet node2, åtte plasser,0/12visning, bygging av begge typer,35/50refusjon, gjenbygging og bakke-deselection. De første to bølgene ble spilt i web med tårn; wave reward, opplæring og pause fungerte. Alle tolv bølger og seier/tap er verifisert gjennom produksjonsskriptene i Godot, ikke manuelt gjennomspilt i nettleseren.

En uavhengig, skrivebeskyttet gjennomgang sammenlignet produksjonsendringene medv0.002. Ingen ytterligere feil ble funnet i slow, transaksjoner, projectiles, input, pause eller kartoverganger. Den synlige markørfeilen ble rettet og verifisert etterpå.

Webserveren er lokal på denne PC-en. Start web.cmd kan starte den igjen senere. Prosjektpakken inneholder de offisielle4.4.1webmalene og tester; ZIP-integritet kontrolleres ved pakking. Vanskelighetsgraden er testet med konkrete strategier, men er fortsatt prototypens balanse og har ikke bred spillertesting.

Det ferdige prosjektarkivet er også pakket ut i en egen kontrollmappe, importert og eksportert på nytt med de inkluderte webmalene. Begge operasjonene fullførte uten feil eller advarsler. Begge leveransearkivene bestod ZIP CRC-kontroll.
