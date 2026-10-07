# Academic Defence v0.010 — økonomibygninger

## Kontrollert
- Eksisterende prosjekt, begge baner og uendret kampsystem.
- Study Hall 100 KP, inntekt15; én eksklusiv gren120.
- Library45, Scholarship10 +5 per graduation innen260radius, cap50 og én global bonus, Research15→25→35→45→55→65.
- Scholarship-telleren nullstilles ved neste bølgestart. Dette følger det eksplisitte kravet i Scholarship-avsnittet; forrige bølges sum forblir lesbar mellom bølgene.
- Sell50% total investering, ingen inntekt etter salg.
- Original PNG brukes direkte i Godot med atlas-regioner, felles pivot, fire idleframes ved3FPS og aktivframe0.45sekunder; statisk steinbase og nearest filtering.
- 3,310 headless checks, 92 nye grafiske checks og54 eksisterende upgrade-UI-checks: 0 feil.
- Uavhengig kildekodegjennomgang: ingen vesentlige funn.
- Lokal webexport vellykket. Nettlesertest: verdenskart, Map1, kjøp, banner, graduation, fullført bølge/passivinntekt, salg og Scholarship-spesialisering/radius. Ingen konsollfeil.

Lokal spill-lenke: http://127.0.0.1:8765/?v=0.010
