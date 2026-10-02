import math, random, struct, wave, os

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')

def silence(dur):
    return [0.0] * int(SR * dur)

def white(dur, seed=None):
    r = random.Random(seed)
    return [r.uniform(-1, 1) for _ in range(int(SR * dur))]

def brown(dur, seed=None):

    r = random.Random(seed)
    out, last = [], 0.0
    for _ in range(int(SR * dur)):
        last = (last + r.uniform(-1, 1) * 0.02)
        last = max(-1.0, min(1.0, last * 0.998))
        out.append(last)
    return out

def lowpass(buf, cutoff):
    a = math.exp(-2 * math.pi * cutoff / SR)
    out, y = [], 0.0
    for x in buf:
        y = (1 - a) * x + a * y
        out.append(y)
    return out

def highpass(buf, cutoff):
    low = lowpass(buf, cutoff)
    return [x - l for x, l in zip(buf, low)]

def bandpass(buf, low_hz, high_hz):
    return lowpass(highpass(buf, low_hz), high_hz)

def sine(dur, freq, phase=0.0):
    n = int(SR * dur)
    return [math.sin(2 * math.pi * freq * i / SR + phase) for i in range(n)]

def sweep(dur, f0, f1, curve=1.0):

    n = int(SR * dur)
    out, ph = [], 0.0
    for i in range(n):
        t = (i / n) ** curve
        f = f0 + (f1 - f0) * t
        ph += 2 * math.pi * f / SR
        out.append(math.sin(ph))
    return out

def env(buf, attack=0.01, decay=0.2, sustain=0.0, release=0.1, hold=0.0):

    n = len(buf)
    a, d, h, r = (int(SR * x) for x in (attack, decay, hold, release))
    out = []
    for i, x in enumerate(buf):
        if i < a:
            g = i / max(1, a)
        elif i < a + d:
            k = (i - a) / max(1, d)
            g = 1.0 + (sustain - 1.0) * k
        elif i < a + d + h:
            g = sustain
        else:
            k = (i - a - d - h) / max(1, r)
            g = max(0.0, sustain * (1.0 - k)) if sustain > 0 else max(0.0, (1.0 - k)) * 0.0
        out.append(x * g)

    return out[:n]

def decay_env(buf, tau):

    return [x * math.exp(-i / (SR * tau)) for i, x in enumerate(buf)]

def fade(buf, fin=0.01, fout=0.05):
    n = len(buf)
    fi, fo = int(SR * fin), int(SR * fout)
    out = list(buf)
    for i in range(min(fi, n)):
        out[i] *= i / fi
    for i in range(min(fo, n)):
        out[n - 1 - i] *= i / fo
    return out

def mix(*bufs):
    n = max(len(b) for b in bufs)
    out = [0.0] * n
    for b in bufs:
        for i, x in enumerate(b):
            out[i] += x
    return out

def at(base, buf, t):

    start = int(SR * t)
    need = start + len(buf)
    if need > len(base):
        base.extend([0.0] * (need - len(base)))
    for i, x in enumerate(buf):
        base[start + i] += x
    return base

def gain(buf, g):
    return [x * g for x in buf]

def normalize(buf, peak=0.7):
    m = max(abs(x) for x in buf) or 1.0
    return [x * peak / m for x in buf]

def loopable(buf, xfade=0.25):

    n = len(buf)
    f = int(SR * xfade)
    out = list(buf[:n - f])
    for i in range(f):
        k = i / f
        out[i] = buf[i] * k + buf[n - f + i] * (1 - k)
    return out

def save(name, buf, peak=0.7):
    buf = normalize(buf, peak)
    path = os.path.join(OUT, name)
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, x)) * 32767)) for x in buf))
    print('  %-18s %5.1f s  %6.0f KB' % (name, len(buf) / SR, os.path.getsize(path) / 1024))

def vento():

    dur = 12.0
    base = lowpass(brown(dur, seed=7), 260)

    out = []
    for i, x in enumerate(base):
        t = i / SR
        lfo = 0.55 + 0.45 * (0.6 * math.sin(2 * math.pi * 0.07 * t)
                             + 0.4 * math.sin(2 * math.pi * 0.11 * t + 1.7))
        out.append(x * lfo)

    whistle = gain(sine(dur, 1180), 0.015)
    whistle = [x * (0.5 + 0.5 * math.sin(2 * math.pi * 0.09 * i / SR)) for i, x in enumerate(whistle)]
    save('amb_vento.wav', loopable(mix(gain(out, 1.0), whistle)), peak=0.45)

