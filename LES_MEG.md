# Academic Defence v0.006

Et Godot-spill der tårn lærer opp studenter før de når broen. v0.006 bygger videre på v0.003 med en radial byggemeny og en felles graduation-effekt.

## Spill i nettleseren

Åpne **http://127.0.0.1:8765/** på denne PC-en. Den lokale serveren er startet som del av leveransen.

Hvis serveren er stoppet senere, dobbeltklikk **Start web.cmd** i den separate mappen **AcademicDefence-Web**. Den starter serveren og åpner spillet. Web-ZIP-en kan pakkes ut til en egen mappe og startes på samme måte. På andre maskiner trenger startfilen Python 3 tilgjengelig.

Serveren lytter kun på 127.0.0.1. Dette er en lokal testversjon, ikke en offentlig publisert nettside. HTML-filen må åpnes via serveren, ikke ved å dobbeltklikke `index.html`.

## Spill lokalt med Godot

Dobbeltklikk **Start spill.cmd** i denne prosjektmappen for å bruke Godot-installasjonen på denne PC-en. Alternativt importer `project.godot` i Godot **4.4.1 eller nyere** og trykk **F5**.

Prosjektets Web-preset inneholder de offisielle enkelttrådede Godot 4.4.1-malene i `export_templates/`. For å eksportere med en annen Godot-versjon må du bruke eksportmaler som matcher den versjonen. Malene er inkludert i prosjekt-ZIP-en, slik at Godot 4.4.1 kan eksportere det utpakkede prosjektet igjen.

## Kontroller

Ved 100 kunnskap forsvinner studenten umiddelbart fra målvalget. En kort røyk-poff, en svevende graduation hat og magisk stjernestøv spiller i 0,85 sekunder. Alle studenttyper bruker samme effekt. Pause fryser også denne animasjonen.

1. Start på **World Map**. Velg **bane 1 – Skogsstien** eller **bane 2 – Elvesvingene**. De tre siste nodene er låst.
2. Klikk på en **+**-markering på battle-kartet for å åpne radialmenyen sentrert på plassen.
3. Velg **Book Tower** eller **Blackboard Tower**. Ikon og navn vises på hvert valg, med prisen under. Knapper blir mørke og inaktive hvis du mangler kunnskapspoeng.
4. Klikk **Start bølge**. Tårn underviser automatisk, og baren over hver student viser kunnskap.
5. Bruk **pauseikonet** eller **Esc** for pause/fortsett. Esc lukker først en åpen byggemeny. Klikk utenfor radialmenyen eller på Cancel for å lukke den.
6. **Kart** øverst til høyre tar deg tilbake til World Map. **Ny** starter battle-banen på nytt.
7. Etter seier/tap kan du velge **Spill igjen** eller **Verdenskart**.

Du kan bygge under en aktiv bølge. Klikk et bygget tårn for å vise rekkevidde og **SELL**. Klikk bakken, et annet tårn eller en byggeplass for å fjerne det gamle valget. SELL gir **35 KP** for Book eller **50 KP** for Blackboard, og plassen kan bygges på igjen. Pek på et tårn i byggemenyen for kort informasjon.

## Tårn og studenter

| Type | Pris | Undervisning | Intervall | Rekkevidde |
|---|---:|---|---:|---:|
| Book Tower | 70 KP | Ett mål, +20 kunnskap per prosjektil | 1 sek | 260 |
| Blackboard Tower | 100 KP | Puls, +15 kunnskap i radius 105 rundt målet og 30 % slow i 2 sek. | 1,3 sek | 225 |

Book Tower er best mot enkeltstudenter. Blackboard Tower underviser flere samtidig når de står tett. To Book Towers er et godt utgangspunkt for de første bølgene; gruppeundervisningen blir mer nyttig senere.

Vanlige studenter har hastighet 85. **PE-studenter** er **35 % raskere** og bruker gutte- eller jentevarianten tilfeldig. Begge studenttyper trenger 100 kunnskap, og begge følger den samme veien. PE-studentens bar har blå fyllfarge; normalstudentens bar er turkis.

Du starter med **200 KP** og **10 omdømme**. Ferdig opplært student gir **10 KP**, fullført bølge gir **45 KP**, og en student som når broen uten full kunnskap koster ett omdømme. Fullfør alle bølgene med omdømme igjen for å vinne: sju på bane 1 eller tolv på bane 2. Slow fornyes ved nye treff og stables aldri; begge studenttyper får normal fart igjen etter to sekunder.

