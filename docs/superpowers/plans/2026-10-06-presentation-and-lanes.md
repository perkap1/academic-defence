# v0.009 – presentation and unit lanes

Use the existing project and user supplied sheets directly as Godot AtlasTextures; no Aseprite or raster editing. Keep all stats, costs, shot counters, wave counts/intervals/speeds, maps and paths.

1. Add failing tests for Book4+4 cycle/attack, Blackboardstaticidle/4 orderedattack frames and level FX, supplied upgrade states, units70% and bounded smooth lanes.
2. Preserve sheets; reusable Godot atlas/pivot data, static lower tower base plus animated upper part. Book4fps8periodcycle; attack0.25sec. Board4frames10fps (.4sec), instantaneous existing Knowledge/slow and concurrent .45sec5frameFX. Keep damage timing and cooldowns.
3. Upgrade arrow from supplied normal/hover/pressed/disabled (MAXdisabled) states, same canvas.
4. Shared unit layout scale.70, knowledge bars retain readable width/height. Independent lane RNG, ±24px normal-side offset, smooth bridge narrowing at entry/exit and bend taper, no spawn/movement timing changes. Assistants meet actual student position at24px gap; distinct rally homes maintained.
5. Tests including bridge containment, smoothness, assistant interactions and both maps; regressions, graphics, independent review, Web export and local browser link.

Execution inline; existing local uncommitted v0.008/waterfall changes preserved. No GitHub push requested.

Completed: all five steps, 3570 passing checks, independent review, Web export and browser checks on both maps. See VERIFISERING-v0.009.md. Cosmetic overlapping sponge halo atlas edges documented.
