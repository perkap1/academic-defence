# Academic Defence v0.002 – verifikasjon

Dato: 2. oktober 2026. Motor: Godot **4.4.1 stable**, GDScript og OpenGL-kompatibilitetsrenderer. Webeksport: enkelttrådet Godot WebAssembly, uten krav om SharedArrayBuffer.

## Automatiske tester

- Grunnregler: **14 kontroller, 0 feil**.
- Blackboard, PE-varianter, felles kunnskapssystem og bølgefordeling: **79 kontroller, 0 feil**.
- Hele spillrunden, seier/tap, tidlig tapsstopp og reset: **30 kontroller, 0 feil**.
- Faktisk grafisk input, World Map-låser, battle-overgang, byggemeny, begge byggetyper, deaktivert knapp, pause/fortsett, reset, resize og retur: **29 kontroller, 0 feil**.

Den blandede strategitesten brukte vanlig startbudsjett, bygde først Book Towers og reinvesterte i både Book og Blackboard mellom bølgene. Den vant etter bølge 7 med **9 omdømme, 79 studenter opplært og 1 sluppet gjennom**. Alle 80 studentene ble registrert nøyaktig én gang. En runde uten tårn tapte under bølge 2.

## Visuell kontroll

Blackboard-rammer bruker samme utsnittstørrelse, skala og sokkelanker. PE-rammer bruker samme skala og fotanker for hver retning. Ingen animasjon endrer enhetens posisjon; PathFollow2D driver framdriften.

De originale UI-rammene og ikonene brukes i HUD, byggemeny, info og handlingsknapper. En størrelsesfeil i TextureRect ble først reprodusert av en ny test og deretter rettet. Renderte bilder av World Map, byggemeny og blandet gameplay er visuelt kontrollert. Klikk ble også kontrollert etter vindusendring.

En uavhengig kodegjennomgang fant ingen alvorlige problemer i gameplay, pause, student/prosjektil-livsløp, sceneoverganger eller level select. Gjennomgangen påpekte at eksportmalene lå utenfor prosjektet; malene er nå inkludert i prosjektet, og preset bruker interne stier.

## Web

Prosjektet er eksportert med Godot til `AcademicDefence-Web/index.html`, `.pck`, `.js` og `.wasm`. Den lokale serveren lytter kun på **127.0.0.1:8765**.

Den ferdige prosjektpakken er pakket ut i en separat kontrollmappe, importert og eksportert på nytt med de inkluderte eksportmalene uten feil. Begge ZIP-pakkene er kontrollert for CRC-feil.

Den faktiske eksporten er åpnet i den innebygde Chromium-nettleseren. Kontrollert med brukerklikk: World Map ved oppstart, ingen overgang ved låst node, bane 1 åpnes, byggemeny med begge tårn, Blackboard bygges for 100 KP, Book bygges for 70 KP, korrekt inaktiv knapp ved manglende poeng, bølgestart, bevegelige studenter og bølgebelønning. En restart-pil manglet glyph i web og er erstattet med den lesbare teksten **Ny**.

Alle sju bølger, seier og tap er simulert gjennom de samme produksjonsskriptene i Godot; de er ikke manuelt gjennomspilt i nettleseren. Dette er fortsatt en prototype uten lyd og bred spillertesting av vanskelighetsgraden.

PE-gutt, PE-jente, kunnskapsstolper og pausemeny er også visuelt kontrollert i webversjonen under bølge 4.
