"""Original, deterministic 8-bit effects. No samples or external dependencies."""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
DEST = Path(__file__).resolve().parents[1] / "assets" / "audio"

def tone(t, frequency, duty=0.5):
    return (1.0 if (t * frequency) % 1 < duty else -1.0) - (2 * duty - 1)

def make(name, duration, synth):
    rng = random.Random(name)
    values = []
    for i in range(round(RATE * duration)):
        t = i / RATE
        envelope = min(1, t / 0.003) * min(1, (duration - t) / 0.018)
        value = sum(synth(t + j / (RATE * 4), rng) for j in range(4)) / 4
        values.append(value * envelope)
    peak = max(abs(v) for v in values) or 1
    samples = [round(max(-1, min(1, v / peak)) * 127) / 127 * 0.22 for v in values]
    samples += [0] * 220
    with wave.open(str(DEST / (name + ".wav")), "wb") as out:
        out.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        out.writeframes(b"".join(struct.pack("<h", round(v * 32767)) for v in samples))

def notes(frequencies, length):
    def synth(t, rng):
        index = min(len(frequencies) - 1, int(t / length))
        local = t % length
        return tone(local, frequencies[index], 0.25) * (1 - local / length) ** 0.6
    return synth

if __name__ == "__main__":
    DEST.mkdir(parents=True, exist_ok=True)
    make("book_throw", .10, lambda t, r: tone(t, 1350 - 8000*t, .25) * math.exp(-20*t))
    make("book_hit", .065, lambda t, r: (.7*r.uniform(-1,1)+.3*tone(t, 160)) * math.exp(-45*t))
    make("science_throw", .16, lambda t, r: tone(t, 450+1300*t+70*math.sin(90*t), .25)*math.exp(-8*t))
    make("science_hit", .19, lambda t, r: (.8*tone(t, 470-1500*t, .5)+.2*r.uniform(-1,1))*math.exp(-13*t))
    make("pe_throw", .12, lambda t, r: (.75*tone(t, 210-950*t)+.25*r.uniform(-1,1))*math.exp(-16*t))
    make("pe_burst", .17, lambda t, r: (.75*r.uniform(-1,1)+.25*tone(t, 100))*math.exp(-26*t))
    make("build", .18, notes([523.25,659.25,783.99], .06))
    make("upgrade", .28, notes([523.25,659.25,783.99,1046.5], .07))
    make("graduate", .18, notes([1046.5,1567.98], .09))
    print("Generated 9 original mono WAV effects at 22050 Hz")
