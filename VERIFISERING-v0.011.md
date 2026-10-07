# Academic Defence v0.011 — Map 3 og The Bookworm

Eksisterende prosjekt videreført, Godot 4.4.1. Ingen Aseprite-endringer.

## Verifisert lokalt

- 3 450 headless-kontroller, 0 feil: de 16 eksisterende testene (3 310), Bookworm (17), Map 3 (64), Bookworm combat (17), progression (10), Map 3 full round (32).
- Bane 1 og 2 fullført med eksisterende budsjettester; geometri og bølger beholdt.
- Map 3: begge innganger i alle bølger, 14 byggeplasser, nøyaktig 15 foreslåtte bølger. 355 studenter avsluttes én gang hver. Vanlig startbudsjett 200 KP/10 Reputation; teststrategien bygger og oppgraderer mellom bølger, vinner med 347 graduates og 2 Reputation.
- Bokskjold: tre positive treff fjerner tre bøker uten Knowledge. Treffet etterpå underviser normalt. Sterke/Golden treff, Blackboard AoE og Assistant-ticks følger samme regel. Slow passerer skjoldet, undervisning stopper eleven, og bevegelse fortsetter etterpå. Graduation gir vanlig belønning.
- Opplåsing etter Map 2-seier, korrekt låst/åpen knapp på verdenskartet, én gangs introduksjon og save/reload. Tester bruker isolert testfil og endrer ikke spillerens lagring.
- 74 grafiske kontroller med ekte museinput: alle 14 byggeplasser åpner radialmeny, bygger, velger og selger; bølge 4 starter; introduksjon og tre hit-reaksjoner med fire frames hver vises.
- Alle 72 Bookworm-poser og begge ruter rendret og visuelt kontrollert. Arkets fargede rammer er ekskludert; samme sprite-skala/canvas og world position gjennom skjoldskifter. Ekstra byggeplasser flyttet til (1148,393) og (1148,550) etter kontroll av kartet.
- Uavhengig kodegjennomgang: ingen Critical/Important funn.
- Web-export exit 0: index.html, index.js, index.wasm og index.pck eksportert sammen. Lokal nettlesertest viser v0.011, verdenskart med låst Map 3, Map 2, radialmeny, bygging og bølgestart; ingen console errors/warnings i denne testen.

## Publisering

Eksisterende main-branch og GitHub Pages-workflow beholdt. De fem nye headless-testene er lagt til før automatisk export/deploy. Eksporten bruker unike asset-URL-er per commit for å unngå gammel cache.

Map 3 og Bookworm er testet i Godot. Nettlesertesten dekker oppstart, meny, assets og input; en full 15-bølgers Map 3-runde er kjørt i den automatiserte Godot-testen.
