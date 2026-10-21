# Academic Defence v0.031.2

Medisinballen velger nå forover eller bakover langs sin valgte Path2D etter kastretningen ved landing. Retningen finnes ved å sammenligne kastets bevegelse langs bakken med veiens lokale tangent. Håndens høyde og den visuelle kastbuen påvirker ikke valget. Retningen beholdes gjennom svinger; ballen bytter ikke rute.

Sveipede treff bruker absolutt tilbakelagt avstand, slik at alle elever mellom to frames også kan treffes under baklengs rulling. Engangstreff, bokskjold, immunitet og statistikk er bevart. Ballen avsluttes ved rullegrensen eller den aktuelle enden av veien. Rotasjonen følger rulleretningen.

Rulleavstander forblir 240 / 350 / 480. Testmodus og alle øvrige spillverdier er uendret.

Verifisering: egne tester for begge retninger på rette, vertikale, diagonale og svingete veier, begge veiender, korte kast fra den hevede hånden og treff mellom frames. Eksisterende PE- og testmoduskontroller kjøres også.

Lokal versjon: http://127.0.0.1:8765/?v=0.031.2
