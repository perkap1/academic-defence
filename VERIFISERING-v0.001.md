# Verifikasjon – 2. oktober 2026

Testet med Godot **4.4.1 stable** på Windows. Den grafiske testen brukte OpenGL-kompatibilitetsmodus på maskinens NVIDIA-grafikkort.

## Resultater

- Prosjektimport: fullført, ingen skriptfeil i den komplette leveransen.
- Normal oppstart av hovedscenen: fullført uten feilmeldinger.
- ZIP-leveransen: pakket ut i en ren mappe, importert i Godot og kjørt gjennom alle 44 regel- og integrasjonskontroller på nytt med 0 feil.
- `test_rules.gd`: **14 kontroller, 0 feil**.
- `test_integration.gd`: **30 kontroller, 0 feil**.
- `test_visual.gd`: **12 kontroller, 0 feil**; ingen feilmeldinger fra grafisk kjøring.
- Renderte skjermbilder av start, spill og endret vindusstørrelse er visuelt kontrollert.
- Uavhengig gjennomgang av kode og scener fant ingen alvorlige spillfeil. En ekstra byggeplass uten steinmarkering ble fjernet, og testen ble utvidet til faktisk klikk etter vindusendring og på omstartknappen. Hele regel- og integrasjonstestene ble kjørt igjen etter endringen.

## Hva som er kontrollert

Byggekostnad, utilstrekkelig gull, opptatte byggeplasser, kunnskap som stopper på 100, levende kunnskapsbar, én fullføring per student, belønning, tap av omdømme, ugyldige prosjektilmål og blokkering av spillhandlinger etter tap.

Bølgestart uten overlapping, bølgeavslutning som venter på studentene, alle 73 studenter i sju bølger, seier med ordinært startbudsjett, tap uten tårn, umiddelbar stopp av spawning ved tidlig tap og ren omstart.

Grafisk input ble sendt gjennom Godots vanlige vinduskoordinater. Bygging, prisavvisning, bølgestart, omstartknappen og klikk etter vindusendring ble kontrollert. Visningen ble kontrollert ved 1280 × 797 og ved et vindu på 1000 × 700 med bevart sideforhold.

## Spillbarhet

Den automatiserte strategitesten bygget to tårn med startbudsjettet og reinvesterte gull mellom bølgene. Resultatet var seier etter bølge 7: **9 omdømme, 72 ferdig opplærte studenter, 1 student sluppet gjennom**. Uten tårn tapte runden under bølge 2.

Dette viser at den første spillrunden kan vinnes med ordinære ressurser. Vanskelighetsgrad og opplevelse er ikke bredt testet av spillere. Versjonen er en prototype med én student- og tårntype, uten oppgraderinger eller lyd.

Leveransen er et Godot-kildeprosjekt med en lokal startfil. Den er ikke eksportert som en selvstendig Windows-programfil.
