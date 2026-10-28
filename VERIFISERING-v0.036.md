# Academic Defence v0.036 — new Science Tower animations

Uses the supplied Science Tower PNG unchanged (SHA256 F961ABF140DCBDFFA6F596D0FD6EB3BC81BB8A5FE1AAFA2285B583D22E2DF2DE). Godot atlas regions provide six idle frames and five experiment frames on a common 600x600 canvas. Idle is 1.5 frames/second, matching Book Tower. All five attack frames fit the existing 0.4-second animation; the firing interval is unchanged.

The desk uses a fixed full-width base; the actor's narrower atlas regions exclude adjacent teachers in the tightly packed sheet. Two small display masks remove neighboring fragments where experiment effects overlap cells, respecting left/right mirroring. The source image is not edited. Gold level numerals are retained on the new red banner. Radial-menu art uses the new source automatically. Stats, upgrades, prices, spinning/directional projectiles and damage/slow behavior remain unchanged.

Verification: Science Tower 99 checks, presentation 88, tower size 16, Book Tower 49, upgrades 107, projectile direction 30, audio 31 and unit layout 1690; all zero failures. All eleven frames were visually inspected in native Godot, including the mirrored view. Web export completed without script errors.
