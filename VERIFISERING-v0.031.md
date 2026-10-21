# Academic Defence v0.031 — PE Teacher

Ny bygning i eksisterende Godot-prosjekt. Originale vedlagte spriteark er bevart i assets/presentation. Ingen Aseprite eller generert grafikk.

| Egenskap | Nivå 1 | Nivå 2 | Nivå 3 |
|---|---:|---:|---:|
| Bygg / oppgradering, KP | 150 | 180 | 300 |
| Knowledge per elev | 60 | 80 | 100 |
| Angrepsintervall, sekunder | 4,0 | 3,8 | 3,6 |
| Rekkevidde | 230 | 230 | 230 |
| Rulleavstand | 120 | 175 | 240 |
| Ballstørrelse | 100 % | 115 % | 135 % |

Medisinballen slippes etter 0,6 sekunds forberedelse, flyr i 0,55 sekund og ruller i rutens retning med 300 enheter/sekund. Treff samples langs den buede ruten, slik at lange frames ikke kutter hjørner. Hver elev treffes maksimalt én gang per ball. Identiske felles veisegmenter tillater treff på elever fra begge innganger; separate veier forblir adskilt. Den godkjente støvsekvensen avslutter ballen uten ekstra Knowledge.

Veinære plasser kontrolleres både mot live Path2D-geometri (maks 110 enheter fra sentrum) og kartspesifikke korridorer gjennomgått mot originalgrafikken. Samme sjekk brukes av meny og byggelogikk. Alle blokkerte plasser må fortsatt ryddes.

Statistikk bruker faktisk gitt Knowledge, fullførte elever, baller, gyldige treff og rekord per ball. En ball beholder nivået den ble kastet fra for statistikk også etter oppgradering eller salg. Total investering på nivå 3 er 630 KP, salgsrefusjon 315 KP.

Verifisering 20. oktober 2026:

- Hele regresjonskjøringen: 51 testpakker bestått, inkludert komplette baner 1–5.
- Egen PE-test dekker bygging, priser, nivåer, alle tolv inngangsruter, svinger, veislutt, engangstreff, skjold, Snack Break, klovn, piloter, brodekning, KP, statistikk og oppgraderingsdialog.
- Visuell kontroll av alle ni positurer i begge retninger, fast base og ballkasse, nivåbanner og meny.
- Uavhengig gjennomgang fant én feil i speiling av klippemasken; rettet og kontrollert.
- Web-eksport og nettleserstart bestått. Lokal bygging, spilt wave, statistikkpanel og nettleserlogg kontrollert.

Lokal test: http://127.0.0.1:8765/?v=0.031

Ingen endringer i eksisterende fiendebalanse, waves eller økonomi. Denne leveransen er lokal.
