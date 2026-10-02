# Academic Defence v0.006 – verifikasjon

Teaching Assistant Post er lagt til i eksisterende prosjekt.

1244 kontroller, 0 feil: tidligere headless-regresjoner1028 og grafiske regresjoner89, nye assistentregler52 og ny grafisk input/visuell test75. Testene ble kjørt i Godot4.4.1.

Verifisert:120KP,2 assistenter, ulike hjemmeplasser, eksklusiv reservasjon, to samtidige undervisninger og tredje elev uten hold;3sekunder og5Knowledge/sek maksimalt15; samme holdtid for normal/PE-gutt/PE-jente; tilnærming til bevegelige elever; normal fart etter undervisning; slow utløper under hold; return/cooldown; graduation via eksisterende effekt; salg frigjør alle elever og gir60KP. Pause fryser undervisning. Manuelt rally snaps til veien innenfor260radius og beholder valgt tårn. Ugyldige/distant punkter avvises. Native faktisk radialinput og SELL er kontrollert.

Alle assistentens idle/walk/teach-frames har samme60x88canvas og fast fotanker; posisjonen styres av Node2D. Grafikk er kontrollert på skjermbilder.

Uavhengig review fant en radiusgrense236vs260; korrigert med rød/grønn regresjonstest. Prosjektversjon korrigert til0.006. Ny Web-export exit0; lokalserver svarer200 på http://127.0.0.1:8765/ . GitHub Pages har fortsatt den tidligere publiserte0.005; denne leveransen er lokal.