def coracao():

    base = silence(1.15)
    for t, g in ((0.0, 1.0), (0.26, 0.72)):
        thump = mix(decay_env(sine(0.30, 54), 0.055),
                    gain(decay_env(lowpass(white(0.30, seed=int(t * 100)), 160), 0.035), 0.5))
        at(base, gain(thump, g), t)
    save('amb_coracao.wav', loopable(base, xfade=0.08), peak=0.6)

def candeeiro():

    dur = 6.0
    flame = gain(bandpass(white(dur, seed=21), 700, 3200), 0.25)
    flame = [x * (0.6 + 0.4 * math.sin(2 * math.pi * 7.3 * i / SR)
                  + 0.2 * math.sin(2 * math.pi * 13.1 * i / SR)) for i, x in enumerate(flame)]
    save('amb_candeeiro.wav', loopable(flame, xfade=0.2), peak=0.3)

def azeite():

    base = silence(1.4)
    drop = decay_env(sweep(0.08, 900, 300), 0.02)
    at(base, gain(drop, 0.5), 0.0)
    flare = bandpass(white(1.1, seed=3), 500, 4000)
    flare = [x * min(1.0, (i / (SR * 0.25))) * math.exp(-i / (SR * 0.55))
             for i, x in enumerate(flare)]
    at(base, gain(flare, 0.8), 0.07)
    at(base, gain(decay_env(sine(0.9, 196), 0.4), 0.18), 0.1)
    save('acao_azeite.wav', fade(base), peak=0.65)

def sal():

    base = silence(1.0)
    r = random.Random(11)
    for _ in range(90):
        t = r.uniform(0.0, 0.45) ** 0.7
        g = r.uniform(0.2, 1.0) * (1 - t)
        grain = decay_env(highpass(white(0.04, seed=r.randint(0, 9999)), 2600), 0.006)
        at(base, gain(grain, g * 0.5), t)
    at(base, gain(decay_env(bandpass(white(0.5, seed=5), 1800, 7000), 0.09), 0.35), 0.0)
    save('acao_sal.wav', fade(base), peak=0.6)

def reza():

    dur = 2.6
    murmur = lowpass(white(dur, seed=13), 520)
    murmur = [x * (0.5 + 0.5 * math.sin(2 * math.pi * 4.6 * i / SR)) for i, x in enumerate(murmur)]
    voice = mix(gain(sine(dur, 112), 0.25), gain(sine(dur, 168), 0.12))
    voice = [x * (0.6 + 0.4 * math.sin(2 * math.pi * 2.1 * i / SR)) for i, x in enumerate(voice)]
    bell = mix(decay_env(sine(2.4, 587), 0.9),
               gain(decay_env(sine(2.4, 880), 0.7), 0.5),
               gain(decay_env(sine(2.4, 1174), 0.5), 0.25))
    base = mix(gain(murmur, 0.5), gain(voice, 0.8))
    at(base, gain(bell, 0.4), 0.15)
    save('acao_reza.wav', fade(base, 0.05, 0.4), peak=0.6)

def trago():

    base = silence(2.0)
    at(base, gain(decay_env(sweep(0.06, 420, 260), 0.02), 0.6), 0.0)
    for k, t in enumerate((0.22, 0.56)):
        glug = decay_env(sweep(0.26, 210 - k * 30, 96), 0.07)
        at(base, gain(glug, 0.75), t)
        at(base, gain(decay_env(lowpass(white(0.18, seed=k), 900), 0.05), 0.25), t)
    breath = gain(bandpass(white(0.7, seed=9), 300, 2200), 0.3)
    breath = [x * math.sin(math.pi * i / len(breath)) for i, x in enumerate(breath)]
    at(base, breath, 1.1)
    save('acao_trago.wav', fade(base), peak=0.6)

def escutar():

    dur = 2.2
    ring = gain(sine(dur, 3150), 0.5)
    ring = [x * math.exp(-abs(i - SR * 0.5) / (SR * 1.1)) for i, x in enumerate(ring)]
    room = gain(lowpass(white(dur, seed=17), 180), 0.5)
    tick = silence(dur)
    for t in (0.35, 0.95, 1.55):
        at(tick, gain(decay_env(bandpass(white(0.1, seed=int(t * 77)), 400, 1800), 0.02), 0.35), t)
    save('acao_escutar.wav', fade(mix(ring, room, tick), 0.08, 0.5), peak=0.5)

