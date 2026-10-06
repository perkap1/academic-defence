# Academic Defence v0.008 – Tower upgrades

Testet 5. oktober 2026, Godot 4.4.1.

- 107 oppgraderingskontroller: stats, kostnad én gang, beholdt node/posisjon/cooldown, MAX, manglende ressurser, eierskap, pause, ferdig runde, salg, Golden Letter hvert femte skudd, faktisk AoE og slow på Normal/PE boy/PE girl.
- 1 259 eksisterende regler/integrasjon/regresjonskontroller: alle bestått, inkludert komplette runder på begge banene, assistenter, radialmeny, miljø og fossefall.
- 54 grafiske kontroller på begge banene: ekte klikk gjennom Level 1–2–3, disabled/MAX, salg, deselection, fast banner/tårnplassering og tekst innenfor rammen. Alle bestått.
- Uavhengig kodegjennomgang: én banner-layoutfeil funnet og rettet med test som feilet før og bestod etter. Ingen øvrige funksjonelle funn.
- De 20 nye spriterammene er hentet fra brukerens ark med Aseprite, nearest-neighbor, felles 180×188 canvas og forankring etter steinbasen. Originale ark er bevart i assets/source/upgrades.
- Web-export til ../AcademicDefence-Web/index.html fullført med tilhørende JS/WASM/PCK-filer.

Lokal testlenke: http://127.0.0.1:8765/

- 230 tidligere grafiske kontroller bestått, inkludert 75 assistentkontroller og fossefalltesten. Totalt 1 650 kontroller bestått (1 366 gameplay + 284 grafiske).
- Nettleser: verdenskart, bane 2, ekte kjøp av Advanced Book/Blackboard, riktig sprite/statbanner, disabled ved manglende KP, og bølgestart kontrollert. Ingen konsollfeil/varsler. HTML/JS/WASM/PCK leveres fra lokal server med HTTP 200 og identisk innhold med nyeste export.
