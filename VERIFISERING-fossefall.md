# Fossefall på Map 2 – 5. oktober 2026

Bruker avklarte at målet er fossefallet øverst til høyre på Map 2 (Elvesvingene). Map 1 har ikke dette fossefallet.

Originalt 2172×724 sprite-sheet beholdes i assets/waterfall/waterfall_sheet.png. Seks AtlasTexture-regioner bruker samme crop (335×455), y135, x25+362×frame. AnimatedWaterfall.tscn bruker AnimatedSprite2D med seks frames, 7 FPS, kontinuerlig loop, top-left origin og nearest-filter. Plassering i Map2 er (1443,150), scale0.28. Bakgrunnsmasken tillater bare vann/foam over eksisterende vann; klipper og terreng forblir urørt. Den tidligere lille top-right patchen er fjernet; bottom-left patchen er beholdt.

Scene kan gjenbrukes ved å sette posisjon/scale og background_path til kartets eksisterende Background Sprite2D. Hver instans har eget materiale og beregner maskens koordinater automatisk. Kall refresh_background_mask() dersom en instans flyttes etter _ready. Ingen collision, input eller fysikk.

Verifisering:
- Ny test feilet før implementering på manglende scene.
- Ti headless-suiter: 1259 kontroller, 0 feil.
- Grafisk fossefallstest: 29 kontroller, 0 feil. Alle seks frames faktisk spilt, fast world position/scale, pause og gameplay testet.
- Alle seks renderede frames er forskjellige. Gjennomsnittlig RGB-endring ved loopens siste/første frame var2.470, sammenlignet med2.389–2.944 mellom øvrige naboframes; ingen stor seam-differanse.
- Originale map1.png/map2.png, map1.gd/map2.gd og main.gd matcher eksisterende Git-versjon byte for byte.
- Web-export vellykket i Godot4.4.1. Lokal startmeny, Map2, tårnbygging og bølgestart kontrollert i nettleseren uten console errors/warnings. HTML/JS/WASM/PCK returnerte HTTP200.

Lokal testlenke: http://127.0.0.1:8765/ . Velg 2 – Elvesvingene.
