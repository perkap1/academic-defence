# Academic Defence v0.031.1

- PE Teacher ruller nå 240 / 350 / 480 enheter på nivå 1 / 2 / 3, nøyaktig dobbelt så langt som i v0.031. Knowledge, hastighet, størrelse og priser er uendret.
- Testmodus slås på eller av i verdenskartet. Nye runder på alle fem baner starter med 2000 KP når den er på, ellers normale 200 KP. Valget lagres og huskes ved retur og omstart. UI-oppdateringer fyller ikke på KP under en runde.
- Aktiv testmodus merkes i HUD. Bytte av modus påvirker ikke lagrede stjerner eller opplåsinger. Øvrige regler er uendret.

Verifisert 20. oktober 2026: 34 testmoduskontroller og 335 PE-kontroller bestått. Regresjoner for grunnregler (14), progresjon (10), stjerner/Science (183), økonomi (92) og wave-preview (4497) bestått. Totalt 5165 kontroller i denne kjøringen.

Web-eksport bestått. I nettleseren er begge moduser slått på/av og ny bane kontrollert med henholdsvis 2000 og 200 KP. Ingen feil i nettleserloggen.

Lokal test: http://127.0.0.1:8765/?v=0.031.1
