"""Original cartoon foley: filtered air, rubber bubbles and rounded impacts.

No recordings, external samples, square waves or 8-bit quantization.
Run with Python's standard library to reproduce all nine game effects.
"""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 44100
DEST = Path(__file__).resolve().parents[1] / "assets" / "audio"
TAU = math.tau

def decay(t, length):
    return (1 - math.exp(-max(0, t) / .004)) * math.exp(-max(0, t) / length)

def chirp(t, duration, start, end):
    if not 0 <= t < duration:
        return 0.0
    ratio = math.log(end / start)
    phase = TAU * start * duration / ratio * math.expm1(ratio * t / duration)
    return math.sin(phase) * math.sin(math.pi * t / duration) ** 1.3

def rubber(t, frequency=130, drop=140, length=.10):
    if t < 0:
        return 0.0
    phase = TAU * (frequency*t + drop*.027*(1-math.exp(-t/.027)))
    return (math.sin(phase)+.16*math.sin(phase*2.03)) * decay(t, length)

def pluck(t, frequency, length=.07):
    if t < 0:
        return 0.0
    # Inharmonic, quickly damped overtones sound like a tiny wooden mallet.
    return sum(weight*math.sin(TAU*frequency*ratio*t)*math.exp(-t/(length*fall))
               for ratio, weight, fall in [(1,.7,1),(2.76,.24,.5),(5.4,.08,.25)]) * (1-math.exp(-t/.002))

def write(name, duration, synth):
    rng = random.Random("cartoon-v033-"+name)
    low = bass = 0.0
    values = []
    for i in range(round(duration*RATE)):
        t = i/RATE
        low += .22*(rng.uniform(-1,1)-low)
        bass += .045*(low-bass)
        air = low-bass
        value = synth(t, air, bass)
        values.append(value)
    # A very short room tail softens the dry synthesis without a long echo.
    dry = values.copy()
    for delay, gain in [(.011,.12),(.023,.075),(.037,.04)]:
        offset = round(delay*RATE)
        for i in range(offset,len(values)):
            values[i] += dry[i-offset]*gain
    dc = sum(values)/len(values)
    values = [(v-dc)*min(1,i/(RATE*.003),(len(values)-1-i)/(RATE*.025)) for i,v in enumerate(values)]
    rms = math.sqrt(sum(v*v for v in values)/len(values)) or 1
    peak = max(abs(v) for v in values) or 1
    gain = min(.075/rms,.22/peak)
    samples = [round(v*gain*32767) for v in values]+[0]*441
    with wave.open(str(DEST/(name+".wav")),"wb") as out:
        out.setparams((1,2,RATE,0,"NONE","not compressed"))
        out.writeframes(b"".join(struct.pack("<h",s) for s in samples))
    print(f"{name}: {len(samples)/RATE:.3f}s, peak {peak*gain:.3f}")

if __name__ == "__main__":
    DEST.mkdir(parents=True,exist_ok=True)
    write("book_throw",.25,lambda t,a,b: a*2.0*math.exp(-((t-.095)/.053)**2)+b*.25*math.exp(-((t-.12)/.065)**2))
    write("book_hit",.19,lambda t,a,b: (a*1.3+b*.6)*decay(t,.027)+pluck(t,180,.025)*.35)
    write("science_throw",.30,lambda t,a,b: chirp(t,.14,520,180)*.7+chirp(t-.09,.15,740,260)*.4+a*.17*decay(t,.08))
    write("science_hit",.34,lambda t,a,b: (a+b*.6)*decay(t,.044)+chirp(t,.13,350,110)*.6+chirp(t-.07,.14,680,230)*.26+chirp(t-.14,.13,420,155)*.2)
    write("pe_throw",.27,lambda t,a,b: (a*.7+b*1.5)*math.exp(-((t-.09)/.06)**2)+rubber(t,80,70,.035)*.32)
    write("pe_burst",.30,lambda t,a,b: rubber(t,75,125,.055)*.7+(a*.7+b)*decay(t,.035)+rubber(t-.085,115,60,.028)*.15)
    write("build",.29,lambda t,a,b: pluck(t,240,.034)*.8+pluck(t-.085,340,.05)*.75+a*.3*decay(t,.025))
    write("upgrade",.44,lambda t,a,b: pluck(t,523.25,.085)*.6+pluck(t-.075,783.99,.085)*.57+pluck(t-.15,1046.5,.095)*.48)
    write("graduate",.29,lambda t,a,b: pluck(t,880,.065)*.65+pluck(t-.07,1320,.075)*.45)
