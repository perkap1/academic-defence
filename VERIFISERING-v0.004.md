# Academic Defence v0.004 – verifikasjon

Godot 4.4.1 stable. Forrige v0.003 er bevart som separat ZIP.

## Testresultater

| Test | Kontroller | Feil |
|---|---:|---:|
| Grunnregler | 14 | 0 |
| Blackboard/PE-regresjon | 79 | 0 |
| Bane 1 komplett spillrunde | 30 | 0 |
| Slow/salg/selection/bane 2 | 106 | 0 |
| Bane 2 komplett spillrunde | 30 | 0 |
| Graduation/radialfunksjoner | 193 | 0 |
| Grafisk regresjon på bane 1 | 28 | 0 |
| Grafisk regresjon på bane 2 | 28 | 0 |
| Grafiske graduation/radialklikk | 20 | 0 |
| **Totalt** | **528** | **0** |

Den nye testen feilet først på manglende radialmeny og graduation-effekt, og bestod etter implementering.

## Completion

Studenten markeres done, fjernes fra students-gruppen og skjules før resolution-signalet sendes. Rewards og bølgesystem beholder samme tidspunkt og gir ikke ekstra belønning ved nye treff. Effekten er en selvstendig node i kartets Effects, med ni faste PNG-rammer fra brukerens ark: røyk, hatt som stiger og stjernestøv. Hele effekten varer 0,85 sekunder, siste støvramme fades ut, og noden frigjøres automatisk.

Normal student, PE-gutt og PE-jente bruker samme effekt. Umiddelbar untargetability, world anchor, rekkefølge, endelig levetid og opprydding er testet. Faktisk grafisk kontroll viser poff, hatt og støv for alle tre typer. Pause stopper effekten og fortsett lar den fullføre.

## Radialmeny

Den gamle paneldialogen og dens infopanel er fjernet fra byggeflyten. Nye Book-, Blackboard- og Cancel-bilder bruker brukerens normal/hover/disabled-states på like store canvases. Ikon og navn finnes i bildene, med KP-pris under valget. Ingen Assistant er tilgjengelig.

Radialmenyen sentreres på slot.global_position uten clamping eller animert flytting. Alle ni plasser på bane 1 og alle åtte på bane 2 er testet. Hover, økonomi og endret vindusstørrelse endrer ikke sentrum. Circular outside-hit-testing omfatter også valgenes knapper. Menyens midtparti blokkerer klikk til byggeplassen bak. Disabled-klikk bygger ikke, outside/Cancel lukker, og vellykket bygging lukker menyen.

## Regresjon og web

Begge komplette spillrunder er simulert på vanlig startbudsjett. Bane 1 vinner med 9 omdømme, og bane 2 med 8; studenttotalene er fortsatt 80 og 218. Begge no-tower-strategier taper korrekt. Grafisk input dekker begge byggetyper, salg, selection, pause, restart, resizing og kartoverganger.

Den nye Godot Web-eksporten er åpnet via http://127.0.0.1:8765/. Nettleserklikk bekreftet radial plassering, Book-bygging og automatisk lukking, nye disabled-bilder ved 60 KP, utenfor-lukking og bølgestart. Første bølge ble fullført med fire opplærte og to som slapp gjennom. Animasjonsstadiene er visuelt kontrollert i Godots grafiske renderer; nettleserkontrollen er ikke et manuelt gjennomspill av alle bølgene.

En uavhengig kildekodegjennomgang fant ingen actionable feil i graduation-livsløp, samtidig completion, siste bølge, pause, GUI/Area2D-input eller radial plassering. Source/Web-pakker får ZIP CRC-kontroll. Eksportmalene følger med prosjektet. Lokalserveren er beholdt, og Start web.cmd kan starte den igjen senere.

Prosjekt-ZIP er pakket ut i en egen kontrollmappe og importert og eksportert på nytt med inkluderte maler, uten feil eller advarsler.
