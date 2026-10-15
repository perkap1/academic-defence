# v0.029.1 – Brodekning
- Fjernet forgrunnsutsnittet som også skjulte elever i skyggen foran broen.
- Map3 definerer nå en eksplisitt dekningssone (x850–1000, y335–450), kun for bakkeelever på LowerPath. Synlighet oppdateres sammen med ruteposisjonen.
- Piloter unntas fra dekningen, flyr synlig over broen og beholder eksisterende book-targeting.
- Targeting og Knowledge avviser elever under broen. Dette gjelder Book, Science/AoE, assistants og prosjektiler som allerede er på vei. Bookworm mister ikke skjold der. Snack beholder spise-mekanikken i tillegg til brodekning.
- test_bridge_cover:34kontroller,0feil; skygge, bro, utgang, alle5fiendetyper, direkte treff og skjold.
- test_bookworm_combat, test_map3_replacement, test_snack_combat, test_v023 og test_v019 bestod.
- test_map3_integration fullfører15waves med normal økonomi. Visuell native kontroll viser bakkeelev i skyggen, skjult elev under broen og pilot over broen.