| Bølge | Vanlige | PE |
|---|---:|---:|
| 1 | 4 | 0 |
| 2 | 6 | 0 |
| 3 | 6 | 2 |
| 4 | 8 | 3 |
| 5 | 10 | 4 |
| 6 | 12 | 5 |
| 7 | 14 | 6 |

## Bane 2 – tolv bølger

| Bølge | Vanlige | PE |
|---|---:|---:|
| 1 | 6 | 0 |
| 2 | 8 | 0 |
| 3 | 8 | 2 |
| 4 | 10 | 3 |
| 5 | 10 | 5 |
| 6 | 12 | 5 |
| 7 | 12 | 7 |
| 8 | 14 | 7 |
| 9 | 14 | 9 |
| 10 | 16 | 10 |
| 11 | 18 | 10 |
| 12 | 20 | 12 |

Spawnintervallet faller gradvis fra 1,8 til 0,75 sekunder.

## Prosjektstruktur

- `scenes/world_map.tscn`: start og level select; bane 1 og 2 er åpne.
- `scenes/main.tscn`: den eksisterende battle-banen, game manager, bølger og UI.
- `scenes/blackboard_tower.tscn` og `scripts/blackboard_tower.gd`: undervisningspuls med områdeeffekt.
- `scripts/student.gd`: felles rute, kunnskapssystem og type/variant for normal og PE.
- `scripts/ui.gd` og `ui_skin.gd`: HUD, byggevalg, info, pause og resultat, med vedlagte rammer og ikoner.
- `assets/source/`: de fem nye originalbildene, bevart uendret.
- `assets/`: spillets beskårne bilder med faste ankere og pikselgjengivelse.
- `export_templates/`: offisielle Godot 4.4.1-webmaler og lisens.
- `tests/`: regeltester, v0.006-tester, full spillrunde og faktisk grafisk input.

Bane 2 har egen scene main_map2.tscn / map2.tscn og åtte større, faste byggeplasser. Bane 1 beholder de ni eksisterende plassene.

## Tester og eksport

Importer prosjektet i Godot før testene kjøres. Erstatt `godot` med din Godot-programfil ved behov.

```
godot --headless --audio-driver Dummy --path . --script res://tests/test_rules.gd
godot --headless --audio-driver Dummy --path . --script res://tests/test_v002.gd
godot --headless --audio-driver Dummy --path . --script res://tests/test_integration.gd
godot --headless --path . --script res://tests/test_v003.gd
godot --headless --path . --script res://tests/test_map2_integration.gd
godot --headless --path . --script res://tests/test_v004.gd
godot --audio-driver Dummy --path . --script res://tests/test_visual.gd
godot --path . --script res://tests/test_visual_v003.gd
godot --path . --script res://tests/test_visual_v004.gd
godot --headless --path . --export-release Web ../AcademicDefence-Web/index.html
```

Testresultater og nettleserkontroll er beskrevet i **VERIFISERING.md**. Arkivet med første versjon er beholdt separat.



## Nye angrep i v0.006

Book Tower skyter en tilfeldig animert A, B eller C per skudd. Blackboard Tower sveiper med tavlesvampen rundt valgt mål og viser våte treff. Dråper vises mens 30 % slow er aktiv i to sekunder; nye treff fornyer varigheten uten å stable slow.

## Teaching Assistant Post – v0.006

Assistant koster120KP og lager2 assistenter. Hver assistent stopper én elev i3sekunder og gir5Knowledge per sekund (15totalt). De returnerer til rally etterpå med0,8sekunders cooldown. Alle studentvarianter holdes like lenge. Andre tårn kan fortsatt undervise den holdte eleven.

Velg posten for å vise rekkevidde260 og arbeidsområde110 rundt rally. Klikk på eller innen28piksler fra veien inne i rekkevidden for å flytte rally. Dette avbryter eksisterende undervisning og samler begge assistenter ved nye, separate hjemmeplasser. SELL frigjør elevene og gir60KP tilbake.
## Miljøanimasjoner – v0.007

Fem små, transparente fire-frame-loops er laget i Aseprite: vannkrusninger, fossefall, busker, bladverk og planter. Map 1 bruker 11 små animasjonspatcher; Map 2 bruker 15, inkludert to fossefall. De ligger bak studenter/tårn og har ingen kollisjon eller input. Fast posisjon og nearest-filter gir skarpe piksler. Miljøet følger pause.

Redigerbare filer ligger i assets/environment/source/*.aseprite. PNG-frames ligger i assets/environment/. Aseprite-skriptet kan kjøres med --batch --script-param out=EXPORT_DIRECTORY/ --script create_loops.lua. Kildene eksporteres ikke til Web.
