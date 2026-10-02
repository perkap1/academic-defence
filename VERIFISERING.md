# Academic Defence v0.005 – verifikasjon

Godot 4.4.1 stable. Forrige v0.004 er bevart i separat ZIP.

1 117 kontroller bestått, 0 feil: grunnregler 14, Blackboard/PE 79, bane 1 integrasjon 30, v0.003 regler 106, bane 2 integrasjon 30, v0.004 regler 193, nye angrep 576, grafiske regresjoner 28 + 28 + 20 og nye grafiske angrep 13.

De nye testene kontrollerer tilfeldig bokstav per skudd, stabile pivoter og animasjonsframes, uendret fart og enkeltmålstreff, kunnskapsmengde, Blackboard-radius og treff, 30 % slow med refresh, normal fart ved utløp, dråper gjennom hele slow-perioden og opprydding av effekter. Vanlige studenter, PE-gutt og PE-jente er kontrollert.

Book beholder 20 Knowledge, intervall 1 sekund, rekkevidde 260 og prosjektilfart 640. Blackboard beholder 15 Knowledge, intervall 1,3 sekunder, rekkevidde 225 og radius 105 rundt valgt mål. Slow varer 2 sekunder og stacker ikke.

Grafisk spilltest viser bokstavflight, svampesveip, wet splash og dråper. Begge baner kan fullføres. Uavhengig kodegjennomgang fant ingen handlingskrevende feil. Ny webeksport er gjennomført og lokal webserver kjører på http://127.0.0.1:8765/.
