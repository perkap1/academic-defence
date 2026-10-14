# Academic Defence v0.027

## Endringer
- Vedlagte Wave Warning-frames brukes som fire-frame idle (4 FPS) og egen gyllen hover-pose.
- Varsel står på rutens senterlinje, 80 piksler innenfor synlig inngang.
- Seks vedlagte mini-ikoner brukes med nearest-neighbor, på 16x16 transparente lerreter med figur opptil 12 piksler. UI viser dem i 2x størrelse. Originale kildefiler er bevart uendret og SHA-256 er kontrollert mot vedleggene.
- Hver wave får en bufret spawn-plan med type, PE-variant og inngang. Forhåndsvisning og faktisk spawning bruker samme plan, også senere puljer. Egen variant-RNG påvirker ikke global RNG under forhåndsvisning.
- Panelet beholdes mens musen er over ikon eller panel. Kort overgangstid på 0,15 sekunder tillater flytting mellom dem. Berøring åpner/lukker som før; panelet slipper byggeklikk gjennom.
- Ingen endringer i wave-antall, spawn-timing, ruter, elevstats eller økonomi.

## Kontroll
- test_v027 sammenligner hvert faktisk spawn med forhåndsvisningen på samtlige waves i alle fem baner, inkludert PE Boy/Girl og inngang. Den kontrollerer også senterplassering, alle seks miniteksturer, idle/hover-framevalg og museflytting inn i panelet.
- test_v026 beholder kontroll av native muse-/berøringshendelser, build-slot-klaring, panelgrenser og skjuling ved wave-start/siste wave.
- Full regresjonssuite kjøres med Godot 4.4.1 og inngår i GitHub Pages-workflow.
- Native skjermbilde av bane 5 wave 22 kontrollert: alle seks typer og total 27 fra den øvre inngangen passer i panelet.
- Web eksportert og åpnet i nettleser lokalt; bane 5 wave 1 viser Normal x6, PE Boy x1, PE Girl x1, total 8 fra inngang A.