def susto():

    base = silence(1.6)
    at(base, gain(decay_env(sweep(0.9, 150, 38, curve=0.6), 0.28), 1.0), 0.0)
    at(base, gain(decay_env(bandpass(white(0.35, seed=23), 900, 5200), 0.07), 0.35), 0.02)
    at(base, gain(decay_env(sine(1.2, 73), 0.5), 0.4), 0.05)
    save('sfx_susto.wav', fade(base), peak=0.78)

def defesa():

    base = silence(1.3)
    at(base, gain(decay_env(sweep(0.7, 320, 120, curve=1.4), 0.3), 0.6), 0.0)
    at(base, gain(decay_env(sine(1.0, 294), 0.45), 0.35), 0.0)
    at(base, gain(decay_env(sine(1.0, 392), 0.4), 0.22), 0.06)
    save('sfx_defesa.wav', fade(base), peak=0.6)

def hora():

    base = silence(0.9)
    at(base, gain(decay_env(bandpass(white(0.25, seed=31), 500, 2400), 0.03), 0.5), 0.0)
    at(base, gain(decay_env(sine(0.6, 220), 0.12), 0.3), 0.0)
    save('sfx_hora.wav', fade(base), peak=0.5)

def amanhecer():

    base = silence(5.0)
    for t, f in ((0.0, 523.25), (1.3, 392.0)):
        bell = mix(decay_env(sine(3.2, f), 1.5),
                   gain(decay_env(sine(3.2, f * 2), 1.1), 0.45),
                   gain(decay_env(sine(3.2, f * 3), 0.7), 0.18))
        at(base, gain(bell, 0.55), t)
    r = random.Random(41)
    for _ in range(14):
        t = r.uniform(1.0, 4.4)
        f0 = r.uniform(2300, 3100)
        chirp = decay_env(sweep(r.uniform(0.04, 0.09), f0, f0 * r.uniform(1.2, 1.7)), 0.02)
        at(base, gain(chirp, r.uniform(0.08, 0.2)), t)
    at(base, gain(lowpass(brown(5.0, seed=43), 300), 0.5), 0.0)
    save('fim_amanhecer.wav', fade(base, 0.05, 1.2), peak=0.7)

def escuro():

    base = silence(4.2)
    puff = gain(decay_env(bandpass(white(0.4, seed=51), 200, 2000), 0.09), 0.5)
    at(base, puff, 0.0)
    rumble = gain(lowpass(brown(3.4, seed=53), 90), 1.0)
    rumble = [x * min(1.0, i / (SR * 2.2)) for i, x in enumerate(rumble)]
    at(base, rumble, 0.5)
    at(base, gain(decay_env(sine(2.2, 41), 1.0), 0.6), 1.4)
    at(base, gain(decay_env(bandpass(white(0.8, seed=57), 1200, 6000), 0.2), 0.18), 2.6)
    save('fim_escuro.wav', fade(base, 0.02, 0.6), peak=0.8)

def fuga():

    base = silence(4.0)
    r = random.Random(61)
    t = 0.0
    while t < 2.6:
        step = gain(decay_env(lowpass(white(0.14, seed=r.randint(0, 9999)), 700), 0.03), r.uniform(0.4, 0.7))
        at(base, step, t)
        t += r.uniform(0.17, 0.24)
    breath = gain(bandpass(white(2.8, seed=63), 400, 2600), 0.3)
    breath = [x * (0.5 + 0.5 * math.sin(2 * math.pi * 1.6 * i / SR)) for i, x in enumerate(breath)]
    at(base, breath, 0.1)
    at(base, gain(decay_env(sweep(1.6, 120, 44, curve=0.7), 0.7), 0.7), 2.4)
    save('fim_fuga.wav', fade(base, 0.02, 0.9), peak=0.75)

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    print('Sintetizando o áudio de A Vigília do Candeeiro:')
    for fn in (vento, candeeiro, coracao, azeite, sal, reza, trago, escutar,
               susto, defesa, hora, amanhecer, escuro, fuga):
        fn()
    print('Pronto.')
