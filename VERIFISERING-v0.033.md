# Academic Defence v0.033 — cartoon sound replacement

Replaced all nine 8-bit WAV assets with original, smoother cartoon effects: airy book swish/paper impact, bubbling science launch/wet splat, heavy PE whoosh/rubber burst, building clunk, upgrade plucks and soft graduation chime. Generated locally without third-party recordings or samples. Updated the sound window title to Lydeffekter.

Existing sound triggers, bus gain, volume/mute settings, save path, cooldowns and voice limits are unchanged. No gameplay changes.

Verified all nine WAV files: mono 44100 Hz / 16 bit, duration 0.20–0.45 seconds, zero-ended fades, capped peak <= 0.22 and full-resolution waveforms. Godot audio suite passed 31 checks with both Dummy and native WASAPI outputs. Import and web export completed without script errors. A preview montage is available at ../../work/cartoon-sound-preview.wav.

Local test: http://127.0.0.1:8765/?v=0.033
